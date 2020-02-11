//
//  ViewController.swift
//  Human Activity Recognition
//
//  Created by Ramy Al Zuhouri on 02/09/17.
//  Copyright © 2017 Ramy Al Zuhouri. All rights reserved.
//

import UIKit
import WatchConnectivity

class PairingViewController: UIViewController, WCSessionDelegate
{
	// MARK: - Properties
	var updatePairingInformationInterval = 5.0
	var timer:Timer!
	@IBOutlet weak var sessionStateLabel: UILabel!
	@IBOutlet weak var instancesLabel: UILabel!
	@IBOutlet weak var showTrainingButton: UIButton!
	@IBOutlet weak var pairingLabel: UILabel!
	@IBOutlet weak var pauseButton: UIButton!
	@IBOutlet weak var resumeButton: UIButton!
	@IBOutlet weak var stopButton: UIButton!
	
	enum ActivityState {
		case notStarted, running, paused, ended, aborted
	}
	
	var session:WCSession {
		return WCSession.default
	}
	var activityState:ActivityState = .notStarted
	var training:Training?
	
	private var _controller:TrainingsController?
	var controller:TrainingsController {
		if _controller == nil {
			_controller = TrainingsController()
		}
		return _controller!
	}
	
	var collectedInstances = 0 {
		didSet {
			self.instancesLabel.text = "You Collected \(collectedInstances) Instances"
		}
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		
		let center = NotificationCenter.default
		center.addObserver(self, selector: #selector(self.didDeleteTraining(notification:)), name: NSNotification.Name(rawValue: "didDeleteTraining"), object: nil)
		
		//center.addObserver(self, selector: #selector(self.needsToSyncTrainings(notification:)), name: NSNotification.Name(rawValue: "needsToSyncTrainings"), object: nil)
	}
	
	deinit {
		self.timer.invalidate()
		
		let center = NotificationCenter.default
		center.removeObserver(self, name: NSNotification.Name(rawValue: "didAddTraining"), object: nil)
		//center.removeObserver(self, name: NSNotification.Name(rawValue: "needsToSyncTrainings"), object: nil)
	}
	
	func refreshPairingState() {
		if WCSession.isSupported() {
			pairingLabel.text = "Your Apple Watch is not Paired"
			self.disableAllButtons()
			
			if session.isPaired && session.isWatchAppInstalled {
				//print("Your Apple Watch is Paired")
				pairingLabel.text = "Your Apple Watch is Paired"
				self.refreshButtons()
			}
			
			if !session.isWatchAppInstalled {
				//print("Human Activity Recognition is not Installed on Your Apple Watch")
				pairingLabel.text = "Human Activity Recognition is not Installed on Your Apple Watch"
				self.disableAllButtons()
			}
		} else {
			//print("Watch Connectivity is not Supported on this Device")
			pairingLabel.text = "Watch Connectivity is not Supported on this Device"
			self.disableAllButtons()
		}
	}
	
	// MARK: - Notifications
	@objc func didDeleteTraining(notification:Notification) {
		// Disable the show training button?
	}
	
	@objc func needsToSyncTrainings(notification:Notification) {
		//self.sendDatasetStatus()
	}
	
	// MARK: - Events
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		if WCSession.isSupported() {
			session.delegate = self
			session.activate()
		}
		self.refreshPairingState()
		
		self.timer = Timer.scheduledTimer(withTimeInterval: updatePairingInformationInterval, repeats: true, block: { [weak self] timer in
			self?.refreshPairingState()
		})
		
		//self.sendDatasetStatus()
	}
	
	// MARK: - Actions
	func disableAllButtons() {
		pauseButton.isEnabled = false
		resumeButton.isEnabled = false
		stopButton.isEnabled = false
	}
	
	func refreshButtons() {
		switch activityState {
		case .notStarted, .ended, .aborted:
			self.disableAllButtons()
		case .running:
			self.pauseButton.isEnabled = true
			self.resumeButton.isEnabled = false
			self.stopButton.isEnabled = true
		case .paused:
			self.pauseButton.isEnabled = false
			self.resumeButton.isEnabled = true
			self.stopButton.isEnabled = true
		}
	}
	
	@IBAction func pause(_ sender: Any) {
		print("Sending pause command")
		let msg = [
			"type" : "command",
			"command":"pause"
		]
		self.sendCommand(msg)
	}
	
	@IBAction func resume(_ sender: Any) {
		print("Sending resume command")
		let msg = [
			"type" : "command",
			"command":"resume"
		]
		self.sendCommand(msg)
	}
	
