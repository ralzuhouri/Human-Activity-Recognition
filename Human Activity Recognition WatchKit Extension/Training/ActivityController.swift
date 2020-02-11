//
//  ActivityController.swift
//  Human Activity Recognition
//
//  Created by Ramy Al Zuhouri on 02/09/17.
//  Copyright © 2017 Ramy Al Zuhouri. All rights reserved.
//

import WatchKit
import Foundation
import HealthKit
import CoreMotion
import WatchConnectivity

class ActivityController: WKInterfaceController, HealthKitServiceDelegate, SensorsRecorderDelegate, MessageQueueDelegate
{
	// MARK: - Properties
	@IBOutlet var separator: WKInterfaceSeparator!
	@IBOutlet var countdownTimer: WKInterfaceTimer!
	@IBOutlet var heartRateLabel: WKInterfaceLabel!
	@IBOutlet var instancesLabel: WKInterfaceLabel!
	@IBOutlet var statusLabel: WKInterfaceLabel!
	@IBOutlet var accelerometerStateLabel: WKInterfaceLabel!
	@IBOutlet var gyroscopeStateLabel: WKInterfaceLabel!
	@IBOutlet var GPS_stateLabel: WKInterfaceLabel!
	@IBOutlet var doneButton: WKInterfaceButton!
	@IBOutlet var summaryLabel: WKInterfaceLabel!
	
	var queue:MessageQueue!
	let queueLimit = 128
	var trainingInfo:[String:Any]!
	
	var collectedInstances = 0 {
		didSet {
			self.setInstancesLabelText()
		}
	}
	var deliveredInstances = Set<Int16>()
	func setInstancesLabelText() {
		//print(self.deliveredInstances.count)
		instancesLabel.setText("Delivered Instances: \(self.deliveredInstances.count)/\(collectedInstances)")
	}
	
	var timer:Timer!
	var recorder:SensorsRecorder!
	
	// MARK: - Events
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
		
		// I set up the sensors recorder and the training info dictionary
		guard let recorder = context as? SensorsRecorder else { return }
		self.recorder = recorder
		recorder.healthKitService.delegate = self
		recorder.delegate = self
		
		let device = WKInterfaceDevice.current()
		self.trainingInfo = [
			"activity":self.recorder.activity,
			"wristLocation":Int16(device.wristLocation.rawValue),
			"crownOrientation":Int16(device.crownOrientation.rawValue),
			"windowSize":Preferences.windowSize,
			"samplingFrequency":Int16(Preferences.samplingFrequency),
			"overlappingWindows":Preferences.overlappingWindows
		]
		if let age = recorder.healthKitService.age {
			trainingInfo["age"] = age
		}
		if let gender = recorder.healthKitService.biologicalSex?.rawValue {
			trainingInfo["gender"] = gender
		}
		
		recorder.startSession()
		self.setTitle(recorder.activity)
		
		// I set up the queue
		self.queue = MessageQueue(timeout: 5.0)
		self.queue.delegate = self
		
		// Setting the Labels
		self.heartRateLabel.setText("♥ N/A")
		
		// Register for the didReceiveRemoteCommand notification
		NotificationCenter.default.addObserver(self, selector: #selector(self.didReceiveRemoteCommand(notification:)), name: NSNotification.Name(rawValue: "didReceiveRemoteCommand"), object: nil)
    }
	
