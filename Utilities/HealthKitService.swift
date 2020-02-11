//
//  Health.swift
//  Human Activity Recognition
//
//  Created by Ramy Al Zuhouri on 02/09/17.
//  Copyright © 2017 Ramy Al Zuhouri. All rights reserved.
//

import Foundation
import HealthKit

#if os(watchOS)
protocol HealthKitServiceDelegate : HKWorkoutSessionDelegate {
	func healthKitService(_ service:HealthKitService, didUpdateHeartRate heartRate:Double)
	func healthKitService(_ service:HealthKitService, didUpdateBodyMass bodyMass:Double)
	func healthKitService(_ service:HealthKitService, didUpdateHeight height:Double)
}
#endif

class HealthKitService
{
	// MARK: - Common
	static var healthStore = HKHealthStore()
	// Types to read/share
	static var workoutType = HKObjectType.workoutType()
	static var heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate)!
	@available(watchOSApplicationExtension 4.0, *) @available(iOS 11.0, *) static var restingHeartRateType = HKObjectType.quantityType(forIdentifier: .restingHeartRate)!
	static var energyType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!
	static var bodyMassType = HKObjectType.quantityType(forIdentifier: .bodyMass)!
	static var heightType = HKObjectType.quantityType(forIdentifier: .height)!
	static var dateOfBirthType = HKCharacteristicType.characteristicType(forIdentifier: .dateOfBirth)!
	static var biologicalSexType = HKCharacteristicType.characteristicType(forIdentifier: .biologicalSex)!
	
	// These values are fetched asynchronously only when the session starts
	var bodyMass:Double?  // Kilograms
	var height:Double?    // Meters
	
	// These values can be read immediately
	var age:Int?         // Years
	{
		do {
			let dateOfBirthComponents = try HealthKitService.healthStore.dateOfBirthComponents()
			if let dateOfBirth = Calendar.current.date(from: dateOfBirthComponents) {
				let ageComponents = Calendar.current.dateComponents([.year], from: dateOfBirth, to: Date())
				return ageComponents.year
			}
		}
		catch {
			print("Error fetching date of birth: \(error)")
		}
		return nil
	}
	var biologicalSex:HKBiologicalSex? {
		do {
			let sex = try HealthKitService.healthStore.biologicalSex().biologicalSex
			return sex
		} catch {
			print("Error feching biological sex: \(error)")
		}
		return nil
	}
	
	class func authorizeHealthKitAccess(_ completion: @escaping (Bool,Error?) -> Void)
	{
		if self.isAuthorized {
			return
		}
		
		let typesToShare = Set([
			workoutType,
			heartRateType,
			energyType
		])
		
		var typesToRead = Set([
			heartRateType,
			bodyMassType,
			heightType,
			dateOfBirthType,
			biologicalSexType
		])
		
		if #available(iOS 11.0, *) {
			if #available(watchOSApplicationExtension 4.0, *) {
				typesToRead = Set([
					heartRateType,
					restingHeartRateType,
					bodyMassType,
					heightType,
					dateOfBirthType,
					biologicalSexType
				])
			}
		}
		
		healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead, completion: {(success,error) in
			completion(success, error)
		})
	}
	
	class var isAuthorized:Bool {
		guard self.healthStore.authorizationStatus(for: self.workoutType) == .sharingAuthorized else { return false }
		guard self.healthStore.authorizationStatus(for: self.heartRateType) == .sharingAuthorized else { return false }
		guard self.healthStore.authorizationStatus(for: self.energyType) == .sharingAuthorized else { return false }
		return true
	}
	
	// MARK: - Watch OS Only
