//
//  MathOperator.swift
//  JCalc
//
//  Created by Soonkyu Jeong on 2019/06/26.
//  Copyright © 2019 Soonkyu Jeong. All rights reserved.
//

enum BinaryOperator: Comparable {
    case leftParenthesis, rightParenthesis
    case power
    case multiplication, division
    case addition, subtraction
	
	var priority: Int {
		switch self {
		case .leftParenthesis, .rightParenthesis:
			return 0
		case .addition, .subtraction:
			return 1
		case .multiplication, .division:
			return 2
		case .power:
			return 3
		}
	}
	
	static func < (lhs: BinaryOperator, rhs: BinaryOperator) -> Bool {
		return lhs.priority < rhs.priority
	}
	
	static func == (lhs: BinaryOperator, rhs: BinaryOperator) -> Bool {
		return lhs.priority == rhs.priority
	}
	
	static let operators: [String: BinaryOperator] = [
		"(": .leftParenthesis,
		")": .rightParenthesis,
		"^": .power,
		"*": .multiplication,
		"/": .division,
		"+": .addition,
		"-": .subtraction
	]
	
	static func contains(_ string: String) -> Bool { operators[string] != nil }
	static subscript (_ string: String) -> BinaryOperator? { operators[string] }
	static subscript (_ oper: BinaryOperator) -> String? {
		for (key, value) in operators {
			if oper == value {
				return key
			}
		}
		return nil
	}
}
