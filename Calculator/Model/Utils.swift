//
//  Utils.swift
//  JCalc
//
//  Created by Soonkyu Jeong on 2019/06/25.
//  Copyright © 2019 Soonkyu Jeong. All rights reserved.
//

import Foundation

typealias StringRange = Range<Int>

extension StringRange {
	init(_ range: NSRange) {
		self = range.location ..< (range.location + range.length)
	}
	
	var width: Int {
		self.upperBound - self.lowerBound
	}
	
	static func +(lhs: Range, rhs: Int) -> StringRange {
		return (lhs.lowerBound + rhs) ..< (lhs.upperBound + rhs)
	}
	
	static func -(lhs: Range, rhs: Int) -> StringRange {
		return (lhs.lowerBound - rhs) ..< (lhs.upperBound - rhs)
	}
}

extension String {
	func trim() -> String {
		return self.trimmingCharacters(in: CharacterSet.whitespaces)
	}
	subscript(_ range: StringRange) -> String {
		let startIndex = self.index(self.startIndex, offsetBy: range.lowerBound)
		let endIndex = self.index(self.startIndex, offsetBy: range.upperBound)
		return String(self[startIndex..<endIndex])
	}
}
