//
//  AppDelegate.swift
//  Human Activity Recognition
//
//  Created by Ramy Al Zuhouri on 02/09/17.
//  Copyright © 2017 Ramy Al Zuhouri. All rights reserved.
//

import UIKit
import HealthKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UITabBarControllerDelegate {
	
	var window: UIWindow?
	let healthStore = HKHealthStore()
	
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		// Override point for customization after application launch.
		Preferences.registerDefaults()
		Preferences.monitorChanges()
		
		let _ = SensorsRecorder.checkAuthorizations()
		
		let navigationController = self.window?.rootViewController
		guard let tabBarController = navigationController?.childViewControllers.first as? UITabBarController else { return true }
		tabBarController.delegate = self
		
		return true
	}
	
	func openSettings() {
		let settingsURL = URL(string: UIApplicationOpenSettingsURLString)!
		UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
	}
	
	func applicationWillResignActive(_ application: UIApplication) {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
	}
	
	func applicationDidEnterBackground(_ application: UIApplication) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	}
	
	func applicationWillEnterForeground(_ application: UIApplication) {
		// Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
	}
	
	func applicationDidBecomeActive(_ application: UIApplication) {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	}
	
	func applicationWillTerminate(_ application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	}
	
	// MARK: - UITabBarControllerDelegate
	func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
		if viewController.title == "Settings" {
			DispatchQueue.main.async { [weak self] in
				self?.openSettings()
			}
			return false
		}
		return true
	}
	
	// MARK: - HealthKit
	func applicationShouldRequestHealthAuthorization(_ application: UIApplication) {
		healthStore.handleAuthorizationForExtension(completion: {(success,error) in
		})
	}
}







