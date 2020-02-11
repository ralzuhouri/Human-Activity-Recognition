//
//  ExtensionDelegate.swift
//  Human Activity Recognition WatchKit Extension
//
//  Created by Ramy Al Zuhouri on 02/09/17.
//  Copyright © 2017 Ramy Al Zuhouri. All rights reserved.
//

import WatchKit
import WatchConnectivity
import ClockKit

class ExtensionDelegate: NSObject, WKExtensionDelegate, WCSessionDelegate
{
	func applicationDidFinishLaunching() {
		// Perform any final initialization of your application.
		Preferences.registerDefaults()
		
		if WCSession.isSupported() {
			let session = WCSession.default
			session.delegate = self
			session.activate()
		}
		
		let _ = SensorsRecorder.checkAuthorizations()
		
		// Since the shared decision tree instance is lazily loaded,
		// I pre-load it here to avoid computational overhead during the testing
		let _ = DecisionTree.shared()
		
		do {
			let logger = Logger.shared
			logger.clearLogs(itemsToKeep: 20)
			guard let logs = logger.allLogs() else { return }
			for (url, date) in logs {
				let text = try String(contentsOf: url)
				print("---------------------------------------------------------------")
				print("\(date)")
				print(text)
				print("---------------------------------------------------------------")
			}
		} catch {
			print("\(error)")
		}
	}
	
	func applicationDidBecomeActive() {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	}
	
	func applicationWillResignActive() {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, etc.
	}
	
	/*func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
		// Sent when the system needs to launch the application in the background to process tasks. Tasks arrive in a set, so loop through and process each one.
		for task in backgroundTasks {
			// Use a switch statement to check the task type
			switch task {
			case let backgroundTask as WKApplicationRefreshBackgroundTask:
				// Be sure to complete the background task once you’re done.
				backgroundTask.setTaskCompleted()
			case let snapshotTask as WKSnapshotRefreshBackgroundTask:
				// Snapshot tasks have a unique completion call, make sure to set your expiration date
				snapshotTask.setTaskCompleted(restoredDefaultState: true, estimatedSnapshotExpiration: Date.distantFuture, userInfo: nil)
			case let connectivityTask as WKWatchConnectivityRefreshBackgroundTask:
				// Be sure to complete the connectivity task once you’re done.
				connectivityTask.setTaskCompleted()
			case let urlSessionTask as WKURLSessionRefreshBackgroundTask:
				// Be sure to complete the URL session task once you’re done.
				urlSessionTask.setTaskCompleted()
			default:
				// make sure to complete unhandled task types
				task.setTaskCompleted()
			}
		}
	}*/
	
	func handleUserActivity(_ userInfo: [AnyHashable : Any]?) {
		guard let date = userInfo?[CLKLaunchedTimelineEntryDateKey] as? Date else { return }
		print("WatchKit Extension App Launched from Complication at Time \(date)")
	}
	
	// MARK: - WCSessionDelegate
	
	func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
		Preferences.pull()
	}
	
	func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
		defer {
			replyHandler([:])
		}
		guard let type = message["type"] as? String else { return }
		
		if type == "pushPreferences" {
			if let dict = message["preferences"] as? [String:Any] {
				print("Updating Preferences")
				Preferences.update(withDictionary: dict)
				NotificationCenter.default.post(name: NSNotification.Name(rawValue: "didUpdatePreferences"), object: nil)
				print("Updated Preferences")
			}
		} else if type == "command" {
			if let command = message["command"] as? String {
				print("Received remote command")
				NotificationCenter.default.post(name: NSNotification.Name(rawValue: "didReceiveRemoteCommand"), object: nil, userInfo:
					[
						"command":command
					])
			}
		} else if type == "datasetStatus" {
			guard let storedDates = message["storedDates"] as? [Date] else { return }
			let center = NotificationCenter.default
			center.post(name: NSNotification.Name(rawValue: "didUpdateStoredDates"), object: nil, userInfo: ["storedDates":storedDates])
		}
	}
}








