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
    func setOperand(operand: Double) {
        accumulator = operand
    }
    func performOperarion(symbol: String) {
        if let operation = operations[symbol] {
            switch operation {
            case .Constant(let value):
                accumulator = value
            case .UnaryOperation(let function):
                accumulator = function(accumulator)
            case .BinaryOperation(let function):
                executePendingBinaryOperation()
                pendingInfo = PendingBinaryOperationInfo(pendingOperation: function, firstOperand: accumulator)
            case .Equals:
                executePendingBinaryOperation()
            }
        }
    }
    var result : Double {
        get {
            return accumulator
        }
    }
}