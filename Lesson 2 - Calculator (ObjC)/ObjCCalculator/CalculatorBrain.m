//
//  CalculatorBrain.m
//  ObjCCalculator
//
//  Created by Vince Li on 2016/7/28.
//  Copyright © 2016年 Vince. All rights reserved.
//

#import "CalculatorBrain.h"


@implementation PendingInfo
- (id)initWithArguments:(PendingOperation)pendingOperation firstOperand:(double)firstOperand{
    self = [super init];
    if(self) {
        _pendingOperation = pendingOperation;
        _firstOperand = firstOperand;
    }
    return self;
}
@end

@implementation TouchEvent
- (id)initWithArguments:(int)operationType symbol:(NSString*)symbol {
    self = [super init];
    if(self) {
        _operationType = operationType;
        _symbol = symbol;
    }
    return self;
}
@end



enum OperationTypes{
    Constant = 0,
    UnaryOperation,
    BinaryOperation,
    Equals,
    Digital,
    Back,
    Save,
    Restore
};

@interface CalculatorBrain ()
- (void) executeBinaryOperation;
@property NSDictionary* operationTypes;
@property NSDictionary* operations;
@property NSMutableArray* touchHistory;
@property NSMutableArray* pendingOperationsForRestore;
@property Boolean pendingForRestore;

- (void) back;
- (void) _performOperarion: (NSString*) symbol addToHistory:(Boolean)addToHistory;
@end

@implementation CalculatorBrain
@synthesize brainDescription = _brainDescription;

- (id)init
{
    self = [super init];
    if (self)
    {
        _result = 0.0;
        _brainDescription = nil;
        _pendingInfo = nil;
        _touchHistory = [[NSMutableArray alloc] init];
        _pendingOperationsForRestore = [[NSMutableArray alloc] init];
        _variableValues = [[NSMutableDictionary alloc] init];
        _pendingForRestore = false;
        
        _operationTypes = [NSDictionary dictionaryWithObjectsAndKeys:
                           [NSNumber numberWithInt:Digital], @"1",
                           [NSNumber numberWithInt:Digital], @"2",
                           [NSNumber numberWithInt:Digital], @"3",
                           [NSNumber numberWithInt:Digital], @"4",
                           [NSNumber numberWithInt:Digital], @"5",
                           [NSNumber numberWithInt:Digital], @"6",
                           [NSNumber numberWithInt:Digital], @"7",
                           [NSNumber numberWithInt:Digital], @"8",
                           [NSNumber numberWithInt:Digital], @"9",
                           [NSNumber numberWithInt:Digital], @"0",
                           [NSNumber numberWithInt:Digital], @".",
                           [NSNumber numberWithInt:Constant], @"π",
                           [NSNumber numberWithInt:Constant], @"e",
                           [NSNumber numberWithInt:Constant], @"C",
                           [NSNumber numberWithInt:UnaryOperation], @"√" ,
                           [NSNumber numberWithInt:UnaryOperation], @"log" ,
                           [NSNumber numberWithInt:UnaryOperation], @"cos" ,
                           [NSNumber numberWithInt:UnaryOperation], @"sin" ,
                           [NSNumber numberWithInt:UnaryOperation], @"tan" ,
                           [NSNumber numberWithInt:UnaryOperation], @"±" ,
                           [NSNumber numberWithInt:BinaryOperation], @"+",
                           [NSNumber numberWithInt:BinaryOperation], @"-",
                           [NSNumber numberWithInt:BinaryOperation], @"×",
                           [NSNumber numberWithInt:BinaryOperation], @"÷",
                           [NSNumber numberWithInt:Equals], @"=",
                           [NSNumber numberWithInt:Back], @"⬅︎",
                           [NSNumber numberWithInt:Restore], @"M",
                           nil];
        
        _operations = [NSDictionary dictionaryWithObjectsAndKeys:
                       ^() {return M_PI;}, @"π",
                       ^() {return M_E;}, @"e",
                       ^() {return 0.0;}, @"C",
                       ^(double operand) {return sqrt(operand);}, @"√" ,
                       ^(double operand) {return log10(operand);}, @"log" ,
                       ^(double operand) {return cos(operand);}, @"cos" ,
                       ^(double operand) {return sin(operand);}, @"sin" ,
                       ^(double operand) {return tan(operand);}, @"tan" ,
                       ^(double operand) {return -operand;}, @"±" ,
                       ^(double p1, double p2) { return p1 + p2; }, @"+",
                       ^(double p1, double p2) { return p1 - p2; }, @"-",
                       ^(double p1, double p2) { return p1 * p2; }, @"×",
                       ^(double p1, double p2) { return p1 / p2; }, @"÷",
                       nil];
    }
    return self;
}

