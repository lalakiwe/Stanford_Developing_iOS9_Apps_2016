//
//  ViewController.swift
//  SwiftCalculator
//
//  Created by Vince Li on 2016/7/27.
//  Copyright © 2016年 Vince. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    private var startToType = false
    private var brain = CalculatorBrain()
    private var displayValue : Double {
        get {
            return Double(display.text!)!
        }
        set {
            display.text = String(newValue)
        }
    }
    @IBOutlet weak var touchHistory: UILabel!
    
    private var touchHistoryArray = [String]()
    private func updateHistory(newString: String) {
        touchHistoryArray.append(newString)
        if(touchHistoryArray.count > 10) {
            touchHistoryArray.removeAtIndex(0)
        }
        
        touchHistory.text = touchHistoryArray.joinWithSeparator(", ")
    }
    
    private func isValidInput(input: String) -> Bool {
        if let currentDisplay = display.text {
            switch input {
            case ".":
                if currentDisplay.rangeOfString(".") != nil {
                    return false;
                }
            case "0":
                if let rangeToZero = currentDisplay.rangeOfString("0") {
                    if currentDisplay.startIndex.distanceTo(rangeToZero.startIndex) == 0 && currentDisplay.rangeOfString(".") == nil {
                        return false;
                    }
                }
            default:
                break
            }
        }
        return true;
    }
    
    
    @IBAction func operationAction(sender: UIButton) {
        if let input = sender.currentTitle {
            updateHistory(input)
            
            brain.setOperand(displayValue)
            brain.performOperarion(input)
            
            displayValue = brain.result
            if(startToType) {
                startToType = false
            }
        }
    }
    
    @IBOutlet weak var display: UILabel!
    
    @IBAction func touchDigital(sender: UIButton) {
        if let input = sender.currentTitle {
            updateHistory(input)
            
            if(isValidInput(input) == false) {
                return;
            }
            
            if(startToType) {
                display.text = display.text! + input
            }
            else {
                display.text = input
                startToType = true
            }
        }
    }
}

