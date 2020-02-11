//
//  TestingController.swift
//  Human Activity Recognition WatchKit Extension
//
//  Created by Ramy Al Zuhouri on 26/01/18.
//  Copyright © 2018 Ramy Al Zuhouri. All rights reserved.
//

import WatchKit
import Foundation
import HealthKit
import WatchConnectivity

class TestingController: WKInterfaceController, SensorsRecorderDelegate, HealthKitServiceDelegate, MessageQueueDelegate, HistorySetDelegate
{
	// MARK: - Properties
	@IBOutlet var activityLabel: WKInterfaceLabel!
	@IBOutlet var accuracyLabel: WKInterfaceLabel!
	@IBOutlet var historySetSizeLabel: WKInterfaceLabel!
	@IBOutlet var caloriesLabel: WKInterfaceLabel!
	@IBOutlet var timer: WKInterfaceTimer!
	@IBOutlet var accelerometerLabel: WKInterfaceLabel!
	@IBOutlet var gyroscopeLabel: WKInterfaceLabel!
	@IBOutlet var GPS_Label: WKInterfaceLabel!
	@IBOutlet var heartRateLabel: WKInterfaceLabel!
	@IBOutlet var separator: WKInterfaceSeparator!
	@IBOutlet var countdownInterfaceTimer: WKInterfaceTimer!
	var countdownTimer:Timer?
	
	var queue:MessageQueue!
	var workout:WorkoutData?
	var restingHeartRate:Double? = nil
	let historySet = HistorySet(historySize: Preferences.historySetSize)
	var startTime:Date!
	var recorder:SensorsRecorder!
	var batteryTest:Any?
	
	lazy var decisionTree:DecisionTree? = {
		return DecisionTree.shared()
	}()
	
	@available(watchOSApplicationExtension 4.0, *)
	func setRestingHeartRate() {
		let typeHeart = HKQuantityType.quantityType(forIdentifier: .restingHeartRate)
		//let startDate = Date() - 7.0 * 24.0 * 3600.0
		let startDate = Date.distantPast
		let predicate: NSPredicate? = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: HKQueryOptions.strictEndDate)
		
		let query = HKStatisticsQuery(quantityType: typeHeart!, quantitySamplePredicate: predicate, options: .discreteAverage, completionHandler: {(query: HKStatisticsQuery,result: HKStatistics?, error: Error?) -> Void in
			DispatchQueue.main.async(execute: {() -> Void in
				guard error == nil else {
					print("Error querying resting heart rate: \(error!)")
					return
				}
				let quantity: HKQuantity? = result?.averageQuantity()
				guard let beats = quantity?.doubleValue(for: HKUnit.count().unitDivided(by: HKUnit.minute())) else { return }
				self.restingHeartRate = beats
			})
		})
		
