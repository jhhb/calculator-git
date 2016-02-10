//
//  ViewController.swift
//  Calculator
//
//  Created by James Boyle on 1/28/16.
//  Copyright © 2016 James Boyle. All rights reserved.
//

/*

The following code is working and follows all of the specifications, though I'm 
going to think of how I can make it more modular and so there is as little code as possible.
*/

import UIKit

class ViewController: UIViewController {
    
/*
Defines labels, global vars, Model
*/
    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var historyLabel: UILabel!
    var userIsInTheMiddleOfTypingANumber = false
    
    //used to avoid printing the return key when a user doesn't explicitly hit the return key
    //useful in cases of operators, and pi, which gets automatically pushed onto the stack.
    var printReturnKey = true;
    
    var brain = CalculatorBrain()
    
    
/*
Parameters: sender from "C" UIButton

Description: Functions resets historyLabel.text, clears brain.stack,
             resets calculator to original state
*/
    @IBAction func clearButton(sender: UIButton) {
        display.text = "0"
        historyLabel.text = "History:"
        brain.clearStack()
        userIsInTheMiddleOfTypingANumber = false
    }
    
    
/*
Parameters: sender from any digit UIButton, 0-9 and .

Description: This function changes display.text and the historyLabel text depending
             upon the input.
    
             This function also handles special cases like entering multiple "."s, multiple "0"s,
             and treats entering "π" as a special case.
    
             This function handles different cases if the userIsInTheMiddleOfTypingANumber is true or false.
*/
    @IBAction func digitPressed(sender: UIButton) {
        
        let digit = sender.currentTitle!
        
        if userIsInTheMiddleOfTypingANumber {
//prevents IP addresses
                if digit == "." && display.text!.rangeOfString(".") != nil {
                    display.text = display.text!
                }
//prevents multiple 0s
                else if digit == "0" && display.text! == "0" {
                    display.text = "0"
                }
//gets behavior correct for pi
                else if digit == "π"{
                    printReturnKey = false
                    enter()
                    printReturnKey = false
                    display.text = String(M_PI)
                    enter()
                }
                else{
                    display.text = display.text! + digit
                }
        }
        else{
//gets behavior correct for pi
            switch digit{
                case "π":
                    printReturnKey = false
                    display.text = String(M_PI)
                    enter()
                default:
                    display.text = digit
                    userIsInTheMiddleOfTypingANumber = true
            }
        }
    }
    
    
/*
Parameters: void / None, but gets called when pressing "⏎",
    
Description: This function is called when calling operate and also when
             typing pi. This function pushes the display value onto the stack,
             and evaluates the stack and changes the Label text.

*/
    @IBAction func enter() {
        
        //Prevents multiple "⏎"s being printed
        if display.text! == String(M_PI){
            if printReturnKey{
                historyLabel.text! += " ⏎, "
            }
            else{
                historyLabel.text! += "π, "
            }
        }
        else if printReturnKey {
            historyLabel.text! += display.text! + ", ⏎, "
        }
        else{
            historyLabel.text! += "\(display.text!), "
        }
        userIsInTheMiddleOfTypingANumber = false
        
        if let result = brain.pushOperand(displayValue!){
            displayValue = result
        }
        printReturnKey = true
    }
    
    
/*
Parameters: sender: UIButton (+, -, division, multiplication, sqrt, cos, sin)
    
Description: This function is called when you click an operator button and also
             operates on the operand(s) from the stack with the given operator and
             changes the displayValue with the result.
            
            If there is nothing in the stick, displayValue is 0.
*/
    @IBAction func operate(sender: UIButton) {
                
        if userIsInTheMiddleOfTypingANumber {
            printReturnKey = false
            enter()
        }
        if let operation = sender.currentTitle {
            historyLabel.text! += "\(operation), "
            if let result = brain.performOperation(operation){
                displayValue = result
            }
            else{
              displayValue = 0
            }
        }
    }
    
    
/*
Defines displayValue as a Double; the get method return the string to double of the display.text
    
The set sets the display.text to the newValue
*/
    var displayValue: Double? {
        get {
            return NSNumberFormatter().numberFromString(display.text!)!.doubleValue
        }
        set{
            display.text = "\(newValue)"
        }
    }

}

