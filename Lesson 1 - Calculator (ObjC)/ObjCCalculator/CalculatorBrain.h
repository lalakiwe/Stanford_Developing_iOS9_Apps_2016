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

//void(^block)(void)

@interface CalculatorBrain : NSObject

- (void) setOperand: (NSString*) operand;
- (void) performOperarion: (NSString*) symbol;

@property double result;
@property PendingInfo* pendingInfo;

@end