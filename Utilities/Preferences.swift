//
//  Preferences.swift
//  Human Activity Recognition
//
//  Created by Ramy Al Zuhouri on 02/09/17.
//  Copyright © 2017 Ramy Al Zuhouri. All rights reserved.
//

import Foundation
import WatchConnectivity

class Preferences
{
	class var userDefaults:UserDefaults {
		return UserDefaults.standard
	}
	// MARK: - Options
	class var activities:[String] {
		return userDefaults.array(forKey: "activities") as! [String]
	}
	
	class var samplingFrequency:Int {
		return userDefaults.integer(forKey: "samplingFrequency")
	}
	
	class var windowSize:Double {
		return userDefaults.double(forKey: "windowSize")
	}
	
	class var countdownTime:Double {
		return userDefaults.double(forKey: "countdownTime")
	}
	
	class var overlappingWindows:Bool {
		return userDefaults.bool(forKey: "overlappingWindows")
	}
	
	class var trimLastTwoInstances:Bool {
		return userDefaults.bool(forKey: "trimLastTwoInstances")
	}
	
	class var historySetSize:Int {
		return userDefaults.integer(forKey: "historySetSize")
	}
	
	// MARK: - Features to Include
	class var includeMin:Bool {
		return userDefaults.bool(forKey: "features-min")
	}
	
	class var includeMax:Bool {
		return userDefaults.bool(forKey: "features-max")
	}
	
	class var includeMedian:Bool {
		return userDefaults.bool(forKey: "features-median")
	}
	
	class var includeMean:Bool {
		return userDefaults.bool(forKey: "features-mean")
	}
	
	class var includeDeviation:Bool {
		return userDefaults.bool(forKey: "features-deviation")
	}
	
	class var includeVariance:Bool {
		return userDefaults.bool(forKey: "features-variance")
	}
	
	class var includeSkewness:Bool {
		return userDefaults.bool(forKey: "features-skewness")
	}
	
	class var includeKurtosis:Bool {
		return userDefaults.bool(forKey: "features-kurtosis")
	}
	
	class var includeIQR:Bool {
		return userDefaults.bool(forKey: "features-IQR")
	}
	
	class var includeEnergy:Bool {
		return userDefaults.bool(forKey: "features-energy")
	}
	
	class var includeEntropy:Bool {
		return userDefaults.bool(forKey: "features-entropy")
	}
	
	// MARK: - Sensor Data to Include
	class var includeHeartRate:Bool {
		return userDefaults.bool(forKey: "data-heartRate")
	}
	
	class var includeRoll:Bool {
		return userDefaults.bool(forKey: "data-attitude-roll")
	}
	
	class var includePitch:Bool {
		return userDefaults.bool(forKey: "data-attitude-pitch")
	}
	
	class var includeYaw:Bool {
		return userDefaults.bool(forKey: "data-attitude-yaw")
	}
	
	class var includeAttitudeMagnitude:Bool {
		return userDefaults.bool(forKey: "data-attitude-magnitude")
	}
	
	class var includeXRotationRate:Bool {
		return userDefaults.bool(forKey: "data-rotationRate-x")
	}
	
	class var includeYRotationRate:Bool {
		return userDefaults.bool(forKey: "data-rotationRate-y")
	}
	
	class var includeZRotationRate:Bool {
		return userDefaults.bool(forKey: "data-rotationRate-z")
	}
	
	class var includeRotationRateMagnitude:Bool {
		return userDefaults.bool(forKey: "data-rotationRate-magnitude")
	}
	
	class var includeXGravity:Bool {
		return userDefaults.bool(forKey: "data-gravity-x")
	}
	
	class var includeYGravity:Bool {
		return userDefaults.bool(forKey: "data-gravity-y")
	}
	
	class var includeZGravity:Bool {
		return userDefaults.bool(forKey: "data-gravity-z")
	}
	
	class var includeGravityMagnitude:Bool {
		return userDefaults.bool(forKey: "data-gravity-magnitude")
	}
	
	class var includeXUserAcceleration:Bool {
		return userDefaults.bool(forKey: "data-userAcceleration-x")
	}
	
	class var includeYUserAcceleration:Bool {
		return userDefaults.bool(forKey: "data-userAcceleration-z")
	}
	
	class var includeZUserAcceleration:Bool {
		return userDefaults.bool(forKey: "data-userAcceleration-z")
	}
	