		let store = HKHealthStore()
		store.execute(query)
	}

	// MARK: - Functions
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
		
		DispatchQueue.main.async { [weak self] in
        	// Configure interface objects here.
			guard let recorder = context as? SensorsRecorder else { return }
			self?.recorder = recorder
			self?.recorder.delegate = self
			self?.recorder.healthKitService.delegate = self
			self?.recorder.startSession()
		
			self?.queue = MessageQueue(timeout: 5.0)
			self?.queue.delegate = self
		
			self?.historySet.delegate = self
			self?.historySetSizeLabel.setText("History Set Size: \(self?.historySet.size ?? 0)")
		
			self?.heartRateLabel.setText("♥ N/A")
		
			if #available(watchOSApplicationExtension 4.0, *) {
				self?.setRestingHeartRate()
			}
		
			let date = Date(timeIntervalSinceNow: Preferences.countdownTime)
			self?.countdownInterfaceTimer.setDate(date)
			self?.countdownInterfaceTimer.start()
			
			self?.countdownTimer = Timer.scheduledTimer(withTimeInterval: Preferences.countdownTime, repeats: false) { [weak self] timer in
				DispatchQueue.main.async {
					self?.startTime = Date()
					//Log("Activity *", relativeDate: self?.startTime)
					// MARK: - Battery test
					/*if #available(watchOSApplicationExtension 4.0, *) {
						self?.startBatteryTest()
					}*/
					self?.recorder.start()
					self?.queue.enqueue(message: ["type":"prediction", "state":"started"])
				
					self?.countdownInterfaceTimer.setHidden(true)
					self?.separator.setHidden(true)
					self?.countdownTimer = nil
					
					let device = WKInterfaceDevice.current()
					device.play(.start)
				}
			}
		}
    }
	
	deinit {
		let startTime:Date? = self.startTime
		if let recorder = self.recorder {
			DispatchQueue.main.async {
				recorder.stopSession()
				if(startTime != nil) {
					recorder.stop()
				}
				recorder.healthKitService.delegate = nil
				recorder.delegate = nil
			}
		}
		
		self.recorder = nil
			
		if(self.countdownTimer != nil) {
			self.countdownInterfaceTimer.stop()
			self.countdownTimer?.invalidate()
		}
		
		//Log("End", relativeDate: self.startTime)
		
		if self.historySet.activity != "Unknown" && self.historySet.activity != "Resting" {
			if var workout = self.workout {
				workout.endDate = Date()
				if workout.duration! >= 10.0 {
					let _ = workout.save()
				}
			}
		}
		
		if let queue = self.queue {
			queue.clear()
		}
		self.queue = nil
		
		if WCSession.isSupported() {
			let session = WCSession.default
			if session.activationState == .activated && session.isReachable {
				session.sendMessage(["type":"prediction","state":"ended"], replyHandler: nil, errorHandler: nil)
			}
		}
	}

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
	
	// MARK: - SensorsRecorderDelegate
	func sensorsRecorder(_ recorder: SensorsRecorder, didExtractFeatures features: [String : Any]) {
		// MARK: - Classification
		guard let activity = self.decisionTree?.activity(forFeaturesDict: features) else {
			self.activityLabel.setText("Activity: Unknown")
			self.accuracyLabel.setText("Accuracy: N/A")
			self.caloriesLabel.setText("Active Calories: 0")
			self.queue.enqueue(message: ["type":"prediction", "state":"predicting", "prediction":"Unknown"])
			return
		}
		self.historySet.insert(activity: activity)
		//Log("\(activity)", relativeDate: self.startTime)

		
		if self.historySet.activity == "Unknown" {
			self.accuracyLabel.setText("Accuracy: N/A")
		} else if self.historySet.accuracy <= 0.6 {
			self.accuracyLabel.setText("Accuracy: Low")
		} else if self.historySet.accuracy <= 0.8 {
			self.accuracyLabel.setText("Accuracy: Medium")
		} else {
			self.accuracyLabel.setText("Accuracy: High")
		}
		
		if self.workout != nil {
			if let heartRateGroup = features["heartRate"] as? [String:Any] {
				if let heartRate = heartRateGroup["mean"] as? Double {
					self.workout!.heartRateSamples.append(heartRate)
				}
			}
			
			self.workout!.endDate = Date()
			guard let calories = self.workout!.caloriesBurned else { return }
			self.caloriesLabel.setText("Active Calories: \(Int(calories))")
		} else {
			self.caloriesLabel.setText("Active Calories: 0")
		}
		
		self.queue.enqueue(message: ["type":"prediction", "state":"predicting", "prediction":self.historySet.activity])
	}
	
	func sensorsRecorder(_ recorder: SensorsRecorder, didChangefromSensorsState fromState: SensorsState, toState: SensorsState) {
		
		if self.recorder.isAccelerometerEnabled {
			if toState.isAccelerometerActive {
				accelerometerLabel.setText("Accelerometer ✅")
			} else {
				self.accelerometerLabel.setText("Accelerometer ❌")
			}
		} else {
			self.accelerometerLabel.setText("Accelerometer N/A")
		}
		
		if self.recorder.isGyroscopeEnabled {
			if toState.isGyroscopeActive {
				gyroscopeLabel.setText("Gyroscope ✅")
			} else {
				self.gyroscopeLabel.setText("Gyroscope ❌")
			}
		} else {
			self.gyroscopeLabel.setText("Gyroscope N/A")
		}
		
		if self.recorder.isGPSEnabled {
			if toState.isGPSActive {
				GPS_Label.setText("GPS ✅")
			} else {
				self.GPS_Label.setText("GPS ❌")
			}
		} else {
			self.GPS_Label.setText("GPS N/A")
		}
	}
	
	// MARK: - HealthKitServiceDelegate
	func healthKitService(_ service: HealthKitService, didUpdateBodyMass bodyMass: Double) {
		if self.workout != nil {
			self.workout!.weight = bodyMass
		}
	}
	
	func healthKitService(_ service: HealthKitService, didUpdateHeight height: Double) {
	}
	
	func healthKitService(_ service: HealthKitService, didUpdateHeartRate heartRate: Double) {
		heartRateLabel.setText("♥ \(heartRate) bpm")
	}
	
	// MARK: - HKWorkoutSessionDelegate
	func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
	}
	
	func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
	}
	
	// MARK: - MessageQueueDelegate
	func messageQueue(_ queue: MessageQueue, didDeliverMessage message: [String : Any], withReply: [String : Any]) {
	}
	
	func messageQueue(_ queue: MessageQueue, didFailToDeliverMessage: [String : Any], retry: UnsafeMutablePointer<Bool>) {
		retry.pointee = true
	}
	
	// MARK: - HistorySetDelegate
	func historySet(_ historySet: HistorySet, didTransitionFromActivity fromActivity: String, toActivity: String) {
		self.activityLabel.setText("Activity: \(toActivity)")
		
		let deltaTime:Double // The minimum amount of time to transition from one activity to another
		let frame:Double
		if Preferences.overlappingWindows {
			frame = Preferences.windowSize / 2.0
		} else {
			frame = Preferences.windowSize
		}
		deltaTime = frame * Double(self.historySet.size / 2 + 1)
		
		if self.workout != nil {
			self.workout!.endDate = Date().addingTimeInterval(-deltaTime)
			if self.workout!.duration! >= 10.0 {
				let _ = self.workout!.save()
			}
		}
		
		self.timer.setDate(Date())
		
		if toActivity == "Unknown" {
			self.timer.stop()
			self.workout = nil
		} else if toActivity != "Resting" {
			self.workout = WorkoutData(startDate: Date().addingTimeInterval(-deltaTime), activity: toActivity)
			self.workout!.age = self.recorder?.healthKitService.age
			self.workout!.gender = self.recorder?.healthKitService.biologicalSex
			self.workout!.weight = self.recorder?.healthKitService.bodyMass
			self.workout!.restingHeartRate = self.restingHeartRate
			self.timer.start()
		} else { // Resting
			self.workout = nil
			self.timer.start()
		}
	}

}

