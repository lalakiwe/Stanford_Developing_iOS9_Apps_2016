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


enum OperationTypes{
    Constant = 0,
    UnaryOperation,
    BinaryOperation,
    Equals
};

@interface CalculatorBrain ()
- (void) executeBinaryOperation;
@property NSDictionary* operationTypes;
@property NSDictionary* operations;
@property NSMutableArray* touchHistoryArray;
@end

@implementation CalculatorBrain

- (id)init
{
    self = [super init];
    if (self)
    {
        _result = 0.0;
        _history = nil;
        _pendingInfo = nil;
        _touchHistoryArray = [[NSMutableArray alloc] init];
        
        _operationTypes = [NSDictionary dictionaryWithObjectsAndKeys:
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

- (void) executeBinaryOperation {
    if(_pendingInfo) {
        if(_pendingInfo.pendingOperation) {
            _result = _pendingInfo.pendingOperation( _pendingInfo.firstOperand, _result);
        }
        _pendingInfo = nil;
    }
}

- (void) performOperarion: (NSString*) symbol {
    NSNumber* operationType = [ _operationTypes objectForKey: symbol];
    if(operationType){
        switch([operationType intValue]) {
            case Constant:
            {
                double(^block)() = [_operations objectForKey:symbol];
                if(block) {
                    _result = block();
                    _pendingInfo = nil;
                }
                break;
            }
            case UnaryOperation:
            {
                double(^block)(double) = [_operations objectForKey:symbol];
                if(block) {
                    _result = block(_result);
                    _pendingInfo = nil;
                }
                break;
            }
            case BinaryOperation:
            {
                [self executeBinaryOperation];
                double(^block)(double, double) = [_operations objectForKey:symbol];
                if(block) {
                    _pendingInfo = [[PendingInfo alloc] initWithArguments:block firstOperand:_result];
                }
                break;
            }
            case Equals:
                [self executeBinaryOperation];
                break;
        }
    }
}


- (void) updateHistory: (NSString*) newString {
    if([[_touchHistoryArray firstObject] isEqualToString:@"C"]) {
        [_touchHistoryArray removeAllObjects];
    }
    
    NSNumber* operationType = [ _operationTypes objectForKey: newString];
    if(operationType){
        switch([operationType intValue]) {
            case Constant:
                [_touchHistoryArray removeAllObjects];
                [_touchHistoryArray addObject:newString];
                break;
            case UnaryOperation:
                [_touchHistoryArray insertObject:@"(" atIndex:0];
                [_touchHistoryArray insertObject:newString atIndex:0];
                [_touchHistoryArray addObject:@")"];
                break;
            case BinaryOperation:
                [_touchHistoryArray addObject:newString];
                break;
            case Equals:
                [_touchHistoryArray removeAllObjects];
                [_touchHistoryArray addObject:@(_result).stringValue];
                break;
        }
    }
    else {
        [_touchHistoryArray addObject:newString];
        if(_touchHistoryArray.count > 10)
            [_touchHistoryArray removeObjectAtIndex:0];
    }
    _history = [_touchHistoryArray componentsJoinedByString:@""];
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
                NSNumber* lastOperationType = [_operationTypes objectForKey:[_touchHistoryArray lastObject]];
                if(lastOperationType && [lastOperationType intValue] == BinaryOperation) {
                    return false;
                }
            }
        }
    }
    return true;
}

@end