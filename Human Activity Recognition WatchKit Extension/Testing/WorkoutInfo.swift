//
//  WorkoutStatus.swift
//  Human Activity Recognition WatchKit Extension
//
//  Created by Ramy Al Zuhouri on 19/11/17.
//  Copyright © 2017 Ramy Al Zuhouri. All rights reserved.
//

import HealthKit

enum SessionStatus:Int {
	case notStarted, started, paused, resumed, stopped
	
	var text:String {
		switch self {
		case .notStarted:
			return "Session not Started"
		case .started:
			return "Session Started"
		case .paused:
			return "Session Paused"
		case .resumed:
			return "Session Resumed"
		case .stopped:
			return "Session Stopped"
		}
	}
	
	var shortText:String {
		switch self {
		case .notStarted:
			return "Not Started"
		case .started:
			return "Started"
		case .paused:
			return "Paused"
		case .resumed:
			return "Resumed"
		case .stopped:
			return "Stopped"
		}
	}
	
}

class WorkoutInfo
{
	var sessionStatus:SessionStatus = .notStarted
	var collectedInstances = 0
	var deliveredInstances = 0
	
	private init() {}
	private static var _shared:WorkoutInfo?
	
	class var shared: WorkoutInfo {
		if _shared == nil {
			_shared = WorkoutInfo()
		}
		return _shared!
	}
	
	var instancesText:String {
		if collectedInstances == 0 {
			return "No Instances Collected"
		} else {
			return "Instances Collected: \(collectedInstances)/\(deliveredInstances)"
		}
	}
	
	var instancesShortText:String {
		if collectedInstances == 0 {
			return "No Instances"
		} else {
			return "Instances: \(deliveredInstances)/\(collectedInstances)"
		}
	}
	
	var sessionStatusText:String {
		return sessionStatus.text
	}
	
	var sessionStatusShortText:String {
		return sessionStatus.shortText
	}
	
	func update(withSessionStatus sessionStatus:SessionStatus, collectedInstances:Int, deliveredInstances: Int)
	{
		self.sessionStatus = sessionStatus
		self.update(withCollectedInstances: collectedInstances, deliveredInstances: deliveredInstances)
	}
	
	func update(withCollectedInstances collectedInstances:Int, deliveredInstances: Int) {
		self.collectedInstances = collectedInstances
		self.deliveredInstances = deliveredInstances
		DispatchQueue.main.async {
			ComplicationController.reloadData()
		}
	}
}