	deinit {
		print("ActivityController.deinit on main thread: \(Thread.isMainThread)")
		
		// Remove the didReceiveRemoteCommand observer
		NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "didReceiveRemoteCommand"), object: nil)
		
		if timer != nil {
			print("Invalidating timer")
			timer.invalidate()
			countdownTimer.stop()
		}
		guard let recorder = self.recorder else { return }
		let deliveredInstances = self.deliveredInstances.count
		let collectedInstances = self.collectedInstances
		
		DispatchQueue.main.async {
			let sessionState = recorder.sessionState
			if sessionState == .running || sessionState == .paused {
				recorder.stop()
				WorkoutInfo.shared.update(withSessionStatus: .stopped, collectedInstances: collectedInstances, deliveredInstances: deliveredInstances)
			}
			
			recorder.healthKitService.delegate = nil
			recorder.delegate = nil
			recorder.stopSession()
		}
	}
	
	var firstAppearance = true
	override func didAppear() {
		if firstAppearance {
			firstAppearance = false
			self.startTimer(resume: false)
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
	
	override func willDisappear() {
		super.willDisappear()
	}
	
	@objc func didReceiveRemoteCommand(notification:Notification) {
		guard let command = notification.userInfo?["command"] as? String else { return }
		guard isTimerOn == false else { return }
		print("didReceiveRemoteCommand: \(command)")
		
		switch command {
		case "pause":
			self.pause()
		case "resume":
			guard self.queue.size < self.queueLimit else { break }
			self.startTimer(resume: true)
		case "stop":
			self.stop()
		default:break
		}
	}
	
	func presentFullQueueAlert() {
		DispatchQueue.main.async {
			let ok = WKAlertAction(title: "Ok", style: .cancel, handler: {})
			self.presentAlert(withTitle: "Training Paused", message: "You Instances Queue is Full. Pair your iPhone to Resume the Training", preferredStyle: .alert, actions: [ok])
		}
	}
	
	// MARK: - Messages
	func sendCommand(_ command:String, userInfo:[String:Any]?) {
		var msg:[String:Any] = [
			"type":"command",
			"command":command,
			"activity":self.recorder.activity,
			"time":Date()
		]
		if userInfo != nil {
			msg["userInfo"] = userInfo!
		}
		
		self.queue.enqueue(message: msg)
	}
	
	func sendInfo(_ info:[String:Any]?) {
		var state:String
		switch recorder.sessionState {
		case .running:
			state = "running"
		case .notStarted:
			state = "notStarted"
		case .paused:
			state = "paused"
		case .ended:
			state = "ended"
		}
		
		var msg:[String:Any] = [
			"type":"info",
			"state":state,
			"activity":self.recorder.activity,
			"time":Date()
		]
		if let info = info {
			for (key, value) in info {
				msg[key] = value
			}
		}
		
		self.queue.enqueue(message: msg)
	}
	
	// MARK: - Commands
	@objc func pause() {
		guard recorder.sessionState == .running else { return }
		recorder.pause()
		WorkoutInfo.shared.update(withSessionStatus: .paused, collectedInstances: self.collectedInstances, deliveredInstances: self.deliveredInstances.count)
		self.sendCommand("pause", userInfo: nil)
		
		DispatchQueue.main.async {
			self.statusLabel.setText("Training Paused")
			self.clearAllMenuItems()
			self.addMenuItem(with: .resume, title: "Resume", action: #selector(self.resume))
			self.addMenuItem(with: .block, title: "Stop", action: #selector(self.stop))
		}
	}
	
	@objc func resume() {
		guard recorder.sessionState == .paused else { return }
		guard self.queue.size < self.queueLimit else {
			self.presentFullQueueAlert()
			return
		}
		self.sendCommand("resume", userInfo: nil)
		
		DispatchQueue.main.async {
			self.clearAllMenuItems()
		}
		self.startTimer(resume: true)
	}
	
	@objc func stop() {
		guard recorder.sessionState != .ended else { return }
		self.recorder.stop()
		
		// Send the "Stop" Command
		let endTime = Date()
		self.sendCommand("stop", userInfo: ["endTime":endTime])
		
		self.recorder.healthKitService.delegate = nil
		self.recorder.delegate = nil
		
		WorkoutInfo.shared.update(withSessionStatus: .stopped, collectedInstances: self.collectedInstances, deliveredInstances: self.deliveredInstances.count)
		
		DispatchQueue.main.async {
			self.clearAllMenuItems()
			
			self.statusLabel.setText("Training Finished")
			self.accelerometerStateLabel.setHidden(true)
			self.gyroscopeStateLabel.setHidden(true)
			self.GPS_stateLabel.setHidden(true)
			self.heartRateLabel.setHidden(true)
			
			if self.queue.isEmpty {
				self.doneButton.setHidden(false)
				
				if self.collectedInstances > 0 {
					self.summaryLabel.setHidden(false)
				}
			}
		}
	}
	
	@IBAction func done() {
		DispatchQueue.main.async {
			self.queue.clear()
			self.recorder.stopSession()
			self.recorder = nil
			self.pop()
		}
	}
	
	// MARK: - Functions
	private var isTimerOn = false
	func startTimer(resume:Bool) {
		guard !isTimerOn else { return }
		let sessionState = recorder.sessionState
		guard sessionState == .notStarted || sessionState == .paused else { return }
		let countdownTime = TimeInterval(Preferences.countdownTime)
		let date = Date(timeIntervalSinceNow: countdownTime)
		countdownTimer.setDate(date)
		separator.setHidden(false)
		countdownTimer.setHidden(false)
		countdownTimer.start()
		self.isTimerOn = true
		
		// In order to better record data in time, the workout is started beforehand
		// When the timer fires, the recorder actually starts recording instances
		
		self.timer = Timer(timeInterval: countdownTime, repeats: false, block: { [weak self] (timer) in
			// Workout Started
			DispatchQueue.main.async {
				let device = WKInterfaceDevice.current()
				device.play(.start)
				self?.separator.setHidden(true)
				self?.countdownTimer.setHidden(true)
				if resume {
					self?.recorder.resume()
					if let collectedInstances = self?.collectedInstances {
						if let deliveredInstances = self?.deliveredInstances {
							WorkoutInfo.shared.update(withSessionStatus: .resumed, collectedInstances: collectedInstances, deliveredInstances: deliveredInstances.count)
						}
					}
				} else {
					self?.recorder.start()
					if let collectedInstances = self?.collectedInstances {
						if let deliveredInstances = self?.deliveredInstances {
							WorkoutInfo.shared.update(withSessionStatus: .started, collectedInstances: collectedInstances, deliveredInstances: deliveredInstances.count)
						}
					}
				}
				
				self?.isTimerOn = false
				
				self?.trainingInfo["startTime"] = Date()
				
				self?.clearAllMenuItems()
				self?.addMenuItem(with: .pause, title: "Pause", action: #selector(self?.pause))
				self?.addMenuItem(with: .block, title: "Stop", action: #selector(self?.stop))
				
				if resume {
					self?.sendCommand("resume", userInfo: nil)
				} else {
					self?.sendCommand("start", userInfo: self?.trainingInfo)
				}
			}
		})
		
		RunLoop.main.add(timer, forMode: .commonModes)
	}
	
	// MARK: - HKWorkoutSessionDelegate
	func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
		switch toState {
		case .running:
			if fromState == .notStarted {
				self.collectedInstances = 0
				self.statusLabel.setText("Training Started")
			} else {
				self.statusLabel.setText("Training Resumed")
			}
			break
		case .paused:
			self.statusLabel.setText("Training Paused")
			break
		case .ended:
			self.statusLabel.setText("Training Stopped")
			break
		default:
			break
		}
	}
	
	func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
		print("Session failed with error: \(String(describing:error))")
	}
	
	// MARK: - HealthKitServiceDelegate
	func healthKitService(_ service: HealthKitService, didUpdateHeartRate heartRate: Double) {
		heartRateLabel.setText("♥ \(heartRate) bpm")
	}
	
	func healthKitService(_ service: HealthKitService, didUpdateBodyMass bodyMass: Double) {
		//self?.training?.weight = bodyMass as NSNumber
		if self.trainingInfo["startTime"] == nil {
			// If the training is not started yet I simply add the weight info
			self.trainingInfo["weight"] = bodyMass
		} else {
			// If the training is already started I send the weight info
			self.sendInfo(["weight":bodyMass])
		}
	}
	
	func healthKitService(_ service: HealthKitService, didUpdateHeight height: Double) {
		//self?.training?.height = height as NSNumber
		if self.trainingInfo["startTime"] == nil {
			// If the training is not started yet I simply add the height info
			self.trainingInfo["height"] = height
		} else {
			// If the training is already started I send the weight info
			self.sendInfo(["height":height])
		}
	}
	
	// MARK: - SensorsRecorderDelegate
	func sensorsRecorder(_ recorder: SensorsRecorder, didExtractFeatures features: [String : Any]) {
		guard self.queue.size < self.queueLimit else {
			WKInterfaceDevice.current().play(.notification)
			self.pause()
			self.presentFullQueueAlert()
			return
		}
		var msgDict = features
		self.collectedInstances += 1
		msgDict["sequenceNumber"] = Int16(self.collectedInstances)
		//print(msgDict)
		
		// TODO: - Uncomment the following line if you want to update complications
		//WorkoutInfo.shared.update(withCollectedInstances: self.collectedInstances, deliveredInstances: self.deliveredInstances.count)
		self.sendInfo(["instance":msgDict])
	}
	
	func sensorsRecorder(_ recorder: SensorsRecorder, didChangefromSensorsState fromState: SensorsState, toState: SensorsState) {
		if self.recorder.isAccelerometerEnabled {
			if toState.isAccelerometerActive {
				accelerometerStateLabel.setText("Accelerometer ✅")
			} else {
				self.accelerometerStateLabel.setText("Accelerometer ❌")
			}
		} else {
			self.accelerometerStateLabel.setText("Accelerometer N/A")
		}
		
		if self.recorder.isGyroscopeEnabled {
			if toState.isGyroscopeActive {
				gyroscopeStateLabel.setText("Gyroscope ✅")
			} else {
				self.gyroscopeStateLabel.setText("Gyroscope ❌")
			}
		} else {
			self.gyroscopeStateLabel.setText("Gyroscope N/A")
		}
		
		if self.recorder.isGPSEnabled {
			if toState.isGPSActive {
				GPS_stateLabel.setText("GPS ✅")
			} else {
				self.GPS_stateLabel.setText("GPS ❌")
			}
		} else {
			self.GPS_stateLabel.setText("GPS N/A")
		}
	}
	
	// MARK: - MessageQueueDelegate
	func messageQueue(_ queue: MessageQueue, didDeliverMessage message: [String : Any], withReply: [String : Any]) {
		
		DispatchQueue.main.async {
			if self.recorder.sessionState == .ended && self.queue.isEmpty {
				self.doneButton.setHidden(false)
				
				if self.collectedInstances > 0 {
					self.summaryLabel.setHidden(false)
				}
			}
		}
		
		guard let instance = message["instance"] as? [String:Any] else { return }
		guard let sequenceNumber = instance["sequenceNumber"] as? Int16 else { return }
		DispatchQueue.main.async {
			self.deliveredInstances.insert(sequenceNumber)
			self.setInstancesLabelText()
			// TODO: - Uncomment the following line if you want to update complications
			//WorkoutInfo.shared.update(withCollectedInstances: self.collectedInstances, deliveredInstances: self.deliveredInstances.count)
		}
	}
	
	func messageQueue(_ queue: MessageQueue, didFailToDeliverMessage: [String : Any], retry: UnsafeMutablePointer<Bool>) {
		retry.pointee = true
	}
}