	@IBAction func stop(_ sender: Any) {
		print("Sending stop command")
		let msg = [
			"type" : "command",
			"command":"stop"
		]
		self.sendCommand(msg)
	}
	
	/*@IBAction func showDatasetInfo(_ sender: Any) {
	// Not needed anymore: the dataset info are statistical info that show how many instances
	// every user (sorted by age) has collected for every activity. 
		guard let trainings = self.controller.trainings else { return }
		var dict:[Int:[String:Int]] = [:]
		
		for training in trainings {
			guard let activity = training.activity else { continue }
			guard let count = training.sets?.count else { continue }
			guard let age = training.age as? Int else { continue }
			
			var actDict = dict[age, default: [:]]
			var num = actDict[activity, default: 0]
			num += count
			actDict[activity] = num
			dict[age] = actDict
		}
		
		let alert = UIAlertController(title: "Dataset Summary", message: nil, preferredStyle: .alert)
		
		let ageArray = dict.keys.sorted()
		var text = "Age\t"
		for age in ageArray {
			text += "\(age)\t"
		}
		alert.addTextField(configurationHandler: { (textField) in
			textField.text = text
			textField.isEnabled = false
		})
		
		for activity in Preferences.activities.sorted() {
			text = "\(activity)\t"
			for age in ageArray {
				guard let actDict = dict[age] else { continue }
				let count = actDict[activity, default: 0]
				text += "\(count)\t"
			}
			
			alert.addTextField(configurationHandler: { (textField) in
				textField.text = text
				textField.isEnabled = false
			})
		}
		
		let ok = UIAlertAction(title: "Ok", style: .default, handler: nil)
		alert.addAction(ok)
		self.present(alert, animated: true, completion: nil)
	}*/

	// MARK: - Sending Data
	func sendCommand(_ command:[String:Any]) {
		self.disableAllButtons()
		let session = WCSession.default
		if session.isReachable && session.activationState == .activated {
			session.sendMessage(command, replyHandler: {reply in
			}, errorHandler: {error in
				print("Error sending command: \(error)")
			})
		}
	}
	