// Battery test extension
@available(watchOSApplicationExtension 4.0, *)
extension TestingController : BatteryTestDelegate
{
	func startBatteryTest() {
		let test = BatteryTest(duration: 60.0 * 60.0 * 4.0)
		self.batteryTest = test
		test.updateInterval = 60.0 * 60.0
		test.delegate = self
		test.start()
		Log("Battery test started, with battery level: \(test.startBatteryLevel)", relativeDate: self.startTime)
	}
	
	func format(timeInterval interval:TimeInterval) -> String? {
		let formatter = DateComponentsFormatter()
		formatter.allowedUnits = [.hour, .minute, .second]
		formatter.unitsStyle = .abbreviated
		formatter.maximumUnitCount = 2
		return formatter.string(from: interval)
	}
	
	func batteryTest(test: BatteryTest, didFinishWithBatteryConsumption batteryConsumption: Float) {
		let duration:Any = self.format(timeInterval: test.elapsedTime) ?? test.elapsedTime
		Log("Battery test ended, with total elapsed time: \(duration), and battery consumption: \(batteryConsumption)", relativeDate: self.startTime)
	}
	
	func batteryTest(test: BatteryTest, didUpdateBatteryConsumption batteryConsumption: Float) {
		let duration:Any = self.format(timeInterval: test.elapsedTime) ?? test.elapsedTime
		Log("Battery test updated, with total elapsed time: \(duration), and battery consumption: \(batteryConsumption)", relativeDate: self.startTime)
	}
}