- (void) setOperand: (NSString*) operand {
    _result = operand.doubleValue;
}

- (double) pushOperand: (NSString*) operand {
    [_touchHistory addObject:[[TouchEvent alloc] initWithArguments:Save symbol:operand]];
    return [self evaluate];
}

- (void) executeBinaryOperation {
    if(_pendingInfo) {
        if(_pendingInfo.pendingOperation) {
            _result = _pendingInfo.pendingOperation( _pendingInfo.firstOperand, _result);
        }
        _pendingInfo = nil;
    }
}


- (void) _performOperarion: (NSString*) symbol addToHistory:(Boolean)addToHistory {
    NSNumber* operationType = [ _operationTypes objectForKey: symbol];
    if(operationType){
        int opType = [operationType intValue];
        switch(opType) {
            case Constant:
            {
                double(^block)() = [_operations objectForKey:symbol];
                if(block) {
                    _result = block();
                    _pendingInfo = nil;
                }
                if(addToHistory) {
                    [_touchHistory addObject:[[TouchEvent alloc] initWithArguments:opType symbol:symbol]];
                }
                break;
            }
            case UnaryOperation:
            {
                if(_pendingForRestore == false) {
                    [self executeBinaryOperation];
                    double(^block)(double) = [_operations objectForKey:symbol];
                    if(block) {
                        _result = block(_result);
                        _pendingInfo = nil;
                    }
                }
                else {
                    [_pendingOperationsForRestore addObject:[[TouchEvent alloc] initWithArguments:opType symbol:symbol]];
                }
                if(addToHistory) {
                    [_touchHistory addObject:[[TouchEvent alloc] initWithArguments:opType symbol:symbol]];
                }
                break;
            }
            case BinaryOperation:
            {
                if(_pendingForRestore == false) {
                    [self executeBinaryOperation];
                    double(^block)(double, double) = [_operations objectForKey:symbol];
                    if(block) {
                        _pendingInfo = [[PendingInfo alloc] initWithArguments:block firstOperand:_result];
                    }
                }
                else {
                    [_pendingOperationsForRestore addObject:[[TouchEvent alloc] initWithArguments:opType symbol:symbol]];
                }
                if(addToHistory) {
                    [_touchHistory addObject:[[TouchEvent alloc] initWithArguments:opType symbol:symbol]];
                }
                break;
            }
            case Equals:
                if(_pendingForRestore == false) {
                    [self executeBinaryOperation];
                }
                else {
                    [_pendingOperationsForRestore addObject:[[TouchEvent alloc] initWithArguments:opType symbol:symbol]];
                }
                if(addToHistory) {
                    [_touchHistory addObject:[[TouchEvent alloc] initWithArguments:opType symbol:symbol]];
                }
                break;
            case Digital:
                if(addToHistory) {
                    [_touchHistory addObject:[[TouchEvent alloc] initWithArguments:opType symbol:symbol]];
                }
                break;
            case Back:
                [self back];
                break;
            case Restore:
                if(addToHistory) {
                    [_touchHistory addObject:[[TouchEvent alloc] initWithArguments:opType symbol:symbol]];
                }
                if ([_variableValues objectForKey:symbol] == nil) {
                    _pendingForRestore = true;
                    [_pendingOperationsForRestore addObject:[[TouchEvent alloc] initWithArguments:opType symbol:symbol]];
                }
                else {
                    [self evaluate];
                }
                break;
            case Save:
                break;
        }
    }
}