	/*func sendDatasetStatus() {
		DispatchQueue.main.async {
			print("Send application context")
			guard let trainings = self.controller.trainings else { return }
			
			var storedDates = [Date]()
			
			for training in trainings {
				guard let startTime = training.startTime as Date? else { continue }
				storedDates.append(startTime)
			}
			
			let msg:[String:Any] = [
				"type":"datasetStatus",
				"storedDates":storedDates
			]
			
			if self.session.isPaired && self.session.isReachable && self.session.activationState == .activated {
				self.session.sendMessage(msg, replyHandler: { (replyDict) in
				}, errorHandler: {error in
					print("\(error)")
				})
			}
		}
	}*/
	
	
	// MARK: - Navigation
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "showTraining" {
			guard let _ = segue.destination as? TrainingViewController else { return }
		}
	}
	
	// MARK: - WCSessionDelegate
	func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
		DispatchQueue.main.async { [weak self] in
			self?.refreshPairingState()
		}
	}
	
	func sessionWatchStateDidChange(_ session: WCSession) {
		DispatchQueue.main.async { [weak self] in
			self?.refreshPairingState()
		}
	}
	
	func sessionDidDeactivate(_ session: WCSession) {
		DispatchQueue.main.async { [weak self] in
			self?.refreshPairingState()
		}
		self.session.activate()
	}
	
	func sessionDidBecomeInactive(_ session: WCSession) {
		DispatchQueue.main.async { [weak self] in
			self?.refreshPairingState()
		}
	}
	
	/*func session(_ session: WCSession, didReceive file: WCSessionFile) {
		print("Session did receive file")
		
		DispatchQueue.main.async { [weak self] in
			defer {
				self?.sendDatasetStatus()
			}
			guard let dictionary = NSDictionary(contentsOf: file.fileURL) as? [String:Any] else { return }
			guard let startTime = dictionary["startTime"] as? Date else { return }
			guard self?.controller.training(withStartTime: startTime) == nil else { return }
			
			guard let _ = self?.controller.insertTraining(dictionary: dictionary) else { return }
			self?.controller.saveContext()
			self?._controller = nil
			print("Training imported with success")
			
			NotificationCenter.default.post(name: NSNotification.Name(rawValue: "didAddTraining"), object: nil)
		}
	}*/
	
	func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
		DispatchQueue.main.async {
			guard let type = message["type"] as? String else { return }
		
			if type == "prediction" {
				defer {
					replyHandler([:])
				}
				guard let state = message["state"] as? String else { return }
				if state == "started" {
					self.sessionStateLabel.text = "Testing Session Started"
				} else if state == "ended" {
					self.sessionStateLabel.text = "Testing Session Ended"
				} else if state == "predicting" {
					guard let prediction = message["prediction"] as? String else { return }
					self.sessionStateLabel.text = "Predicted Activity: \(prediction)"
				}
			} else if type == "command" {
				defer {
					replyHandler([:])
				}
				guard let command = message["command"] as? String else { return }
				guard let activity = message["activity"] as? String else { return }
				guard let time = message["time"] as? NSDate else { return }
				
				switch command {
				case "start":
					if self.activityState == .running {
						if let previousStartTime = self.training?.startTime {
							let components = Calendar.current.dateComponents([.second, .minute, .hour], from: previousStartTime as Date, to: time as Date)
							if let second = components.second, let minute = components.minute, let hour = components.hour {
								// If another training was started, I have to check that the second training was started at least
								// 10 seconds later, otherwise it may be a spurious message and I ignore it
								guard second >= 5 || minute >= 1 || hour >= 1 else { return }
							}
						}
					}
					self.activityState = .running
					self.sessionStateLabel.text = "\(activity) Session Started"
					self.collectedInstances = 0
					guard let trainingInfo = message["userInfo"] as? [String:Any] else { break }
					self.training = self.controller.insertTraining(dictionary: trainingInfo)
					self.training?.endTime = time
					self.controller.saveContext()
					NotificationCenter.default.post(name: NSNotification.Name(rawValue: "didAddTraining"), object: nil)
				case "pause":
					guard self.activityState != .paused else { break }
					self.activityState = .paused
					self.sessionStateLabel.text = "\(activity) Session Paused"
				case "resume":
					guard self.activityState != .running else { break }
					self.activityState = .running
					self.sessionStateLabel.text = "\(activity) Session Resumed"
				case "stop":
					guard self.activityState != .ended else { break }
					self.activityState = .ended
					self.sessionStateLabel.text = "\(activity) Session Ended"
					guard let userInfo = message["userInfo"] as? [String:Any] else { break }
					guard let endTime = userInfo["endTime"] as? NSDate else { break }
					self.training?.endTime = endTime
					guard let training = self.training else {
						break
					}
					self.controller.saveContext()
					NotificationCenter.default.post(name: NSNotification.Name(rawValue: "didEditDataset"), object: nil)
				default:
					break
				}
				self.refreshPairingState()
			} else if type == "info" {
				defer {
					replyHandler([:])
				}
				guard let state = message["state"] as? String else { return }
				guard let activity = message["activity"] as? String else { return }
				guard let training = self.training else { return }
				guard let time = message["time"] as? NSDate else { return }
				
				if let weight = message["weight"] as? Double {
					self.training?.weight = weight as NSNumber
				}
				if let height = message["height"] as? Double {
					self.training?.height = height as NSNumber
				}
				
				if let instance = message["instance"] as? [String:Any] {
					if let sequenceNumber = instance["sequenceNumber"] as? Int16 {
						if let sets = self.training?.sets as? Set<FeatureSet> {
							let sequenceNumbers = sets.map({ (set) -> Int16 in
								return set.sequenceNumber
							})
							if !sequenceNumbers.contains(sequenceNumber) {
								let _ = self.controller.insertFeatureSet(instance, inTraining: training)
								self.collectedInstances += 1
								self.training?.endTime = time
								self.controller.saveContext()
								NotificationCenter.default.post(name: NSNotification.Name(rawValue: "didEditDataset"), object: nil)
							}
						}
					}
				}
				
				switch state {
				case "running":
					self.activityState = .running
					self.sessionStateLabel.text = "\(activity) Session Running"
				case "notStarted":
					self.activityState = .notStarted
					self.sessionStateLabel.text = "\(activity) Session not Started yet"
				case "paused":
					self.activityState = .paused
					self.sessionStateLabel.text = "\(activity) Session Paused"
				case "ended":
					self.activityState = .ended
					self.sessionStateLabel.text = "\(activity) Session Ended"
				default:
					break
				}
				
				self.refreshPairingState()
			}
			else if type == "pullPreferences" {
				replyHandler(Preferences.dictionary)
			} else {
				replyHandler([:])
			}
		}
	}
	
}









