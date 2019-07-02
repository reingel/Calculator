//
//  PhysicalValue.swift
//  JCalc
//
//  Created by Soonkyu Jeong on 2019/06/23.
//  Copyright © 2019 Soonkyu Jeong. All rights reserved.
//

struct PhysicalValue: Equatable {
	var value: NumericValue
	let dim: Dimension
	
	init(_ value: NumericValue, _ dim: Dimension) {
		self.value = value
		self.dim = dim
	}
	init(_ value: NumericValue, _ unit: Unit) {
		self.value = value * unit.factor + unit.offset
		self.dim = unit.dim
	}
	init?(_ value: NumericValue, _ unitString: String) {
		if let unit = Unit[unitString] {
			self.init(value, unit)
		} else {
			return nil
		}
	}
	
	subscript(_ unit: Unit) -> NumericValue? {
		if self.dim == unit.dim {
			return (value - unit.offset) / unit.factor
		} else {
			return nil
		}
	}
	subscript(_ unitString: String) -> NumericValue? {
		if let unit = Unit[unitString] {
			return self[unit]
		} else {
			return nil
		}
	}
	
	var inFavoriteUnit: String {
		if let (str, unit) = Unit.favorite(self.dim) {
			let value = self[unit]!
			return String(value) + " " + str
		} else {
			return ""
		}
	}
	
	static func ==(lhs: PhysicalValue, rhs: PhysicalValue) -> Bool {
		return lhs.value == rhs.value && lhs.dim == rhs.dim
	}
	
	static func +(lhs: PhysicalValue, rhs: PhysicalValue) -> PhysicalValue? {
		if lhs.dim == rhs.dim {
			return PhysicalValue(lhs.value + rhs.value, lhs.dim)
		}
		return nil
	}
	static func +(lhs: PhysicalValue, rhs: NumericValue) -> NumericValue? {
		if lhs.dim == .unitless {
			return NumericValue(lhs.value + rhs)
		}
		return nil
	}
	static func +(lhs: NumericValue, rhs: PhysicalValue) -> NumericValue? {
		if rhs.dim == .unitless {
			return NumericValue(lhs + rhs.value)
		}
		return nil
	}
	
	static func -(lhs: PhysicalValue, rhs: PhysicalValue) -> PhysicalValue? {
		if lhs.dim == rhs.dim {
			return PhysicalValue(lhs.value - rhs.value, lhs.dim)
		}
		return nil
	}
	static func -(lhs: PhysicalValue, rhs: NumericValue) -> NumericValue? {
		if lhs.dim == .unitless {
			return NumericValue(lhs.value - rhs)
		}
		return nil
	}
	static func -(lhs: NumericValue, rhs: PhysicalValue) -> NumericValue? {
		if rhs.dim == .unitless {
			return NumericValue(lhs - rhs.value)
		}
		return nil
	}
	
	static func *(lhs: PhysicalValue, rhs: PhysicalValue) -> PhysicalValue? {
		if let expLeft = Dimension[lhs.dim], let expRight = Dimension[rhs.dim] {
			let exponent = expLeft + expRight
			if let dim = Dimension[exponent] {
				return PhysicalValue(lhs.value * rhs.value, dim)
			}
		}
		return nil
	}
	static func *(lhs: PhysicalValue, rhs: NumericValue) -> PhysicalValue {
		return PhysicalValue(lhs.value * rhs, lhs.dim)
	}
	static func *(lhs: NumericValue, rhs: PhysicalValue) -> PhysicalValue {
		return PhysicalValue(lhs * rhs.value, rhs.dim)
	}
	
	static func /(lhs: PhysicalValue, rhs: PhysicalValue) -> PhysicalValue? {
		// TODO: division by zero
		if let expLeft = Dimension[lhs.dim], let expRight = Dimension[rhs.dim] {
			let exponent = expLeft - expRight
			if let dim = Dimension[exponent] {
				return PhysicalValue(lhs.value / rhs.value, dim)
			}
		}
		return nil
	}
	static func /(lhs: PhysicalValue, rhs: NumericValue) -> PhysicalValue {
		return PhysicalValue(lhs.value / rhs, lhs.dim)
	}
	static func /(lhs: NumericValue, rhs: PhysicalValue) -> PhysicalValue {
		return PhysicalValue(lhs / rhs.value, rhs.dim) // TODO: rhs.dim shoudl be -rhs.dim
	}
}

extension NumericValue {
	static func *(lhs: NumericValue, rhs: Unit) -> PhysicalValue {
		return PhysicalValue(lhs, rhs)
	}
	
	static func /(lhs: NumericValue, rhs: Unit) -> PhysicalValue {
		return PhysicalValue(lhs, rhs)
	}
}
