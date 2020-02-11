//
//  CoreLocationService.swift
//  Human Activity Recognition
//
//  Created by Ramy Al Zuhouri on 10/09/17.
//  Copyright © 2017 Ramy Al Zuhouri. All rights reserved.
//

import Foundation
import CoreLocation

protocol CoreLocationServiceDelegate : NSObjectProtocol
{
	func didChangeAuthorizationStatus(_ status:CLAuthorizationStatus)
}

class CoreLocationService : NSObject, CLLocationManagerDelegate
{
	let manager:CLLocationManager
	var location:CLLocation?
	weak var delegate:CoreLocationServiceDelegate?
	
	var isAuthorized:Bool {
		let authorizationStatus = CLLocationManager.authorizationStatus()
		return authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse
	}
	
	func requestAuthorization() {
		if self.isAuthorized { return }
		manager.requestWhenInUseAuthorization()
	}
	
	override init() {
		manager = CLLocationManager()
		super.init()
		manager.delegate = self
	}
	
	deinit {
		print("CoreLocationService.deinit")
	}
	
	func startUpdates() {
		manager.delegate = self
		manager.startUpdatingLocation()
	}
	
	func stopUpdates() {
		manager.delegate = nil
		manager.stopUpdatingLocation()
	}
	
	// MARK: - CLLocationManagerDelegate
	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		print("CLLocationManager Error: \(error)")
	}
	
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		self.location = locations.last
	}
	
	func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
		self.delegate?.didChangeAuthorizationStatus(status)
	}
}







