//
//  WorkoutData.swift
//  Human Activity Recognition WatchKit Extension
//
//  Created by Ramy Al Zuhouri on 18/02/18.
//  Copyright © 2018 Ramy Al Zuhouri. All rights reserved.
//

import Foundation
import HealthKit

struct WorkoutData
{
	let startDate:Date
	let activity:String
	var endDate:Date?
	var age:Int?
	var weight:Double?
	var gender:HKBiologicalSex?
	var restingHeartRate:Double? = nil
	var heartRateSamples = [Double]()
	
	var caloriesBurned:Double? {
		return self.computeCaloriesBurnedWithHeartRate() ?? self.computeCaloriesBurnedWithMetTable()
	}
	
	func computeCaloriesBurnedWithMetTable() -> Double? {
		guard let weight = self.weight else { return nil }
		guard let duration = self.duration else { return nil }
		
		switch activity {
		case "Walking":
			return 3.0 * weight * duration / 3600.0
		case "Sit-ups", "Push-ups", "Lunges":
			return 3.8 * weight * duration / 3600.0
		case "Squats":
			return 5.0 * weight * duration / 3600.0
		case "Running":
			return 7.0 * weight * duration / 3600.0
		case "Jump Rope":
			return 11.8 * weight * duration / 3600.0
		default:
			return nil
		}
	}
	
	func computeCaloriesBurnedWithHeartRate() -> Double? {
		guard let age = self.age else { return nil }
		guard let weight = self.weight else { return nil }
		guard let duration = self.duration else { return nil }
		guard let restingHR = self.restingHeartRate else { return nil }
		guard self.heartRateSamples.count > 0 else { return nil }
		let heartRate = self.heartRateSamples.mean
		
		let maxHR = 210 - (0.8 * Double(age))
		let vo2max = 15.3 * (maxHR / restingHR)
		let vo2 = heartRate / maxHR * vo2max
		return (5.0 * weight * (vo2 - 15.3) / 1000.0 * duration / 60.0)
	}
	
	var duration:TimeInterval? {
		return self.endDate?.timeIntervalSince(self.startDate)
	}
	
	init(startDate:Date, activity:String) {
		self.startDate = startDate
		self.activity = activity
	}
	
	func save() -> Bool {
		guard let endDate = self.endDate else { return false }
		var activityType:HKWorkoutActivityType
		var calories:HKQuantity?
		
		if let caloriesBurned = self.caloriesBurned {
			calories = HKQuantity(unit: HKUnit.kilocalorie(), doubleValue: caloriesBurned)
		}
		
		switch activity
		{
		case "Running":
			activityType = .running
		case "Walking":
			activityType = .walking
		case "Jump Rope":
			activityType = .jumpRope
		case "Lunges", "Squats", "Sit-ups", "Push-ups":
			activityType = .gymnastics
		default:
			activityType = .other
		}
		
		let workout = HKWorkout(activityType: activityType, start: self.startDate, end: endDate, duration: 0.0, totalEnergyBurned: calories, totalDistance: nil, device: HKDevice.local(), metadata: ["Activity":self.activity])
		
		let store = HKHealthStore()
		store.save(workout) {(success, error) in
			print("Workout with Activity: \(self.activity) Saved with Success: \(success)")
			if let error = error {
				print("Error saving Workout: \(error)")
			}
		}
		
		return true
	}
}
