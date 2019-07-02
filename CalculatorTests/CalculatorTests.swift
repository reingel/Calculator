//
//  CalculatorTests.swift
//  CalculatorTests
//
//  Created by Soonkyu Jeong on 2019/06/30.
//  Copyright © 2019 Soonkyu Jeong. All rights reserved.
//

import XCTest
@testable import Calculator

class CalculatorTests: XCTestCase {

    override func setUp() {
        print("")
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
	
	func testStack() {
		var stack = Stack<Int>()
		
		stack.push(1)
		stack.push(2)
		if let ret = stack.pop() {
			print(ret)
			XCTAssert(ret == 2)
		}
		if let ret = stack.pop() {
			print(ret)
			XCTAssert(ret == 1)
		}
		let ret = stack.pop()
		print(ret)
		XCTAssertNil(ret)
	}
	
	func testQueue() {
		var queue = Queue<Int>()
		
		queue.push(1)
		queue.push(2)
		if let ret = queue.pop() {
			print(ret)
			XCTAssert(ret == 1)
		}
		if let ret = queue.pop() {
			print(ret)
			XCTAssert(ret == 2)
		}
		let ret = queue.pop()
		print(ret)
		XCTAssertNil(ret)
	}
	
	func testUnit() {
		let m = Unit["m"]
		print(m!)
		let km = Unit["km"]
		print(km!)
		let Nm = Unit["Nm"]
		print(Nm)
		XCTAssert(Unit.contains("degC"))
		XCTAssertFalse(Unit.contains("MB"))
		let length = Unit[.length]
		for len in length {
			print(len)
		}
		let fav = Unit.favorite(.length)
		print(fav!)
	}
	
	func testPhysical() {
		let a = PhysicalValue(1, Unit["km"]!)
		let b = PhysicalValue(200, "m")!
		let c = PhysicalValue(1200, .length)
		let d = PhysicalValue(1000*200, "m^2")
		
		XCTAssert(a + b == c)
		XCTAssert(a * b == d)
		XCTAssert(c["km"] == 1.2)
		XCTAssert(c["m"] == 1200.0)
		print(c.inFavoriteUnit)
	}
	
	func testOperator() {
		let a = BinaryOperator["("]
		XCTAssert(a!.priority == 0)
		XCTAssert(BinaryOperator.addition.priority == 1)
	}
	
	func testCalculator() {
		let option = false
		var calculator = Calculator()
		XCTAssert(calculator.evaluate("1+2^9*3+4/5-6^2", verbose: option) == "1501.8")
		print("")
		XCTAssert(calculator.evaluate("1 + 2 ^ 9 * 3 + 4 / 5 - 6 ^ 2", verbose: option) == "1501.8")
		print("")
		XCTAssert(calculator.evaluate("7*(2+3)", verbose: option) == "35.0")
		print("")
		XCTAssert(calculator.evaluate("1e-3km + 200 m *(3 - 1)", in: "km", verbose: true) == "0.401 km")
		print("")
		XCTAssert(calculator.evaluate("0 degC", in: "degF", verbose: true) == "32.0 degF")
		print(calculator.parserError)
		print("")
	}
}
