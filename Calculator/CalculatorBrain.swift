//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by James Boyle on 2/2/16.
//  Copyright © 2016 James Boyle. All rights reserved.
//
import Foundation

class CalculatorBrain
{
    
//Stack of operands and operations
    private var opStack = [Op]()
    
//Dictionary mapping String to type Op
    private var knownOps = [String:Op]()
    
    
/*
Defines Op to be an enumerated type and adopts CustomStringConvertible protocol for debugging

Defines an Operand, UnaryOperation, and BinaryOperation case for the enum Op.
*/
    private enum Op: CustomStringConvertible {
        case Operand(Double)
        case UnaryOperation(String, Double -> Double)
        case BinaryOperation(String, (Double, Double) -> Double)

        var description: String {
            get {
                switch self{
                case .Operand(let operand):
                    return "\(operand)"
                case .UnaryOperation(let symbol, _):
                    return symbol
                case .BinaryOperation(let symbol,_):
                    return symbol
                }
            }
        }
    }
    
    
//Initializes the knownOps dictionary
    init(){
        func learnOp(op: Op){
            knownOps[op.description] = op
        }
       // learnOp(Op.BinaryOperation("x", *))
        knownOps["×"] = Op.BinaryOperation("×", *)
        knownOps["−"] = Op.BinaryOperation("−") { $1 - $0}
        knownOps["+"] = Op.BinaryOperation("+", +)
        knownOps["÷"] = Op.BinaryOperation("÷") { $1 / $0}
        knownOps["√"] = Op.UnaryOperation("√", sqrt)
        knownOps["sin"] = Op.UnaryOperation("sin", sin)
        knownOps["cos"] = Op.UnaryOperation("cos", cos)
        //ALl these can be replaced by learnOp calls
    }
    
    
/*
Parameters: takes stack of Ops [Op]

Description: recursively evaluates the stack per postfix notation, depending upon the operands.
             Function has different cases for unary operations, binary operations, and operands,
             and returns a tuple of Double? and stack of Ops, remainingOps[]

             When there is nothing to evaluate it returns (nil, ops) as a tuple.
*/
    private func evaluate(ops: [Op]) -> (result: Double?, remainingOps: [Op]) {
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
            case .Operand(let operand):
                return (operand, remainingOps)
            case .UnaryOperation(_, let operation):
                let operandEvaluation = evaluate(remainingOps)
                if let operand = operandEvaluation.result {
                    return (operation(operand), operandEvaluation.remainingOps)
                }
            case .BinaryOperation(_, let operation):
                let operandEvaluation = evaluate(remainingOps)
                if let operand = operandEvaluation.result{
                    let operandEvaluation2 = evaluate(operandEvaluation.remainingOps)
                    if let operand2 = operandEvaluation2.result {
                        return (operation(operand, operand2), operandEvaluation2.remainingOps)
                    }
                }
                
            }
            
        }
        return (nil, ops)
    }


//Wrapper function that returns an optional double from evaluate(opStack)
    func evaluate() -> Double? {
        let (result,_) = evaluate(opStack)
        return result
    }
    
    
/*
Parameters: takes an operand (Double)
    
Description: appends the operand into the opStack and returns the value of evaluate()
*/
    func pushOperand(operand: Double) -> Double? {
        opStack.append(Op.Operand(operand))
        return evaluate()
    }
    
    
//Clears the stack and gets called in the viewController when the "C" button is pressed
    func clearStack(){
        opStack.removeAll()
    }
    
    
//Appends an operation to the stack and returns the evaluation of the stack
    func performOperation(symbol: String) -> Double? {
        if let operation = knownOps[symbol] {
            opStack.append(operation)
        }
     //   print(opStack)
        return evaluate()
    }
    
//used for debugging
    func printopStack(){
        print(opStack)
    }
}