	class var includeUserAccelerationMagnitude:Bool {
		return userDefaults.bool(forKey: "data-userAcceleration-magnitude")
	}
	
	class var includeLatitude:Bool {
		return userDefaults.bool(forKey: "data-coordinate-latitude")
	}
	
	class var includeLongitude:Bool {
		return userDefaults.bool(forKey: "data-coordinate-longitude")
	}
	
	class var includeAltitude:Bool {
		return userDefaults.bool(forKey: "data-altitude")
	}
	
	class var includeCourse:Bool {
		return userDefaults.bool(forKey: "data-course")
	}
	
	class var includeSpeed:Bool {
		return userDefaults.bool(forKey: "data-speed")
	}
	
	// MARK: - Registration and Updating
	class func registerDefaults()
	{
		let path = Bundle.main.path(forResource: "Activities", ofType: "plist")!
		let activities = NSArray(contentsOfFile: path) as! [String]
		
		let defaults:[String:Any] = [
			"activities":activities,
			"countdownTime":5.0,
			"windowSize":2.5,
			"samplingFrequency":16,
			"overlappingWindows":true,
			"trimLastTwoInstances":true,
			"historySetSize":5,
			"features-min":true,
			"features-max":true,
			"features-median":true,
			"features-mean":true,
			"features-deviation":true,
			"features-variance":false,
			"features-skewness":true,
			"features-kurtosis":true,
			"features-IQR":true,
			"features-energy":false,
			"features-entropy":false,
			"data-heartRate":true,
			"data-attitude-roll":true,
			"data-attitude-pitch":true,
			"data-attitude-yaw":true,
			"data-attitude-magnitude":true,
			"data-rotationRate-x":true,
			"data-rotationRate-y":true,
			"data-rotationRate-z":true,
			"data-rotationRate-magnitude":true,
			"data-gravity-x":false,
			"data-gravity-y":false,
			"data-gravity-z":false,
			"data-gravity-magnitude":false,
			"data-userAcceleration-x":true,
			"data-userAcceleration-y":true,
			"data-userAcceleration-z":true,
			"data-userAcceleration-magnitude":true,
			"data-coordinate-latitude":false,
			"data-coordinate-longitude":false,
			"data-altitude":true,
			"data-course":true,
			"data-speed":true
		] 
		self.userDefaults.register(defaults: defaults)
	}
	
	class var dictionary:[String:Any] {
		let dict:[String:Any] = [
			"activities":self.activities,
			"countdownTime":self.countdownTime,
			"windowSize":self.windowSize,
			"samplingFrequency":self.samplingFrequency,
			"overlappingWindows":self.overlappingWindows,
			"trimLastTwoInstances":self.trimLastTwoInstances,
			"historySetSize":self.historySetSize,
			"features-min":self.includeMin,
			"features-max":self.includeMax,
			"features-median":self.includeMedian,
			"features-mean":self.includeMean,
			"features-deviation":self.includeDeviation,
			"features-variance":self.includeVariance,
			"features-skewness":self.includeSkewness,
			"features-kurtosis":self.includeKurtosis,
			"features-IQR":self.includeIQR,
			"features-energy":self.includeEnergy,
			"features-entropy":self.includeEntropy,
			"data-heartRate":self.includeHeartRate,
			"data-attitude-roll":self.includeRoll,
			"data-attitude-pitch":self.includePitch,
			"data-attitude-yaw":self.includeYaw,
			"data-attitude-magnitude":self.includeAttitudeMagnitude,
			"data-rotationRate-x":self.includeXRotationRate,
			"data-rotationRate-y":self.includeYRotationRate,
			"data-rotationRate-z":self.includeZRotationRate,
			"data-rotationRate-magnitude":self.includeRotationRateMagnitude,
			"data-gravity-x":self.includeXGravity,
			"data-gravity-y":self.includeYGravity,
			"data-gravity-z":self.includeZGravity,
			"data-gravity-magnitude":self.includeGravityMagnitude,
			"data-userAcceleration-x":self.includeXUserAcceleration,
			"data-userAcceleration-y":self.includeYUserAcceleration,
			"data-userAcceleration-z":self.includeZUserAcceleration,
			"data-userAcceleration-magnitude":self.includeUserAccelerationMagnitude,
			"data-coordinate-latitude":self.includeLatitude,
			"data-coordinate-longitude":self.includeLongitude,
			"data-altitude":self.includeAltitude,
			"data-course":self.includeCourse,
			"data-speed":self.includeSpeed
		]
		return dict
	}
	
