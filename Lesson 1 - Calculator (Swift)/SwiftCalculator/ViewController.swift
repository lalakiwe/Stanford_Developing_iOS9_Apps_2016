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
    
    @IBAction func operationAction(sender: UIButton) {
        updateHistory(sender.currentTitle!)
        
        if let mathematicalSymbol = sender.currentTitle {
            brain.setOperand(displayValue)
            brain.performOperarion(mathematicalSymbol)
        }
        displayValue = brain.result
        if(startToType) {
            startToType = false
        }
    }
    
    @IBOutlet weak var display: UILabel!
    
    @IBAction func touchDigital(sender: UIButton) {
        updateHistory(sender.currentTitle!)
        
        if let currentDisplay = display.text {
            switch sender.currentTitle! {
            case ".":
                if currentDisplay.rangeOfString(".") != nil {
                    return
                }
            case "0":
                if let range = currentDisplay.rangeOfString("0") {
                    if currentDisplay.startIndex.distanceTo(range.startIndex) == 0 {
                        return
                    }
                }
            default:
                break
            }
        }
        
        if(startToType) {
            display.text = display.text! + sender.currentTitle!
        }
        else {
            display.text = sender.currentTitle!
            startToType = true
        }
        
    }
}

