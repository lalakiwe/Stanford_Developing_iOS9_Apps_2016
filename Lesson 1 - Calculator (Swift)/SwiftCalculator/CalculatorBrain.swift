//
//  CalculatorBrain.swift
//  SwiftCalculator
//
//  Created by Vince Li on 2016/7/27.
//  Copyright © 2016年 Vince. All rights reserved.
//

import Foundation


class CalculatorBrain {
    
    private enum Operation {
        case Constant(Double)
        case UnaryOperation(Double -> Double)
        case BinaryOperation((Double, Double) -> Double)
        case Equals
    }
    
    private var operations : Dictionary<String,Operation> = [
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
        "=" : Operation.Equals
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
    private var touchHistoryArray = [String]()
    
    func setOperand(operand: Double) {
        accumulator = operand
    }
    func performOperarion(symbol: String) {
        if let operation = operations[symbol] {
            switch operation {
            case .Constant(let value):
                accumulator = value
                pendingInfo = nil
            case .UnaryOperation(let function):
                accumulator = function(accumulator)
                pendingInfo = nil
            case .BinaryOperation(let function):
                executePendingBinaryOperation()
                pendingInfo = PendingBinaryOperationInfo(pendingOperation: function, firstOperand: accumulator)
            case .Equals:
                executePendingBinaryOperation()
            }
        }
    }
    func updateHistory(newString: String) {
        if touchHistoryArray.first == "C"{
            touchHistoryArray.removeAll()
        }
            
        if let operation = operations[newString] {
            switch operation {
            case .Constant:
                touchHistoryArray.removeAll()
                touchHistoryArray.append(newString)
            case .UnaryOperation:
                touchHistoryArray.insert("(", atIndex: 0)
                touchHistoryArray.insert(newString, atIndex: 0)
                touchHistoryArray.append(")")
            case .BinaryOperation:
                touchHistoryArray.append(newString)
            case .Equals:
                touchHistoryArray.removeAll()
                touchHistoryArray.append(String(accumulator))
            }
        }
        else {
            touchHistoryArray.append(newString)
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
                    if let lastTouch = operations[touchHistoryArray.last!] {
                        switch lastTouch {
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
    var history : String {
        get {
            return touchHistoryArray.joinWithSeparator("")
        }
    }
}