	class func update(withDictionary dictionary:[String:Any]) {
		if let activities = dictionary["activities"] as? [String] {
			self.userDefaults.set(activities, forKey: "activities")
		}
		
		if let countdownTime = dictionary["countdownTime"] as? Double {
			self.userDefaults.set(countdownTime, forKey: "countdownTime")
		}
		
		if let windowSize = dictionary["windowSize"] as? Double {
			self.userDefaults.set(windowSize, forKey: "windowSize")
		}
		
		if let samplingFrequency = dictionary["samplingFrequency"] as? Int {
			self.userDefaults.set(samplingFrequency, forKey: "samplingFrequency")
		}
		
		if let overlappingWindows = dictionary["overlappingWindows"] as? Bool {
			self.userDefaults.set(overlappingWindows, forKey: "overlappingWindows")
		}
		
		if let trimLastTwoInstances = dictionary["trimLastTwoInstances"] as? Bool {
			self.userDefaults.set(trimLastTwoInstances, forKey: "trimLastTwoInstances")
		}
		
		if let historySetSize = dictionary["historySetSize"] as? Int {
			self.userDefaults.set(historySetSize, forKey: "historySetSize")
		}
		
		let features = [
			"features-max",
			"features-min",
			"features-median",
			"features-mean",
			"features-deviation",
			"features-variance",
			"features-skewness",
			"features-kurtosis",
			"features-IQR",
			"features-energy",
			"features-entropy",
		]
		
		for feature in features {
			if let boolean = dictionary[feature] as? Bool {
				self.userDefaults.set(boolean, forKey: feature)
			}
		}
		
		let sensorData = [
			"data-heartRate",
			"data-attitude-roll",
			"data-attitude-pitch",
			"data-attitude-yaw",
			"data-attitude-magnitude",
			"data-rotationRate-x",
			"data-rotationRate-y",
			"data-rotationRate-z",
			"data-rotationRate-magnitude",
			"data-gravity-x",
			"data-gravity-y",
			"data-gravity-z",
			"data-gravity-magnitude",
			"data-userAcceleration-x",
			"data-userAcceleration-y",
			"data-userAcceleration-z",
			"data-userAcceleration-magnitude",
			"data-coordinate-latitude",
			"data-coordinate-longitude",
			"data-altitude",
			"data-course",
			"data-speed"
		]
		
		for data in sensorData {
			if let boolean = dictionary[data] as? Bool {
				self.userDefaults.set(boolean, forKey: data)
			}
		}
		
		self.userDefaults.synchronize()
	}
	
#if os(watchOS)
	class func pull()
	{
		let session = WCSession.default
		if session.isReachable && session.activationState == .activated {
			session.sendMessage(["type":"pullPreferences"], replyHandler: { reply in
				self.update(withDictionary: reply)
				print("Succesfully updated preferences")
			}, errorHandler: { error in
				print("Error updating preferences: \(error)")
			})
		}
	}
#endif
	
#if os(iOS)
	class PreferencesObserver:NSObject
	{
		private static var _shared:PreferencesObserver?
		class var shared:PreferencesObserver {
			if _shared == nil {
				_shared = PreferencesObserver()
			}
			return _shared!
		}
		
		private override init() {}
		
		override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
			print("Observe value for key path: \(keyPath ?? "Nil")")
			Preferences.push()
		}
	}
	
	class func monitorChanges() {
		print("Start monitoring changes")
		let observer = PreferencesObserver.shared
		for key in self.dictionary.keys {
			self.userDefaults.addObserver(observer, forKeyPath: key, options: .new, context: nil)
		}
	}
	
	class func stopMonitoringChanges() {
		print("Stop monitoring changes")
		let observer = PreferencesObserver.shared
		for key in self.dictionary.keys {
			self.userDefaults.removeObserver(observer, forKeyPath: key)
		}
	}
	
	// Asynchronous push: THIS HAS TO BE CHANGED. The call should be synchronous
	class func push() {
		print("Pushing preferences")
		let session = WCSession.default
		if session.isReachable && session.activationState == .activated {
			let message:[String:Any] = [
				"type":"pushPreferences",
				"preferences":self.dictionary
			]
			session.sendMessage(message, replyHandler: { reply in
			}, errorHandler: { error in
				print("Error: \(error)")
			})
		}
	}
#endif
}







