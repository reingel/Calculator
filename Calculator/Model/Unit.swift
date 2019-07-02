//
//  Unit.swift
//  JCalc
//
//  Created by Soonkyu Jeong on 2019/06/23.
//  Copyright © 2019 Soonkyu Jeong. All rights reserved.
//

struct Unit {
	let dim: Dimension
	let factor: NumericValue
	let offset: NumericValue
	let isFavorite: Bool
	
	init(dim: Dimension = .unitless, factor: NumericValue = 1.0, offset: NumericValue = 0.0, isFavorite: Bool = false) {
		self.dim = dim
		self.factor = factor
		self.offset = offset
		self.isFavorite = isFavorite
	}
	
	static let units: [String: Unit] = [
		"m": Unit(dim: .length, isFavorite: true),
		"km": Unit(dim: .length, factor: 1000.0),
		
		"m^2": Unit(dim: .area, isFavorite: true),
		
		"degC": Unit(dim: .temperature, factor: 1.0, offset: 273.15, isFavorite: true),
		"degF": Unit(dim: .temperature, factor: 5.0/9.0, offset: 459.67*5.0/9.0),
	]
	
	static func contains(_ unitString: String) -> Bool { units[unitString] != nil }
	static subscript (_ unitString: String) -> Unit? { units[unitString] }
	static subscript (_ dim: Dimension) -> [String: Unit] {
		var found = [String: Unit]()
		for unit in units {
			if unit.value.dim == dim {
				found[unit.key] = unit.value
			}
		}
		return found
	}
	static func favorite(_ dim: Dimension) -> (String, Unit)? {
		for unit in units {
			if unit.value.dim == dim && unit.value.isFavorite == true {
				return (unit.key, unit.value)
			}
		}
		return nil
	}
}
