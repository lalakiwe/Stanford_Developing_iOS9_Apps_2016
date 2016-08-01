//
//  ViewController.m
//  ObjCCalculator
//
//  Created by Vince Li on 2016/7/28.
//  Copyright © 2016年 Vince. All rights reserved.
//

#import "ViewController.h"
#import "CalculatorBrain.h"

@interface ViewController ()

@property bool startToType;
@property NSMutableArray* touchHistoryArray;
@property (weak, nonatomic) IBOutlet UILabel *historyDisplay;
@property (weak, nonatomic) IBOutlet UILabel *display;
@property CalculatorBrain* brain;
- (void) updateHistory: (NSString*) newString;
- (bool) isValidInput: (NSString*) input;

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    _startToType = false;
    _touchHistoryArray = [[NSMutableArray alloc] init];
    _brain = [[CalculatorBrain alloc] init];
}

- (IBAction)touchDigit:(UIButton *)sender {
    [self updateHistory:sender.currentTitle];
    
    if([self isValidInput:sender.currentTitle] == false) {
        return;
    }
    
    if(_startToType == false) {
        _startToType = true;
        _display.text = sender.currentTitle;
    }
    else {
        _display.text = [_display.text stringByAppendingString: sender.currentTitle];
    }
}

- (IBAction)performOperation:(UIButton *)sender {
    [self updateHistory:sender.currentTitle];
    
    [_brain setOperand:_display.text];
    [_brain performOperarion:sender.currentTitle];
  
    _display.text = @(_brain.result).stringValue;
    
    if(_startToType == true) {
        _startToType = false;
    }
}

- (void) updateHistory: (NSString*) newString {
    [_touchHistoryArray addObject:newString];
    if(_touchHistoryArray.count > 10) {
        [_touchHistoryArray removeObjectAtIndex:0];
    }
    _historyDisplay.text = [_touchHistoryArray componentsJoinedByString:@", "];
}

- (bool) isValidInput: (NSString*) input {
    NSString * currentDisplay = _display.text;
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
    }
    return true;
}

@end
