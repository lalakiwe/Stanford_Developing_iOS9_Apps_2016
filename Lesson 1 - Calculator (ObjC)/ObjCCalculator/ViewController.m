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
@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    _startToType = false;
    _brain = [[CalculatorBrain alloc] init];
}

- (IBAction)touchDigit:(UIButton *)sender {
    if([_brain isValidInput:sender.currentTitle currentDisplay:_display.text] == false) {
        return;
    }
    
    if(_startToType == false) {
        _startToType = true;
        _display.text = sender.currentTitle;
    }
    else {
        _display.text = [_display.text stringByAppendingString: sender.currentTitle];
    }
    
    [_brain updateHistory:sender.currentTitle];
    _historyDisplay.text = _brain.history;
}

- (IBAction)performOperation:(UIButton *)sender {
    if([_brain isValidInput:sender.currentTitle currentDisplay:_display.text] == false) {
        return;
    }
    
    [_brain setOperand:_display.text];
    [_brain performOperarion:sender.currentTitle];
    [_brain updateHistory:sender.currentTitle];
  
    _display.text = @(_brain.result).stringValue;
    
    if(_startToType == true) {
        _startToType = false;
    }
    
    _historyDisplay.text = _brain.history;
}

@end
