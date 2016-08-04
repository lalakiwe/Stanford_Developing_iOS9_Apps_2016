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
    private var displayValue : Double? {
        get {
            if let value = display.text {
                return Double(value)
            }
            return nil
        }
        set {
            if let value = newValue {
                display.text = String(value)
            }
        }
    }
    @IBOutlet weak var touchHistory: UILabel!
    
    @IBAction func operationAction(sender: UIButton) {
        if let input = sender.currentTitle {
            if(brain.isValidInput(input, currentDisplay: display.text!) == false) {
                return;
            }
            
            brain.setOperand(displayValue)
            brain.performOperarion(input)
            
            displayValue = brain.result
            touchHistory.text = brain.description
            if(startToType) {
                startToType = false
            }
        }
    }
    
    @IBOutlet weak var display: UILabel!
    
    @IBAction func touchDigital(sender: UIButton) {
        if let input = sender.currentTitle {
            if(brain.isValidInput(input, currentDisplay: display.text!) == false) {
                return;
            }
            
            brain.performOperarion(input)
            
            if(startToType) {
                display.text = display.text! + input
            }
            else {
                display.text = input
                startToType = true
            }
            touchHistory.text = brain.description
        }
    }
    
    @IBAction func save() {
        brain.pushOperand("M")
        brain.variableValues["M"] = displayValue
        
        if let value = brain.evaluate() {
            displayValue = value
        }
    }
    @IBAction func restore() {
        displayValue = brain.variableValues["M"]
        brain.performOperarion("M")

        touchHistory.text = brain.description
        displayValue = brain.result
    }
}

