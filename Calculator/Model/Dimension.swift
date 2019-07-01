//
//  Dimension.swift
//  JCalc
//
//  Created by Soonkyu Jeong on 2019/06/23.
//  Copyright © 2019 Soonkyu Jeong. All rights reserved.
//

enum Dimension {
	case unitless
	case length, mass, time,electricCurrent,temperature, amountOfSubstance, luminousIntensity
	case area, volume
	case frequency, energy, power
	case velocity, acceleration, force, pressure
	case planeAngle, solidAngle, torque, angularVelocity, angularAcceleration
	case electricCharge, voltage, capacitance, resistance, electricConductance
	
	static let dimensions: [Dimension: DimensionalExponent] = [
		.unitless:                  DimensionalExponent([0, 0, 0, 0, 0, 0, 0]),
		
		.length:                    DimensionalExponent([1, 0, 0, 0, 0, 0, 0]),
		.mass:                      DimensionalExponent([0, 1, 0, 0, 0, 0, 0]),
		.time:                      DimensionalExponent([0, 0, 1, 0, 0, 0, 0]),
		.electricCurrent:           DimensionalExponent([0, 0, 0, 1, 0, 0, 0]),
		.temperature:               DimensionalExponent([0, 0, 0, 0, 1, 0, 0]),
		.amountOfSubstance:         DimensionalExponent([0, 0, 0, 0, 0, 1, 0]),
		.luminousIntensity:         DimensionalExponent([0, 0, 0, 0, 0, 0, 1]),
		
		.area:                      DimensionalExponent([2, 0, 0, 0, 0, 0, 0]),
		.volume:                    DimensionalExponent([3, 0, 0, 0, 0, 0, 0]),
		
		.frequency:                 DimensionalExponent([0, 0, 0, 0, 0, 0, 0]),
		.energy:                    DimensionalExponent([0, 0, 0, 0, 0, 0, 0]),
		.power:                     DimensionalExponent([0, 0, 0, 0, 0, 0, 0]),
		
		.velocity:                  DimensionalExponent([1, 0, -1, 0, 0, 0, 0]),
		.acceleration:              DimensionalExponent([0, 0, 0, 0, 0, 0, 0]),
		.force:                     DimensionalExponent([0, 0, 0, 0, 0, 0, 0]),
		.pressure:                  DimensionalExponent([0, 0, 0, 0, 0, 0, 0])
	]
	
	static func contains(_ dim: Dimension) -> Bool { dimensions[dim] != nil }
	static subscript (_ dim: Dimension) -> DimensionalExponent? { dimensions[dim] }
	static subscript (_ exp: DimensionalExponent) -> Dimension? {
		for (key, value) in dimensions {
			if exp == value {
				return key
			}
		}
		return nil
	}
}

struct DimensionalExponent: Equatable {
	// [length, mass, time, electricCurrent, temperature, amountOfSubstance, luminousIntensity]
	let exponents: [Int8]
	let angle: Int8 // plane angle = 1, solid angle = 2
	
	init(_ exponents: [Int8] = [0, 0, 0, 0, 0, 0, 0], angle: Int8 = 0) {
		assert(exponents.count == 7)
		self.exponents = exponents
		self.angle = angle
	}
	
	static let nBaseDimension = 7 // excluding angle
	
	static func ==(lhs: DimensionalExponent, rhs: DimensionalExponent) -> Bool {
		for i in 0..<nBaseDimension {
			if lhs.exponents[i] != rhs.exponents[i] {
				return false
			}
		}
		return lhs.angle == rhs.angle
	}
	
	static func +(lhs: DimensionalExponent, rhs: DimensionalExponent) -> DimensionalExponent {
		return DimensionalExponent([
			lhs.exponents[0] + rhs.exponents[0],
			lhs.exponents[1] + rhs.exponents[1],
			lhs.exponents[2] + rhs.exponents[2],
			lhs.exponents[3] + rhs.exponents[3],
			lhs.exponents[4] + rhs.exponents[4],
			lhs.exponents[5] + rhs.exponents[5],
			lhs.exponents[6] + rhs.exponents[6]
			], angle: lhs.angle + rhs.angle)
	}
	
	static func -(lhs: DimensionalExponent, rhs: DimensionalExponent) -> DimensionalExponent {
		return DimensionalExponent([
			lhs.exponents[0] - rhs.exponents[0],
			lhs.exponents[1] - rhs.exponents[1],
			lhs.exponents[2] - rhs.exponents[2],
			lhs.exponents[3] - rhs.exponents[3],
			lhs.exponents[4] - rhs.exponents[4],
			lhs.exponents[5] - rhs.exponents[5],
			lhs.exponents[6] - rhs.exponents[6]
			], angle: lhs.angle - rhs.angle)
	}
	
	static prefix func -(rhs: DimensionalExponent) -> DimensionalExponent {
		return DimensionalExponent([
			-rhs.exponents[0],
			-rhs.exponents[1],
			-rhs.exponents[2],
			-rhs.exponents[3],
			-rhs.exponents[4],
			-rhs.exponents[5],
			-rhs.exponents[6]
			], angle: -rhs.angle)
	}
}
