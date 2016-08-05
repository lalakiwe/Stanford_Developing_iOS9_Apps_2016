//
//  CalculatorBrain.h
//  ObjCCalculator
//
//  Created by Vince Li on 2016/7/28.
//  Copyright © 2016年 Vince. All rights reserved.
//


#import <Foundation/Foundation.h>


typedef double (^PendingOperation)(double, double);

@interface PendingInfo : NSObject
@property (nonatomic, strong) PendingOperation pendingOperation;
@property (nonatomic) double firstOperand;
- (id)initWithArguments:(PendingOperation)pendingOperation firstOperand:(double)firstOperand;
@end

@interface TouchEvent : NSObject
@property (nonatomic) int operationType;
@property (nonatomic) NSString* symbol;
- (id)initWithArguments:(int)operationType symbol:(NSString*)symbol;
@end


@interface CalculatorBrain : NSObject

- (void) setOperand: (NSString*) operand;
- (void) performOperarion: (NSString*) symbol;
- (bool) isValidInput: (NSString*) input currentDisplay:(NSString*)currentDisplay;
- (double) pushOperand: (NSString*) operand;
- (double) evaluate;

@property double result;
@property NSString* brainDescription;
@property PendingInfo* pendingInfo;
@property NSMutableDictionary* variableValues;

@end