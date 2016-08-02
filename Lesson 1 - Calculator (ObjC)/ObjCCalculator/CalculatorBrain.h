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

@interface CalculatorBrain : NSObject

- (void) setOperand: (NSString*) operand;
- (void) performOperarion: (NSString*) symbol;
- (void) updateHistory: (NSString*) newString;
- (bool) isValidInput: (NSString*) input currentDisplay:(NSString*)currentDisplay;

@property double result;
@property NSString* history;
@property PendingInfo* pendingInfo;

@end