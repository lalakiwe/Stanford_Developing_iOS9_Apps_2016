//
//  CalculatorBrain.swift
//  SwiftCalculator
//
//  Created by Vince Li on 2016/7/27.
//  Copyright © 2016年 Vince. All rights reserved.
//

import Foundation


class CalculatorBrain {
    
    init () {
        self.variableValues = Dictionary<String, Double>()
    }
    private enum Operation {
        case Constant(Double)
        case UnaryOperation(Double -> Double)
        case BinaryOperation((Double, Double) -> Double)
        case Equals
        case Digital(String)
        case Back
        case Save
        case Restore
    }
    
    private var operations : Dictionary<String,Operation> = [
        "1" : Operation.Digital("1"),
        "2" : Operation.Digital("2"),
        "3" : Operation.Digital("3"),
        "4" : Operation.Digital("4"),
        "5" : Operation.Digital("5"),
        "6" : Operation.Digital("6"),
        "7" : Operation.Digital("7"),
        "8" : Operation.Digital("8"),
        "9" : Operation.Digital("9"),
        "0" : Operation.Digital("0"),
        "." : Operation.Digital("."),
        "π" : Operation.Constant(M_PI),
        "e" : Operation.Constant(M_E),
        "C" : Operation.Constant(0),
        "√" : Operation.UnaryOperation(sqrt),
        "log" : Operation.UnaryOperation(log10),
        "cos" : Operation.UnaryOperation(cos),
        "sin" : Operation.UnaryOperation(sin),
        "tan" : Operation.UnaryOperation(tan),
        "±" : Operation.UnaryOperation({ -$0 }),
        "+" : Operation.BinaryOperation({ $0 + $1 }),
        "-" : Operation.BinaryOperation({ $0 - $1 }),
        "×" : Operation.BinaryOperation({ $0 * $1 }),
        "÷" : Operation.BinaryOperation({ $0 / $1 }),
        "=" : Operation.Equals,
        "⬅︎": Operation.Back,
        "M": Operation.Restore,
        ]
    
    private struct PendingBinaryOperationInfo {
        var pendingOperation : (Double, Double) -> Double
        var firstOperand : Double
    }
    private var pendingInfo : PendingBinaryOperationInfo?
    
    private func executePendingBinaryOperation() {
        if pendingInfo != nil {
            accumulator = pendingInfo!.pendingOperation(pendingInfo!.firstOperand, accumulator)
            pendingInfo = nil
        }
    }
    
    private var accumulator = 0.0
    private var touchHistories = [(symbol:String, operation:Operation)]()
    private var pendingForRestore = false
    private var pendingOperationsForRestore = [(symbol:String, operation:Operation)]()
    
    func setOperand(operand: Double?) {
        if let op = operand {
            accumulator = op
        }
    }
    
    func performOperarion(symbol: String) {
        _performOperarion(symbol, addToHistory:true)
    }
    
    private func _performOperarion(symbol: String, addToHistory:Bool) {
        if let operation = operations[symbol] {
            switch operation {
            case .Constant(let value):
                accumulator = value
                pendingInfo = nil
                if(addToHistory) {
                    touchHistories.append( (symbol, operation) )
                }
            case .UnaryOperation(let function):
                if pendingForRestore == false {
                    executePendingBinaryOperation()
                    accumulator = function(accumulator)
                    pendingInfo = nil
                }
                else {
                    pendingOperationsForRestore.append((symbol, operation))
                }
                if(addToHistory) {
                    touchHistories.append( (symbol, operation) )
                }
            case .BinaryOperation(let function):
                if pendingForRestore == false {
                    executePendingBinaryOperation()
                    pendingInfo = PendingBinaryOperationInfo(pendingOperation: function, firstOperand: accumulator)
                }
                else {
                    pendingOperationsForRestore.append((symbol, operation))
                }
                if(addToHistory) {
                    touchHistories.append( (symbol, operation) )
                }
            case .Equals:
                if pendingForRestore == false {
                    executePendingBinaryOperation()
                }
                else {
                    pendingOperationsForRestore.append((symbol, operation))
                }
                if(addToHistory) {
                    touchHistories.append( (symbol, operation) )
                }
            case .Digital:
                if(addToHistory) {
                    touchHistories.append( (symbol, operation) )
                }
            case .Back:
                back()
            case .Restore:
                if(addToHistory) {
                    touchHistories.append( (symbol, operation) )
                }
                if variableValues[symbol] == nil {
                    pendingForRestore = true
                    pendingOperationsForRestore.append((symbol, operation))
                }
                else {
                    evaluate()
                }
            case .Save:
                break
            }
        }
    }
    
    private func generateDescription() -> String {
        var output:String = ""
        for (newString, element) in touchHistories {
            switch element {
            case .Constant:
                if !output.isEmpty {
                    output += ", "
                }
                output += newString
            case .UnaryOperation:
                if !output.isEmpty {
                    var index = 0
                    if let rangeToComma = output.rangeOfString(", ", options: NSStringCompareOptions.BackwardsSearch) {
                        index = output.startIndex.distanceTo(rangeToComma.endIndex)
                    }
                    let preOutput = output.substringToIndex(output.startIndex.advancedBy(index))
                    let postOutput = output.substringFromIndex(output.startIndex.advancedBy(index))
                    output = preOutput + String(format: "%@(%@)", newString, postOutput)
                }
            case .BinaryOperation:
                output += newString
            case .Equals:
                output = ""
            case .Digital(let value):
                output += value
            case .Back:
                break
            case .Restore:
                output += newString
            case .Save:
                break
            }
        }
        return output
    }
    
    private func back() {
        if touchHistories.isEmpty == false {
            touchHistories.removeLast()
        }
    }
    
    func isValidInput(input: String, currentDisplay:String) -> Bool {
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
            if let operation = operations[input] {
                switch operation {
                case .BinaryOperation:
                    if let lastTouch = touchHistories.last {
                        switch lastTouch.1 {
                        case .BinaryOperation:
                            return false
                        default:
                            break
                        }
                    }
                    break
                default:
                    break
                }
            }
            break
        }
        return true;
    }
    var result : Double {
        get {
            return accumulator
        }
    }
    var description : String {
        get {
            let output = generateDescription()
            return (output == "") ? " " : output
        }
    }
    
    func evaluate() -> Double? {
        if pendingForRestore == true && pendingOperationsForRestore.isEmpty == false {
            var allVariableSet = true
            for (symbol, operation) in pendingOperationsForRestore {
                switch operation {
                case .Restore:
                    if variableValues[symbol] == nil {
                        allVariableSet = false
                    }
                default:
                    break
                }
            }
            
            if allVariableSet == true {
                pendingForRestore = false
                
                for (symbol, operation) in pendingOperationsForRestore {
                    switch operation {
                    case .Restore:
                        accumulator = variableValues[symbol]!
                        break
                    default:
                        _performOperarion(symbol, addToHistory: false)
                        break
                    }
                }
                pendingOperationsForRestore.removeAll()
            }
        }
        
        
        return accumulator
    }
    func pushOperand(symbol: String) -> Double? {
        variableValues[symbol] = nil
        touchHistories.append( (symbol, Operation.Save) )
        return evaluate()
    }
    var variableValues: Dictionary<String,Double>
    
}