- (void) performOperarion: (NSString*) symbol {
    [self _performOperarion:symbol addToHistory:TRUE];
}


- (NSString*) generateDescription {
    NSMutableString* output = [NSMutableString stringWithFormat:@""];
    for (int i = 0; i < [_touchHistory count]; i++) {
        TouchEvent* event = [_touchHistory objectAtIndex:i];
        if(event) {
            switch(event.operationType) {
                case Constant:
                    if (output.length > 0) {
                        [output appendString:@", "];
                    }
                    [output appendString:event.symbol];
                    break;
                case UnaryOperation:
                    if (output.length > 0) {
                        NSUInteger index = 0;
                        NSRange rangeToComma = [output rangeOfString:@", " options:NSBackwardsSearch];
                        
                        if(rangeToComma.location != NSNotFound) {
                            index = rangeToComma.location;
                        }
                        NSString *preOutput = [output substringToIndex:index];
                        NSString *postOutput = [output substringFromIndex:index];
                        output = [NSMutableString stringWithFormat:@"%@%@(%@)", preOutput, event.symbol, postOutput];
                    }
                    break;
                case BinaryOperation:
                    [output appendString:event.symbol];
                    break;
                case Equals:
                    output = [NSMutableString stringWithFormat:@""];
                    break;
                case Digital:
                    [output appendString:event.symbol];
                    break;
                case Back:
                    break;
                case Save:
                    break;
                case Restore:
                    [output appendString:event.symbol];
                    break;
            }
        }
    }
    return [NSString stringWithString:output];
}


- (bool) isValidInput: (NSString*) input currentDisplay:(NSString*)currentDisplay {
    if(currentDisplay) {
        if([input isEqualToString:@"."]) {
            if([currentDisplay rangeOfString:@"."].location != NSNotFound) {
                return false;
            }
        }
        else if([input isEqualToString:@"0"]) {
            if([currentDisplay rangeOfString:@"0"].location == 0 && [currentDisplay rangeOfString:@"."].location == NSNotFound) {
                return false;
            }
        }
        else {
            NSNumber* operationType = [ _operationTypes objectForKey: input];
            if(operationType && [operationType intValue] == BinaryOperation) {
                NSNumber* lastOperationType = [_operationTypes objectForKey:[_touchHistory lastObject]];
                if(lastOperationType && [lastOperationType intValue] == BinaryOperation) {
                    return false;
                }
            }
        }
    }
    return true;
}

- (void) back {
    if (_touchHistory.count > 0) {
        [_touchHistory removeLastObject];
    }
}

- (double) evaluate {
    if(_pendingForRestore == true && _pendingOperationsForRestore.count > 0) {
        bool allVariableSet = true;
        for(NSUInteger i = 0; i < _pendingOperationsForRestore.count; i++) {
            TouchEvent* event = [_pendingOperationsForRestore objectAtIndex:i];
            switch (event.operationType) {
                case Restore:
                    if ([_variableValues objectForKey:event.symbol] == nil) {
                        allVariableSet = false;
                    }
                    break;
                default:
                    break;
            }
        }
        
        if(allVariableSet) {
            _pendingForRestore = false;
            for(NSUInteger i = 0; i < _pendingOperationsForRestore.count; i++) {
                TouchEvent* event = [_pendingOperationsForRestore objectAtIndex:i];
                switch (event.operationType) {
                    case Restore:
                    {
                        NSString* value = [_variableValues objectForKey:event.symbol];
                        if(value) {
                            _result = [value doubleValue];
                        }
                    }
                        break;
                    default:
                        [self _performOperarion:event.symbol addToHistory:false];
                        break;
                }
            }
            [_pendingOperationsForRestore removeAllObjects];
        }
    }
    
    return _result;
}


- (void) setBrainDescription:(NSString *)brainDescription {
}
- (NSString*)brainDescription {
    NSString* output = [self generateDescription];
    return (output && output.length > 0) ? output : @" ";
}

@end