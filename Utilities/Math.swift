//
//  Math.swift
//  Human Activity Recognition
//
//  Created by Ramy Al Zuhouri on 12/09/17.
//  Copyright © 2017 Ramy Al Zuhouri. All rights reserved.
//

import Foundation
import CoreMotion
import CoreLocation

private func arraySum(array:[Double]) -> Double {
	return sum(array)
}

private func arrayMean(array:[Double]) -> Double {
	return mean(array)
}

extension CMAttitude
{
	var magnitude:Double {
		return sqrt(roll * roll + pitch * pitch + yaw * yaw)
	}
}

extension CMRotationRate
{
	var magnitude:Double {
		return sqrt(x * x + y * y + z * z)
	}
}

extension CMAcceleration
{
	var magnitude:Double {
		return sqrt(x * x + y * y + z * z)
	}
}

extension Array where Element == Double?
{
	var hasNilValues:Bool {
		return self.reduce(false, { (result, value) -> Bool in
			return result || value == nil
		})
	}
	
	var unwrapped:[Double]? {
		guard !hasNilValues else { return nil }
		return self.map({(value) in
			return value!
		})
	}
}

extension Array where Element == Double
{
	var sum:Double {
		return arraySum(array: self)
	}
	
	var mean:Double {
		return arrayMean(array: self)
	}
	
	var median:Double
	{
		let sortedArray = self.sorted()
		if sortedArray.count % 2 == 1 {
			// The count is odd
			return sortedArray[count / 2]
		}
		// The count is even
		let median1 = sortedArray[count / 2 - 1]
		let median2 = sortedArray[count / 2]
		return (median1 + median2) / 2.0
	}
	
	func deviation(variance:Double) -> Double {
		return sqrt(variance)
	}
	
	func variance(mean:Double) -> Double {
		return pow(self - mean, 2.0).sum / Double(self.count)
	}
	
	func skewness(mean:Double, deviation:Double) -> Double {
		let s = (pow(self - mean, 3.0) / pow(deviation, 3.0)).sum
		return Double(count) / Double((count - 1) * (count - 2)) * s
	}
	
	func kurtosis(mean:Double, deviation:Double) -> Double {
		let c1 = pow(self - mean, 2.0).sum
		let c2 = pow(self - mean, 4.0).sum
		
		var num = Double(count * (count + 1)) * c2
		num -= 3.0 * c1 * c1 * Double(count - 1)
		
		let den = Double((count - 1) * (count - 2) * (count - 3)) * pow(deviation, 4.0)
		return num / den
	}
	
	var interQuartileRange:Double {
		let sortedArray = self.sorted()
		
		let q1 = sortedArray[count / 4 - 1]
		let q3 = sortedArray[count * 3 / 4 - 1]
		return q3 - q1
	}
	
	func energy(transforms:[Double]) -> Double
	{
		var result:Double = sumsq(transforms)
		result /= Double(transforms.count)
		
		return result
	}
	
	func entropy(transforms:[Double]) -> Double
	{
		var squaredFFTs = pow(transforms, 2.0)
		squaredFFTs = squaredFFTs / Double(transforms.count)
		squaredFFTs = squaredFFTs / squaredFFTs.sum
		
		return -mul(squaredFFTs, log(squaredFFTs)).sum
	}
}







