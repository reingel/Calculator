//
//  Calculator.swift
//  JCalc
//
//  Created by Soonkyu Jeong on 2019/06/30.
//  Copyright © 2019 Soonkyu Jeong. All rights reserved.
//

import Foundation

typealias Location = Int
typealias Whitespace = String
typealias NumericValue = Double

enum CalcError {
    case noError
    case syntaxError(Location)
	case rightParenthesisWithoutLeftParenthesis(Location)
    case divisionByZero(Location)
	case stackIsEmptyWhilePoppingRightOperand(Location)
	case stackIsEmptyWhilePoppingLeftOperand(Location)
	case stackIsEmptyWhilePoppingOperator(Location)
	case unknownOperator(Location)
	case unknownObject(Location)
	
	var description: String {
		switch self {
		case .noError:
			return "No error"
		case .syntaxError(let loc):
			return "Syntax error at " + String(loc)
		case .rightParenthesisWithoutLeftParenthesis(let loc):
			return "Right parenthesis without left parenthesis at " + String(loc)
		case .divisionByZero(let loc):
			return "Division by zero at " + String(loc)
		case .stackIsEmptyWhilePoppingRightOperand(let loc):
			return "Stack is empty while popping right operand at " + String(loc)
		case .stackIsEmptyWhilePoppingLeftOperand(let loc):
			return "Stack is empty while popping left operand at " + String(loc)
		case .stackIsEmptyWhilePoppingOperator(let loc):
			return "Stack is empty while popping operator at " + String(loc)
		case .unknownOperator(let loc):
			return "Unknown operator at " + String(loc)
		case .unknownObject(let loc):
			return "Unknown object at " + String(loc)
		}
	}
}

enum MathObject {
    case whitespace(Whitespace, Location)
    case numeric(NumericValue, Location)
    case physical(PhysicalValue, Location)
    case unit(Unit, Location)
    case binaryOperator(BinaryOperator, Location)
    //    case function(Function, Location)
    //    case variable(Variable, Location)
    
    var isNotWhitespace: Bool {
        switch self {
        case .whitespace: return false
        default: return true
        }
    }
    var isNotNumeric: Bool {
        switch self {
        case .numeric: return false
        default: return true
        }
    }
    var isNotPhysical: Bool {
        switch self {
        case .physical: return false
        default: return true
        }
    }
    var isNotUnit: Bool {
        switch self {
        case .unit: return false
        default: return true
        }
    }
    var isNotBinaryOperator: Bool {
        switch self {
        case .binaryOperator: return false
        default: return true
        }
    }
    var isBinaryOperator: Bool { !isNotBinaryOperator }
    
    var description: String {
        switch self {
        case let .whitespace(s, loc):
            return s + " " + String(loc)
        case let .numeric(value, loc):
            return String(value) + " " + String(loc)
        case let .binaryOperator(oper, loc):
            return BinaryOperator[oper]! + " " + String(loc)
        default:
            return ""
        }
    }
}

struct Calculator {
    var objects = Queue<MathObject>()
    var locations = Queue<Location>()
    
    var stack = Stack<MathObject>()
    var queue = Queue<MathObject>()
    
    var parserError: CalcError = .noError
    
