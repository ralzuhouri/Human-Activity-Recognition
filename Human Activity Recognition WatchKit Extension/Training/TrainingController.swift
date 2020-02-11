//
//  TrainingController.swift
//  Human Activity Recognition WatchKit Extension
//
//  Created by Ramy Al Zuhouri on 02/09/17.
//  Copyright © 2017 Ramy Al Zuhouri. All rights reserved.
//

import WatchKit
import Foundation
import HealthKit
import WatchConnectivity

class TrainingController: WKInterfaceController {

	// MARK: - Table
	@IBOutlet var activitiesTable: WKInterfaceTable!
	lazy var activities:[String]? = {
		return Preferences.activities
	}()
	
	func loadTable()
	{
		guard let activities = self.activities else { return }
		
		activitiesTable.setNumberOfRows(activities.count, withRowType: "ActivityRowController")
		for (index,activity) in activities.enumerated() {
			guard let row = activitiesTable.rowController(at: index) as? ActivityRowController else {
				return
			}
			row.activityLabel.setText(activity)
		}
	}
	
	override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
		guard let activities = self.activities else { return }
		let activity = activities[rowIndex]
		
		guard SensorsRecorder.checkAuthorizations() else {
			let ok = WKAlertAction(title: "Ok", style: .default, handler: {})
			self.presentAlert(withTitle: "Cannot Start Activity", message: "You did not Grant All the Required Authorizations", preferredStyle: .alert, actions: [ok])
			return
		}
		
		let session = WCSession.default
		guard session.activationState == .activated && session.isReachable else {
			let ok = WKAlertAction(title: "Ok", style: .default, handler: {})
			self.presentAlert(withTitle: "Cannot Start Activity", message: "Your iPhone is not Reachable", preferredStyle: .alert, actions: [ok])
			return
		}
		
		DispatchQueue.main.async { [weak self] in
			guard let recorder = SensorsRecorder(activity:activity) else { return }
			self?.pushController(withName: "ActivityController", context: recorder)
		}
	}
	
	// MARK: -
	override init() {
		//self.recorder?.startSession()
		super.init()
		loadTable()
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "didUpdatePreferences"), object: nil)
		//self.recorder?.stopSession()
	}
	
	// MARK: - Callbacks
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
		NotificationCenter.default.addObserver(self, selector: #selector(self.didUpdatePreferences(notification:)), name: NSNotification.Name(rawValue: "didUpdatePreferences"), object: nil)
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
		
		let service = CoreLocationService()
		service.requestAuthorization()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
	
	@objc func didUpdatePreferences(notification:Notification) {
		self.loadTable()
	}
}









