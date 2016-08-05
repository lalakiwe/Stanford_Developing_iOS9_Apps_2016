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
    
    [_brain performOperarion:sender.currentTitle];
    
    if(_startToType == false) {
        _startToType = true;
        _display.text = sender.currentTitle;
    }
    else {
        _display.text = [_display.text stringByAppendingString: sender.currentTitle];
    }
    
    _historyDisplay.text = _brain.brainDescription;
}
- (IBAction)save {
    [_brain pushOperand:@"M"];
    [_brain.variableValues setObject:_display.text forKey:@"M"];
    _display.text = @([_brain evaluate]).stringValue;
}
- (IBAction)restore {
    NSString* text = [_brain.variableValues objectForKey:@"M"];
    if(text) {
        _display.text = text;
    }
    [_brain performOperarion:@"M"];
    
    _historyDisplay.text = _brain.brainDescription;
    _display.text = @(_brain.result).stringValue;
}

- (IBAction)performOperation:(UIButton *)sender {
    if([_brain isValidInput:sender.currentTitle currentDisplay:_display.text] == false) {
        return;
    }
    
    [_brain setOperand:_display.text];
    [_brain performOperarion:sender.currentTitle];
  
    _display.text = @(_brain.result).stringValue;
    _historyDisplay.text = _brain.brainDescription;
    if(_startToType == true) {
        _startToType = false;
    }
}

@end