    // placed outside of parse() to speed up parsing
    let whitespaceRegex = try? NSRegularExpression(pattern: #"^[ \t]"#)
    let numericRegex = try? NSRegularExpression(pattern: #"^[+-]?(\d+(\.\d+)?|\.\d+)([eE][+-]?\d+)?"#)
    let unitRegex = try? NSRegularExpression(pattern: #"^[a-zA-Z]+(([*/][a-zA-Z]+)|(\^-?\d+))*"#)
    let operatorRegex = try? NSRegularExpression(pattern: #"^[\(\)^\*\/+\-]"#)
    let functionRegex = try? NSRegularExpression(pattern: #"^[a-zA-Z_][a-zA-Z0-9_]*\("#)
    let variableRegex = try? NSRegularExpression(pattern: #"^[a-zA-Z_][a-zA-Z0-9_]*"#)
    
	mutating func parse(_ string: String, verbose: Bool = false) -> Bool {
		if verbose { print("\nparsing:") }
        var objectRange: StringRange = 0..<0
        var remainRange: StringRange = 0..<string.count
        var object: MathObject?
        var previous: MathObject = MathObject.whitespace(" ", 0)
        while !remainRange.isEmpty {
            object = nil
            if previous.isNotWhitespace {
                if let match = whitespaceRegex?.firstMatch(in: string, range: NSRange(remainRange)) {
                    objectRange = StringRange(match.range)
                    let value = string[objectRange]
                    object = MathObject.whitespace(value, objectRange.lowerBound)
                }
            }
            if previous.isNotNumeric && object == nil {
                if let match = numericRegex?.firstMatch(in: string, range: NSRange(remainRange)) {
                    objectRange = StringRange(match.range)
                    let value = NumericValue(string[objectRange])!
                    object = MathObject.numeric(value, objectRange.lowerBound)
                }
            }
			if previous.isNotUnit && object == nil {
				if let match = unitRegex?.firstMatch(in: string, range: NSRange(remainRange)) {
					objectRange = StringRange(match.range)
					let value = Unit[string[objectRange]]!
					object = MathObject.unit(value, objectRange.lowerBound)
				}
			}
            if object == nil {
                if let match = operatorRegex?.firstMatch(in: string, range: NSRange(remainRange)) {
                    objectRange = StringRange(match.range)
                    let value = BinaryOperator[string[objectRange]]!
                    object = MathObject.binaryOperator(value, objectRange.lowerBound)
                }
            }
            
            if object != nil {
				if verbose { print(object!) }
                objects.push(object!)
                locations.push(objectRange.lowerBound)
                remainRange.removeFirst(objectRange.width)
                previous = object!
            } else {
                parserError = .syntaxError(objectRange.upperBound)
                return false
            }
        }
        return true
    }
    
	mutating func infixToPostfix(verbose: Bool = false) -> Bool {
		if verbose { print("\nconverting infix to postfix:") }
		var stackNumeric = Stack<MathObject>()
		convertLoop: while let object = objects.pop() {
            switch object {
            case .whitespace, .physical:
                break
			case .numeric:
				stackNumeric.push(object)
			case let .unit(unit, loc):
				if let numericObject = stackNumeric.pop() {
					switch numericObject {
					case let .numeric(numericValue, loc):
						let newObject = MathObject.physical(numericValue * unit, loc)
						queue.push(newObject)
					default:
						parserError = .unknownObject(loc)
						return false
					}
				} else {
					if !queue.isEmpty {
						let newObject = MathObject.physical(1.0 * unit, loc)
						queue.push(newObject)
					} else {
						parserError = .syntaxError(loc)
						return false
					}
				}
            case let .binaryOperator(parsedOperator, loc):
				if !stackNumeric.isEmpty {
					queue.push(stackNumeric.pop()!)
				}
				switch parsedOperator {
				case .leftParenthesis:
					stack.push(object)
				case .rightParenthesis:
					while let poppedObject = stack.pop() {
						switch poppedObject {
						case let .binaryOperator(poppedOperator, _):
							if poppedOperator == .leftParenthesis {
								continue convertLoop
							} else {
								queue.push(poppedObject)
							}
						default:
							queue.push(poppedObject)
						}
					}
					parserError = .rightParenthesisWithoutLeftParenthesis(loc)
					return false // right parenthesis without left parenthesis
				default:
					let parsedPriority = parsedOperator.priority
					compareLoop: while true {
						if let poppedObject = stack.pop() {
							switch poppedObject {
							case let .binaryOperator(poppedOperator, _):
								let poppedPriority = poppedOperator.priority
								if poppedPriority >= parsedPriority {
									queue.push(poppedObject)
								} else {
									stack.push(poppedObject)
									stack.push(object)
									break compareLoop
								}
							default:
								break compareLoop
							}
						} else {
							stack.push(object)
							break compareLoop
						}
					}
				}
            }
        }
		if let numericObject = stackNumeric.pop() {
			queue.push(numericObject)
		}
        // pop every operators in stack
        while let poppedObject = stack.pop() {
            queue.push(poppedObject)
        }
        
        return true
    }
    
	mutating func evaluate(_ string: String, verbose: Bool = false) -> String {
        guard parse(string, verbose: verbose) else {
			return parserError.description
        }
        guard infixToPostfix(verbose: verbose) else {
			return parserError.description
        }
		
		if verbose { print("\nevaluating:") }
        calcLoop: while let poppedObject = queue.pop() {
			if verbose { print(poppedObject) }
            switch poppedObject {
            case .whitespace:
                break
            case .numeric, .physical:
                stack.push(poppedObject)
            case let .unit(unit, loc):
				if let numericObject = stack.pop() {
					switch numericObject {
					case let .numeric(value, loc):
						stack.push(MathObject.physical(value * unit, loc))
					default:
						break
					}
				} else {
					stack.push(MathObject.physical(1.0 * unit, loc))
				}
            case let .binaryOperator(mathOperator, loc):
				let rightOperand = stack.pop()
				if rightOperand == nil {
					parserError = .stackIsEmptyWhilePoppingRightOperand(loc)
					return parserError.description
				}
				let leftOperand = stack.pop()
				if leftOperand == nil {
					parserError = .stackIsEmptyWhilePoppingLeftOperand(loc)
					return parserError.description
				}
				
				switch (rightOperand, leftOperand) {
				case let (.numeric(rhs, _), .numeric(lhs, _)):
					switch mathOperator {
					case .power:
						let value = pow(lhs, rhs)
						stack.push(MathObject.numeric(value, loc))
					case .multiplication:
						let value = lhs * rhs
						stack.push(MathObject.numeric(value, loc))
					case .division:
						let value = lhs / rhs
						stack.push(MathObject.numeric(value, loc))
					case .addition:
						let value = lhs + rhs
						stack.push(MathObject.numeric(value, loc))
					case .subtraction:
						let value = lhs - rhs
						stack.push(MathObject.numeric(value, loc))
					default:
						parserError = .unknownOperator(loc)
						return parserError.description
					}
				case let (.numeric(rhs, _), .physical(lhs, _)):
					switch mathOperator {
					case .power:
						let value = PhysicalValue(0.0, .unitless)//pow(lhs, rhs)
						stack.push(MathObject.physical(value, loc))
					case .multiplication:
						let value = lhs * rhs
						stack.push(MathObject.physical(value, loc))
					case .division:
						let value = lhs / rhs
						stack.push(MathObject.physical(value, loc))
					case .addition:
						let value = lhs + rhs
						stack.push(MathObject.numeric(value!, loc)) // need to check error
					case .subtraction:
						let value = lhs - rhs
						stack.push(MathObject.numeric(value!, loc)) // need to check error
					default:
						parserError = .unknownOperator(loc)
						return parserError.description
					}
				case let (.physical(rhs, _), .numeric(lhs, _)):
					switch mathOperator {
					case .power:
						let value = PhysicalValue(0.0, .unitless)//pow(lhs, rhs)
						stack.push(MathObject.physical(value, loc))
					case .multiplication:
						let value = lhs * rhs
						stack.push(MathObject.physical(value, loc))
					case .division:
						let value = lhs / rhs
						stack.push(MathObject.physical(value, loc))
					case .addition:
						let value = lhs + rhs
						stack.push(MathObject.numeric(value!, loc)) // need to check error
					case .subtraction:
						let value = lhs - rhs
						stack.push(MathObject.numeric(value!, loc)) // need to check error
					default:
						parserError = .unknownOperator(loc)
						return parserError.description
					}
				case let (.physical(rhs, _), .physical(lhs, _)):
					switch mathOperator {
					case .power:
						let value = PhysicalValue(0.0, .unitless)//pow(lhs, rhs)
						stack.push(MathObject.physical(value, loc))
					case .multiplication:
						let value = lhs * rhs
						stack.push(MathObject.physical(value!, loc))
					case .division:
						let value = lhs / rhs
						stack.push(MathObject.physical(value!, loc))
					case .addition:
						let value = lhs + rhs
						stack.push(MathObject.physical(value!, loc))
					case .subtraction:
						let value = lhs - rhs
						stack.push(MathObject.physical(value!, loc))
					default:
						parserError = .unknownOperator(loc)
						return parserError.description
					}
				default:
					parserError = .unknownObject(loc)
					return parserError.description
				}
            }
        }
		
        switch stack.pop()! {
        case let .numeric(value, _):
            return String(value)
		case let .physical(value, _):
			return String(value.value)// + Unit[value.dim]
        default:
			parserError = .unknownObject(0)
			return parserError.description
        }
    }
}
