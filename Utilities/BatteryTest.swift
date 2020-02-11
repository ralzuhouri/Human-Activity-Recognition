//
//  BatteryTest.swift
//  Human Activity Recognition WatchKit Extension
//
//  Created by Ramy Al Zuhouri on 22/06/18.
//  Copyright © 2018 Ramy Al Zuhouri. All rights reserved.
//

import WatchKit

@available(watchOSApplicationExtension 4.0, *)
protocol BatteryTestDelegate : class
{
	func batteryTest(test:BatteryTest, didFinishWithBatteryConsumption batteryConsumption:Float)
	func batteryTest(test:BatteryTest, didUpdateBatteryConsumption batteryConsumption:Float)
}

@available(watchOSApplicationExtension 4.0, *)
class BatteryTest
{
	public let duration:TimeInterval
	public var updateInterval:TimeInterval = -1.0 {
		didSet {
			if self.updateTimer != nil {
				Log("Updating BatteryTest::updateInterval during a test results in undefined behavior.")
			}
		}
	}
	public private(set) var elapsedTime:TimeInterval = 0.0
	public private(set) var startBatteryLevel:Float
	public private(set) var endBatteryLevel:Float
	public weak var delegate:BatteryTestDelegate?
	private var timer:Timer?
	private var updateTimer:Timer?
	
	init(duration:TimeInterval) {
		self.duration = duration
		self.startBatteryLevel = -1.0
		self.endBatteryLevel = -1.0
	}
	
	func start() {
		let device = WKInterfaceDevice.current()
		device.isBatteryMonitoringEnabled = true
		self.startBatteryLevel = device.batteryLevel
		
		if self.updateInterval > 0.0 {
			self.updateTimer = Timer.scheduledTimer(timeInterval: self.updateInterval, target: self, selector: #selector(self.updateTimerFunc(timer:)), userInfo: nil, repeats: true)
		} else {
			self.timer = Timer.scheduledTimer(timeInterval: self.duration, target: self, selector: #selector(self.timerFunc(timer:)), userInfo: nil, repeats: false)
		}
	}
	
	@objc private func updateTimerFunc(timer:Timer) {
		self.update()
	}
	
	@objc private func timerFunc(timer:Timer) {
		self.stop()
	}
	
	func update() {
		let device = WKInterfaceDevice.current()
		let batteryLevel = device.batteryLevel
		self.elapsedTime += updateInterval
		
		if self.elapsedTime < self.duration {
			self.delegate?.batteryTest(test: self, didUpdateBatteryConsumption: self.startBatteryLevel - batteryLevel)
		} else {
			self.stop()
		}
	}
	
	func stop() {
		let device = WKInterfaceDevice.current()
		self.endBatteryLevel = device.batteryLevel
		self.elapsedTime = duration
		self.delegate?.batteryTest(test: self, didFinishWithBatteryConsumption: self.startBatteryLevel - self.endBatteryLevel)
		self.updateTimer?.invalidate()
		self.updateTimer = nil
		self.timer = nil
	}
}