#if os(watchOS)
	var activity:String = "Other"
	var session:HKWorkoutSession
	var sessionState:HKWorkoutSessionState {
		return session.state
	}
	var heartRate:Double?
	weak var delegate:HealthKitServiceDelegate? {
		didSet {
			self.session.delegate = delegate
		}
	}
	
	convenience init?(activity:String) {
		var activityType:HKWorkoutActivityType
		var locationType:HKWorkoutSessionLocationType
	
		activityType = HKWorkoutActivityType.other
		locationType = HKWorkoutSessionLocationType.unknown
	
		self.init(activityType: activityType, locationType: locationType)
		self.activity = activity
	}
	
	init?(activityType:HKWorkoutActivityType, locationType:HKWorkoutSessionLocationType) {
		let configuration = HKWorkoutConfiguration()
		configuration.activityType = activityType
		configuration.locationType = locationType
		
		do {
			let session = try HKWorkoutSession(configuration: configuration)
			self.session = session
		} catch {
			print("Error initializing HealthKitService: \(error)")
			return nil
		}
	}
	
	deinit {
		print("healthKitService.deinit")
	}
	
	func startSession(monitorHeartRate:Bool = true) {
		HealthKitService.healthStore.start(session)
		if monitorHeartRate {
			self.startHeartRateQueries()
		}
		self.startBodyMassQuery()
		self.startHeightQuery()
	}
	
	func pauseSession(monitorHeartRate:Bool = true) {
		HealthKitService.healthStore.pause(session)
		if monitorHeartRate {
			self.stopHeartRateQueries()
		}
	}
	
	func stopSession(monitorHeartRate:Bool = true) {
		HealthKitService.healthStore.end(session)
		if monitorHeartRate {
			self.stopHeartRateQueries()
		}
	}
	
	func resumeSession(monitorHeartRate:Bool = true) {
		HealthKitService.healthStore.resumeWorkoutSession(session)
		if monitorHeartRate {
			self.startHeartRateQueries()
		}
	}
	
	var heartRateQueryAnchor:HKQueryAnchor?
	var heartRateQuery:HKAnchoredObjectQuery?
	
	private func startHeartRateQueries() {
		let startDate = Date()
		let predicate = HKQuery.predicateForSamples(withStart: startDate, end: nil, options: .strictEndDate)
		let handler = { (query:HKAnchoredObjectQuery, sampleObjects:[HKSample]?, deletedObjects:[HKDeletedObject]?, newAnchor:HKQueryAnchor?, error:Error?) in
			self.heartRateQueryAnchor = newAnchor
			// Check the Samples
			guard let samples = sampleObjects as? [HKQuantitySample], samples.count > 0 else {
				return
			}
			
			if let quantity = samples.last?.quantity {
				self.heartRate = quantity.doubleValue(for: HKUnit.init(from: "count/min"))
				self.delegate?.healthKitService(self, didUpdateHeartRate: self.heartRate!)
			}
		}
		
		let heartRateQuery = HKAnchoredObjectQuery(type: HealthKitService.heartRateType, predicate: predicate, anchor: heartRateQueryAnchor, limit: Int(HKObjectQueryNoLimit), resultsHandler: handler)
		
		heartRateQuery.updateHandler = handler
		HealthKitService.healthStore.execute(heartRateQuery)
		self.heartRateQuery = heartRateQuery
	}
	
	private func stopHeartRateQueries() {
		guard let query = self.heartRateQuery else { return }
		HealthKitService.healthStore.stop(query)
	}
#endif
	var bodyMassQuery:HKSampleQuery?
	private func startBodyMassQuery() {
		let predicate = HKQuery.predicateForSamples(withStart: Date.distantPast, end: Date.distantFuture, options: .init(rawValue: 0))
		let sort = [
			NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)
		]
		let bodyMassQuery = HKSampleQuery(sampleType: HealthKitService.bodyMassType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: sort) { (query, sampleObjects, error) in
			guard error == nil else {
				print("Error querying body mass: \(error!)")
				return
			}
			guard let samples = sampleObjects as? [HKQuantitySample], samples.count > 0 else {
				print("Body mass: fetched \(sampleObjects!.count) objects")
				return
			}
			guard let quantity = samples.last?.quantity else { return }
			let bodyMass = quantity.doubleValue(for: HKUnit.gram()) / 1000.0
			self.bodyMass = bodyMass
			#if os(watchOS)
			self.delegate?.healthKitService(self, didUpdateBodyMass: bodyMass)
			#endif
		}
		self.bodyMassQuery = bodyMassQuery
		HealthKitService.healthStore.execute(bodyMassQuery)
	}
	
	var heightQuery:HKSampleQuery?
	private func startHeightQuery() {
		let predicate = HKQuery.predicateForSamples(withStart: Date.distantPast, end: Date.distantFuture, options: .init(rawValue: 0))
		let sort = [
			NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)
		]
		let heightQuery = HKSampleQuery(sampleType: HealthKitService.heightType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: sort) { (query, sampleObjects, error) in
			guard error == nil else {
				print("Error querying height: \(error!)")
				return
			}
			guard let samples = sampleObjects as? [HKQuantitySample], samples.count > 0 else {
				print("Height: fetched \(sampleObjects!.count) objects")
				return
			}
			guard let quantity = samples.last?.quantity else { return }
			let height = quantity.doubleValue(for: HKUnit.meter())
			self.height = height
			#if os(watchOS)
			self.delegate?.healthKitService(self, didUpdateHeight: height)
			#endif
		}
		self.heightQuery = heightQuery
		HealthKitService.healthStore.execute(heightQuery)
	}
}







