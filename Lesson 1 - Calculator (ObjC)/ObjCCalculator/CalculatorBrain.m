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
@end

@implementation CalculatorBrain

- (id)init
{
    self = [super init];
    if (self)
    {
        _result = 0.0;
        _pendingInfo = nil;
        
        _operationTypes = [NSDictionary dictionaryWithObjectsAndKeys:
                           [NSNumber numberWithInt:Constant], @"π",
                           [NSNumber numberWithInt:Constant], @"e",
                           [NSNumber numberWithInt:Constant], @"C",
                           [NSNumber numberWithInt:BinaryOperation], @"√" ,
                           [NSNumber numberWithInt:BinaryOperation], @"log" ,
                           [NSNumber numberWithInt:BinaryOperation], @"cos" ,
                           [NSNumber numberWithInt:BinaryOperation], @"sin" ,
                           [NSNumber numberWithInt:BinaryOperation], @"tan" ,
                           [NSNumber numberWithInt:BinaryOperation], @"±" ,
                           [NSNumber numberWithInt:UnaryOperation], @"+",
                           [NSNumber numberWithInt:UnaryOperation], @"-",
                           [NSNumber numberWithInt:UnaryOperation], @"×",
                           [NSNumber numberWithInt:UnaryOperation], @"÷",
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
                }
                break;
            }
            case BinaryOperation:
            {
                double(^block)(double) = [_operations objectForKey:symbol];
                if(block) {
                    _result = block(_result);
                }
                break;
            }
            case UnaryOperation:
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

@end