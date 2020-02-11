//
//  CoreMotionService.swift
//  Human Activity Recognition
//
//  Created by Ramy Al Zuhouri on 04/09/17.
//  Copyright © 2017 Ramy Al Zuhouri. All rights reserved.
//

import Foundation
import CoreMotion

class CoreMotionService
{
	let manager:CMMotionManager
	var samplingFrequency = 10
	var timer:Timer!
	
	var motion:CMDeviceMotion? {
		return manager.deviceMotion
	}
	
	/************* MOST LIKELY THIS IS NOT NECESSARY **********
	var isAuthorized:Bool {
		return CMSensorRecorder.authorizationStatus() == .authorized
	}
	
	func requestAuthorization() {
		DispatchQueue.global(qos: .userInteractive).async {
			let recorder = CMSensorRecorder()
			recorder.recordAccelerometer(forDuration: 0.1)
		}
	}*/
	
	init?() {
		manager = CMMotionManager()
		
		guard manager.isDeviceMotionAvailable else {
			return nil
		}
		if manager.isMagnetometerAvailable {
			print("Magnetometer Available")
		} else {
			print("Magnetometer Unavailable")
		}
	
		manager.deviceMotionUpdateInterval = 1.0 / Double(samplingFrequency)
	}
	
	deinit {
		print("CoreMotionService.deinit")
	}
	
	func startUpdates() {
		manager.startDeviceMotionUpdates()
	}
	
	func stopUpdates() {
		manager.stopDeviceMotionUpdates()
	}
}







