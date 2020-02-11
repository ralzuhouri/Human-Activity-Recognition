//
//  InstancesController.swift
//  Human Activity Recognition
//
//  Created by Ramy Al Zuhouri on 15/09/17.
//  Copyright © 2017 Ramy Al Zuhouri. All rights reserved.
//

import Foundation
import CoreData
import HealthKit
import WatchConnectivity

extension FeatureGroup {
	var numberOfValues:Int {
		var counter = 0
		
		if self.deviation != nil {
			counter += 1
		}
		if self.variance != nil {
			counter += 1
		}
		if self.interQuartileRange != nil {
			counter += 1
		}
		if self.kurtosis != nil {
			counter += 1
		}
		if self.max != nil {
			counter += 1
		}
		if self.mean != nil {
			counter += 1
		}
		if self.median != nil {
			counter += 1
		}
		if self.min != nil {
			counter += 1
		}
		if self.skewness != nil {
			counter += 1
		}
		if self.energy != nil {
			counter += 1
		}
		if self.entropy != nil {
			counter += 1
		}
		
		return counter
	}
	
 	func csvHeader() -> String
	{
		let parameter = self.data ?? "unknown"
		var csv = ""
		let features = [
			"max",
			"min",
			"median",
			"mean",
			"deviation",
			"variance",
			"skewness",
			"kurtosis",
			"IQR",
			"energy",
			"entropy"
		]
		
		for feature in features {
			csv += parameter + "-" + feature + ","
		}
		if !csv.isEmpty {
			csv.removeLast()
		}
		
		return csv
	}
	
	func csvString() -> String
	{
		var csv = ""
		let values = [
			self.max,
			self.min,
			self.median,
			self.mean,
			self.deviation,
			self.variance,
			self.skewness,
			self.kurtosis,
			self.interQuartileRange,
			self.energy,
			self.entropy
		]
		for value in values {
			var csvValue:String
			if value != nil {
				csvValue = "\(value!.doubleValue)"
			} else {
				csvValue = "n/a"
			}
			
			csv += csvValue + ","
		}
		if !csv.isEmpty {
			csv.removeLast()
		}
		
		return csv
	}
	
	func dictionary() -> [String:Any] {
		var dict:[String:Any] = [:]
		if let max = self.max as? Double {
			dict["max"] = max
		}
		if let min = self.min as? Double {
			dict["min"] = min
		}
		if let median = self.median as? Double {
			dict["median"] = median
		}
		if let mean = self.mean as? Double {
			dict["mean"] = mean
		}
		if let deviation = self.deviation as? Double {
			dict["deviation"] = deviation
		}
		if let variance = self.variance as? Double {
			dict["variance"] = variance
		}
		if let skewness = self.skewness as? Double {
			dict["skewness"] = skewness
		}
		if let kurtosis = self.kurtosis as? Double {
			dict["kurtosis"] = kurtosis
		}
		if let interQuartileRange = self.interQuartileRange as? Double {
			dict["interQuartileRange"] = interQuartileRange
		}
		if let energy = self.energy as? Double {
			dict["energy"] = energy
		}
		if let entropy = self.entropy as? Double {
			dict["entropy"] = entropy
		}
		return dict
	}
	
	static func == (left:FeatureGroup, right:FeatureGroup) -> Bool {
		guard left.max?.doubleValue == right.max?.doubleValue else { return false }
		guard left.min?.doubleValue == right.min?.doubleValue else { return false }
		guard left.median?.doubleValue == right.median?.doubleValue else { return false }
		guard left.mean?.doubleValue == right.mean?.doubleValue else { return false }
		guard left.deviation?.doubleValue == right.deviation?.doubleValue else { return false }
		guard left.variance?.doubleValue == right.variance?.doubleValue else { return false }
		guard left.skewness?.doubleValue == right.skewness?.doubleValue else { return false }
		guard left.kurtosis?.doubleValue == right.kurtosis?.doubleValue else { return false }
		guard left.interQuartileRange?.doubleValue == right.interQuartileRange?.doubleValue else { return false }
		guard left.energy?.doubleValue == right.energy?.doubleValue else { return false }
		guard left.entropy?.doubleValue == right.entropy?.doubleValue else { return false }
		return true
	}
}

extension FeatureSet {
	var numberOfValues:Int {
		var values = 0
		guard let set = self.groups as? Set<FeatureGroup> else { return 0 }
		for group in set {
			values += group.numberOfValues
		}
		return values
	}
	
	var heartRate:FeatureGroup? {
		guard let set = self.groups as? Set<FeatureGroup> else { return nil }
		
		let filteredGroups = set.filter { group -> Bool in
			return group.data == "heartRate"
		}
		guard let heartRate = filteredGroups.first else { return nil }
		return heartRate
	}
	
	var roll:FeatureGroup? {
		guard let set = self.groups as? Set<FeatureGroup> else { return nil }
		
		let filteredGroups = set.filter { group -> Bool in
			return group.data == "attitude-roll"
		}
		guard let roll = filteredGroups.first else { return nil }
		return roll
	}
	
	var pitch:FeatureGroup? {
		guard let set = self.groups as? Set<FeatureGroup> else { return nil }
		
		let filteredGroups = set.filter { group -> Bool in
			return group.data == "attitude-pitch"
		}
		guard let pitch = filteredGroups.first else { return nil }
		return pitch
	}
	
	var yaw:FeatureGroup? {
		guard let set = self.groups as? Set<FeatureGroup> else { return nil }
		
		let filteredGroups = set.filter { group -> Bool in
			return group.data == "attitude-yaw"
		}
		guard let yaw = filteredGroups.first else { return nil }
		return yaw
	}
	
	var attitudeMagnitude:FeatureGroup? {
		guard let set = self.groups as? Set<FeatureGroup> else { return nil }
		
		let filteredGroups = set.filter { group -> Bool in
			return group.data == "attitude-magnitude"
		}
		guard let attitudeMagnitude = filteredGroups.first else { return nil }
		return attitudeMagnitude
	}
	
	var xRotationRate:FeatureGroup? {
		guard let set = self.groups as? Set<FeatureGroup> else { return nil }
		
		let filteredGroups = set.filter { group -> Bool in
			return group.data == "rotationRate-x"
		}
		guard let xRotationRate = filteredGroups.first else { return nil }
		return xRotationRate
	}
	
	var yRotationRate:FeatureGroup? {
		guard let set = self.groups as? Set<FeatureGroup> else { return nil }
		
		let filteredGroups = set.filter { group -> Bool in
			return group.data == "rotationRate-y"
		}
		guard let yRotationRate = filteredGroups.first else { return nil }
		return yRotationRate
	}
	
	var zRotationRate:FeatureGroup? {
		guard let set = self.groups as? Set<FeatureGroup> else { return nil }
		
		let filteredGroups = set.filter { group -> Bool in
			return group.data == "rotationRate-z"
		}
		guard let zRotationRate = filteredGroups.first else { return nil }
		return zRotationRate
	}
	
	var rotationRateMagnitude:FeatureGroup? {
		guard let set = self.groups as? Set<FeatureGroup> else { return nil }
		
		let filteredGroups = set.filter { group -> Bool in
			return group.data == "rotationRate-magnitude"
		}
		guard let rotationRateMagnitude = filteredGroups.first else { return nil }
		return rotationRateMagnitude
	}
	
	var xGravity:FeatureGroup? {
		guard let set = self.groups as? Set<FeatureGroup> else { return nil }
		
		let filteredGroups = set.filter { group -> Bool in
			return group.data == "gravity-x"
		}
		guard let xGravity = filteredGroups.first else { return nil }
		return xGravity
	}
	
	var yGravity:FeatureGroup? {
		guard let set = self.groups as? Set<FeatureGroup> else { return nil }
		
		let filteredGroups = set.filter { group -> Bool in
			return group.data == "gravity-y"
		}
		guard let yGravity = filteredGroups.first else { return nil }
		return yGravity
	}
	
	var zGravity:FeatureGroup? {
		guard let set = self.groups as? Set<FeatureGroup> else { return nil }
		
		let filteredGroups = set.filter { group -> Bool in
			return group.data == "gravity-z"
		}
		guard let zGravity = filteredGroups.first else { return nil }
		return zGravity
	}
	
	var gravityMagnitude:FeatureGroup? {
		guard let set = self.groups as? Set<FeatureGroup> else { return nil }
		
		let filteredGroups = set.filter { group -> Bool in
			return group.data == "gravity-magnitude"
		}
		guard let gravityMagnitude = filteredGroups.first else { return nil }
		return gravityMagnitude
	}
	
	var xUserAcceleration:FeatureGroup? {
		guard let set = self.groups as? Set<FeatureGroup> else { return nil }
		
		let filteredGroups = set.filter { group -> Bool in
			return group.data == "userAcceleration-x"
		}
		guard let xUserAcceleration = filteredGroups.first else { return nil }
		return xUserAcceleration
	}
	
	var yUserAcceleration:FeatureGroup? {
		guard let set = self.groups as? Set<FeatureGroup> else { return nil }
		
		let filteredGroups = set.filter { group -> Bool in
			return group.data == "userAcceleration-y"
		}
		guard let yUserAcceleration = filteredGroups.first else { return nil }
		return yUserAcceleration
	}
	
	var zUserAcceleration:FeatureGroup? {
		guard let set = self.groups as? Set<FeatureGroup> else { return nil }
		
		let filteredGroups = set.filter { group -> Bool in
			return group.data == "userAcceleration-z"
		}
		guard let zUserAcceleration = filteredGroups.first else { return nil }
		return zUserAcceleration
	}
	
	var userAccelerationMagnitude:FeatureGroup? {
		guard let set = self.groups as? Set<FeatureGroup> else { return nil }
		
		let filteredGroups = set.filter { group -> Bool in
			return group.data == "userAcceleration-magnitude"
		}
		guard let userAccelerationMagnitude = filteredGroups.first else { return nil }
		return userAccelerationMagnitude
	}
	
	var latitude:FeatureGroup? {
		guard let set = self.groups as? Set<FeatureGroup> else { return nil }
		
		let filteredGroups = set.filter { group -> Bool in
			return group.data == "coordinate-latitude"
		}
		guard let latitude = filteredGroups.first else { return nil }
		return latitude
	}
	
	var longitude:FeatureGroup? {
		guard let set = self.groups as? Set<FeatureGroup> else { return nil }
		
		let filteredGroups = set.filter { group -> Bool in
			return group.data == "coordinate-longitude"
		}
		guard let longitude = filteredGroups.first else { return nil }
		return longitude
	}
	
	var altitude:FeatureGroup? {
		guard let set = self.groups as? Set<FeatureGroup> else { return nil }
		
		let filteredGroups = set.filter { group -> Bool in
			return group.data == "altitude"
		}
		guard let altitude = filteredGroups.first else { return nil }
		return altitude
	}
	
	var course:FeatureGroup? {
		guard let set = self.groups as? Set<FeatureGroup> else { return nil }
		
		let filteredGroups = set.filter { group -> Bool in
			return group.data == "course"
		}
		guard let course = filteredGroups.first else { return nil }
		return course
	}
	
	var speed:FeatureGroup? {
		guard let set = self.groups as? Set<FeatureGroup> else { return nil }
		
		let filteredGroups = set.filter { group -> Bool in
			return group.data == "speed"
		}
		guard let speed = filteredGroups.first else { return nil }
		return speed
	}
	
	var allGroups:[FeatureGroup?] {
		let groups:[FeatureGroup?] = [
			self.heartRate,
			self.roll,
			self.yaw,
			self.pitch,
			self.attitudeMagnitude,
			self.xRotationRate,
			self.yRotationRate,
			self.zRotationRate,
			self.rotationRateMagnitude,
			self.xGravity,
			self.yGravity,
			self.zGravity,
			self.gravityMagnitude,
			self.xUserAcceleration,
			self.yUserAcceleration,
			self.zUserAcceleration,
			self.userAccelerationMagnitude,
			self.latitude,
			self.longitude,
			self.altitude,
			self.course,
			self.speed
		]
		return groups
	}
	
	func csvHeader() -> String
	{
		var csv = ""
		let groups = self.allGroups
		for group in groups {
			if group != nil {
				csv += group!.csvHeader() + ","
			}
		}
		
		csv += "weight,height,age,gender,wristLocation,crownOrientation,activity"
		
		return csv
	}
	
	func csvString() -> String
	{
		var csv = ""
		
		let groups = self.allGroups
		
		for group in groups {
			if group != nil {
				csv += group!.csvString() + ","
			}
		}
		
		if let weight = self.training?.weight {
			csv += "\(weight),"
		} else {
			csv += "n/a,"
		}
		
		if let height = self.training?.height {
			csv += "\(height),"
		} else {
			csv += "n/a,"
		}
		
		if let age = self.training?.age {
			csv += "\(age),"
		} else {
			csv += "n/a,"
		}
		
		if let gender = self.training?.gender {
			if let biologicalSex = HKBiologicalSex(rawValue: gender.intValue) {
				switch biologicalSex {
				case .female:
					csv += "female,"
				case .male:
					csv += "male,"
				case .other:
					csv += "other,"
				case .notSet:
					csv += "not set,"
				}
			}
		} else {
			csv += "n/a,"
		}
		
		if let wristLocation = self.training?.wristLocation {
			csv += "\(wristLocation),"
		} else {
			csv += "n/a,"
		}
		
		if let crownOrientation = self.training?.crownOrientation {
			csv += "\(crownOrientation),"
		} else {
			csv += "n/a,"
		}
		
		if let activity = self.training?.activity {
			csv += "\(activity.lowercased())"
		} else {
			csv += "n/a"
		}
		
		return csv
	}
	
	func dictionary() -> [String:Any] {
		var dict:[String:Any] = [:]
		dict["sequenceNumber"] = self.sequenceNumber
		if let heartRate = self.heartRate {
			dict["heartRate"] = heartRate.dictionary()
		}
		if let roll = self.roll {
			dict["attitude-roll"] = roll.dictionary()
		}
		if let pitch = self.pitch {
			dict["attitude-pitch"] = pitch.dictionary()
		}
		if let yaw = self.yaw {
			dict["attitude-yaw"] = yaw.dictionary()
		}
		if let attitudeMagnitude = self.attitudeMagnitude {
			dict["attitude-magnitude"] = attitudeMagnitude.dictionary()
		}
		if let xRotationRate = self.xRotationRate {
			dict["rotationRate-x"] = xRotationRate.dictionary()
		}
		if let yRotationRate = self.yRotationRate {
			dict["rotationRate-y"] = yRotationRate.dictionary()
		}
		if let zRotationRate = self.zRotationRate {
			dict["rotationRate-z"] = zRotationRate.dictionary()
		}
		if let rotationRateMagnitude = self.rotationRateMagnitude {
			dict["rotationRate-magnitude"] = rotationRateMagnitude.dictionary()
		}
		if let xGravity = self.xGravity {
			dict["gravity-x"] = xGravity.dictionary()
		}
		if let yGravity = self.yGravity {
			dict["gravity-y"] = yGravity.dictionary()
		}
		if let zGravity = self.zGravity {
			dict["gravity-z"] = zGravity.dictionary()
		}
		if let gravityMagnitude = self.gravityMagnitude {
			dict["gravity-magnitude"] = gravityMagnitude.dictionary()
		}
		if let xUserAcceleration = self.xUserAcceleration {
			dict["userAcceleration-x"] = xUserAcceleration.dictionary()
		}
		if let yUserAcceleration = self.yUserAcceleration {
			dict["userAcceleration-y"] = yUserAcceleration.dictionary()
		}
		if let zUserAcceleration = self.zUserAcceleration {
			dict["userAcceleration-z"] = zUserAcceleration.dictionary()
		}
		if let userAccelerationMagnitude = self.userAccelerationMagnitude {
			dict["userAcceleration-magnitude"] = userAccelerationMagnitude.dictionary()
		}
		if let latitude = self.latitude {
			dict["coordinate-latitude"] = latitude.dictionary()
		}
		if let longitude = self.longitude {
			dict["coordinate-longitude"] = longitude.dictionary()
		}
		if let altitude = self.altitude {
			dict["altitude"] = altitude.dictionary()
		}
		if let course = self.course {
			dict["course"] = course.dictionary()
		}
		if let speed = self.speed {
			dict["speed"] = speed.dictionary()
		}
		return dict
	}
}

extension Training
{
	func csvHeader() -> String
	{
		var csv = ""
		if let set = self.sets?.anyObject() as? FeatureSet {
			csv += set.csvHeader()
		}
		
		return csv
	}
	
	func csvString() -> String
	{
		var csv = ""
		
		let sortDesc = NSSortDescriptor(key: "sequenceNumber", ascending: true)
		if let sets = self.sets!.sortedArray(using: [sortDesc]) as? [FeatureSet]
		{
			for set in sets {
				csv += set.csvString() + "\n"
			}
		}
		if !csv.isEmpty {
			csv.removeLast()
		}
		
		return csv
	}
	
	func dictionary() -> [String:Any] {
		var dict:[String:Any] = [:]
		
		dict["wristLocation"] = self.wristLocation
		dict["crownOrientation"] = self.crownOrientation
		dict["overlappingWindows"] = self.overlappingWindows
		dict["samplingFrequency"] = self.samplingFrequency
		dict["windowSize"] = self.windowSize
		
		if let activity = self.activity {
			dict["activity"] = activity
		}
		if let startTime = self.startTime {
			dict["startTime"] = startTime
		}
		if let endTime = self.endTime {
			dict["endTime"] = endTime
		}
		if let weight = self.weight {
			dict["weight"] = weight
		}
		if let height = self.height {
			dict["height"] = height
		}
		if let gender = self.gender {
			dict["gender"] = gender
		}
		if let age = self.age {
			dict["age"] = age
		}
		
		var instances:[[String:Any]] = []
		let sortDesc = NSSortDescriptor(key: "sequenceNumber", ascending: true)
		guard let sets = self.sets?.sortedArray(using: [sortDesc]) as? [FeatureSet] else { return dict }
		for set in sets {
			instances.append(set.dictionary())
		}
		dict["instances"] = instances
		
		return dict
	}
}

extension Array where Element == Training
{
	func anyNonEmptyTraining() -> Training? {
		let trainings = self.filter { (training:Training) -> Bool in
			if let count = training.sets?.count {
				return count > 0
			}
			return false
		}
		return trainings.first
	}
	
	func csvString() -> String
	{
		var csv = ""
		if let training = self.anyNonEmptyTraining() {
			csv += training.csvHeader() + "\n"
		}
		
		for training in self {
			csv += training.csvString() + "\n"
		}
		if !csv.isEmpty {
			csv.removeLast()
		}
		
		return csv
	}
}

class TrainingsController : NSObject
{
	let persistentContainer:NSPersistentContainer
	var context:NSManagedObjectContext {
		if background {
			return self.backgroundContext
		} else {
			return self.foregroundContext
		}
	}
	var foregroundContext:NSManagedObjectContext {
		return persistentContainer.viewContext
	}
	private var _backgroundContext:NSManagedObjectContext?
	var backgroundContext:NSManagedObjectContext {
		if _backgroundContext == nil {
			_backgroundContext = persistentContainer.newBackgroundContext()
		}
		return _backgroundContext!
	}
	var background = false
	
	override init() {
		persistentContainer = NSPersistentContainer(name: "Instances")
		persistentContainer.loadPersistentStores(completionHandler: {(description,error) in
			if let error = error {
				print("Failed to Load Core Data Stack: \(error)")
			}
		})
		super.init()
	}
	
	convenience init(background:Bool) {
		self.init()
		self.background = background
	}
	
	func saveContext() {
		if self.context.hasChanges {
			do {
				try self.context.save()
			} catch {
				print("Error Saving Context: \(error)")
			}
		}
	}
	
	func restore(fromURL url:URL) -> Bool {
		guard let trainingDicts = NSArray(contentsOf: url) as? [[String:Any]] else { return false }
		guard let trainings = self.trainings else { return false }
		
		for training in trainings {
			self.delete(object: training)
		}
		for trainingDict in trainingDicts {
			guard let _ = self.insertTraining(dictionary: trainingDict) else { return false }
		}
		return true
	}
	
	// MARK: - Serialization
	var data:Data? {
		guard let trainings = self.trainings else { return nil }
		var trainingDicts = [[String:Any]]()
		for training in trainings {
			trainingDicts.append(training.dictionary())
		}
		
		do {
			let data = try PropertyListSerialization.data(fromPropertyList: trainingDicts, format: .xml, options: 0)
			return data
		} catch {
			print("\(error)")
			return nil
		}
	}
	
	// MARK: - Insertion
	func insertFeatureGroup(_ groupDict:[String:Any], inSet set:FeatureSet, forData data:String) -> FeatureGroup? {
		guard let group = NSEntityDescription.insertNewObject(forEntityName: "FeatureGroup", into: self.context) as? FeatureGroup else { return nil }
		
		group.data = data
		group.set = set
		if let min = groupDict["min"] as? Double { group.min = min as NSNumber }
		if let max = groupDict["max"] as? Double { group.max = max as NSNumber }
		if let mean = groupDict["mean"] as? Double { group.mean = mean as NSNumber }
		if let median = groupDict["median"] as? Double { group.median = median as NSNumber }
		if let deviation = groupDict["deviation"] as? Double {
			group.deviation = deviation as NSNumber
		}
		if let variance = groupDict["variance"] as? Double {
			group.variance = variance as NSNumber
		}
		if let skewness = groupDict["skewness"] as? Double {
			group.skewness = skewness as NSNumber
		}
		if let kurtosis = groupDict["kurtosis"] as? Double {
			group.kurtosis = kurtosis as NSNumber
		}
		if let interQuartileRange = groupDict["interQuartileRange"] as? Double {
			group.interQuartileRange = interQuartileRange as NSNumber
		}
		if let energy = groupDict["energy"] as? Double { group.energy = energy as NSNumber }
		if let entropy = groupDict["entropy"] as? Double { group.entropy = entropy as NSNumber }
		return group
	}
	
	func insertFeatureSet(_ featuresDict:[String:Any], inTraining training:Training) -> FeatureSet? {
		guard let set = NSEntityDescription.insertNewObject(forEntityName: "FeatureSet", into: self.context) as? FeatureSet else { return nil }
		guard let sequenceNumber = featuresDict["sequenceNumber"] as? Int16 else { return nil }
		
		training.addToSets(set)
		set.training = training
		set.sequenceNumber = sequenceNumber
		set.groups = NSSet()
		
		if let heartRate = featuresDict["heartRate"] as? [String:Any] {
			if let group = insertFeatureGroup(heartRate, inSet: set, forData: "heartRate") {
				set.addToGroups(group)
			}
		}
		
		if let roll = featuresDict["attitude-roll"] as? [String:Any] {
			if let group = insertFeatureGroup(roll, inSet: set, forData: "attitude-roll") {
				set.addToGroups(group)
			}
		}
		
		if let pitch = featuresDict["attitude-pitch"] as? [String:Any] {
			if let group = insertFeatureGroup(pitch, inSet: set, forData: "attitude-pitch") {
				set.addToGroups(group)
			}
		}
		
		if let yaw = featuresDict["attitude-yaw"] as? [String:Any] {
			if let group = insertFeatureGroup(yaw, inSet: set, forData: "attitude-yaw") {
				set.addToGroups(group)
			}
		}
		
		if let attitudeMagnitude = featuresDict["attitude-magnitude"] as? [String:Any] {
			if let group = insertFeatureGroup(attitudeMagnitude, inSet: set, forData: "attitude-magnitude") {
				set.addToGroups(group)
			}
		}
		
		if let xRotationRate = featuresDict["rotationRate-x"] as? [String:Any] {
			if let group = insertFeatureGroup(xRotationRate, inSet: set, forData: "rotationRate-x") {
				set.addToGroups(group)
			}
		}
		
		if let yRotationRate = featuresDict["rotationRate-y"] as? [String:Any] {
			if let group = insertFeatureGroup(yRotationRate, inSet: set, forData: "rotationRate-y") {
				set.addToGroups(group)
			}
		}
		
		if let zRotationRate = featuresDict["rotationRate-z"] as? [String:Any] {
			if let group = insertFeatureGroup(zRotationRate, inSet: set, forData: "rotationRate-z") {
				set.addToGroups(group)
			}
		}
		
		if let rotationRateMagnitude = featuresDict["rotationRate-magnitude"] as? [String:Any] {
			if let group = insertFeatureGroup(rotationRateMagnitude, inSet: set, forData: "rotationRate-magnitude") {
				set.addToGroups(group)
			}
		}
		
		if let xGravity = featuresDict["gravity-x"] as? [String:Any] {
			if let group = insertFeatureGroup(xGravity, inSet: set, forData: "gravity-x") {
				set.addToGroups(group)
			}
		}
		
		if let yGravity = featuresDict["gravity-y"] as? [String:Any] {
			if let group = insertFeatureGroup(yGravity, inSet: set, forData: "gravity-y") {
				set.addToGroups(group)
			}
		}
		
		if let zGravity = featuresDict["gravity-z"] as? [String:Any] {
			if let group = insertFeatureGroup(zGravity, inSet: set, forData: "gravity-z") {
				set.addToGroups(group)
			}
		}
		
		if let gravityMagnitude = featuresDict["gravity-magnitude"] as? [String:Any] {
			if let group = insertFeatureGroup(gravityMagnitude, inSet: set, forData: "gravity-magnitude") {
				set.addToGroups(group)
			}
		}
		
		if let xUserAcceleration = featuresDict["userAcceleration-x"] as? [String:Any] {
			if let group = insertFeatureGroup(xUserAcceleration, inSet: set, forData: "userAcceleration-x") {
				set.addToGroups(group)
			}
		}
		
		if let yUserAcceleration = featuresDict["userAcceleration-y"] as? [String:Any] {
			if let group = insertFeatureGroup(yUserAcceleration, inSet: set, forData: "userAcceleration-y") {
				set.addToGroups(group)
			}
		}
		
		if let zUserAcceleration = featuresDict["userAcceleration-z"] as? [String:Any] {
			if let group = insertFeatureGroup(zUserAcceleration, inSet: set, forData: "userAcceleration-z") {
				set.addToGroups(group)
			}
		}
		
		if let userAccelerationMagnitude = featuresDict["userAcceleration-magnitude"] as? [String:Any] {
			if let group = insertFeatureGroup(userAccelerationMagnitude, inSet: set, forData: "userAcceleration-magnitude") {
				set.addToGroups(group)
			}
		}
		
		if let latitude = featuresDict["coordinate-latitude"] as? [String:Any] {
			if let group = insertFeatureGroup(latitude, inSet: set, forData: "coordinate-latitude") {
				set.addToGroups(group)
			}
		}
		
		if let longitude = featuresDict["coordinate-longitude"] as? [String:Any] {
			if let group = insertFeatureGroup(longitude, inSet: set, forData: "coordinate-longitude") {
				set.addToGroups(group)
			}
		}
		
		if let altitude = featuresDict["altitude"] as? [String:Any] {
			if let group = insertFeatureGroup(altitude, inSet: set, forData: "altitude") {
				set.addToGroups(group)
			}
		}
		
		if let course = featuresDict["course"] as? [String:Any] {
			if let group = insertFeatureGroup(course, inSet: set, forData: "course") {
				set.addToGroups(group)
			}
		}
		
		if let speed = featuresDict["speed"] as? [String:Any] {
			if let group = insertFeatureGroup(speed, inSet: set, forData: "speed") {
				set.addToGroups(group)
			}
		}
		
		return set
	}
	
	func insertTraining(activity:String) -> Training? {
		guard let training = NSEntityDescription.insertNewObject(forEntityName: "Training", into: self.context) as? Training else { return nil }
		training.activity = activity
		training.sets = NSSet()
		return training
	}
	
	func insertTraining(dictionary:[String:Any]) -> Training? {
		guard let activity = dictionary["activity"] as? String else { return nil }
		guard let training = self.insertTraining(activity: activity) else { return nil }
		
		if let wristLocation = dictionary["wristLocation"] as? Int16 {
			training.wristLocation = wristLocation
		}
		if let crownOrientation = dictionary["crownOrientation"] as? Int16 {
			training.crownOrientation = crownOrientation
		}
		if let overlappingWindows = dictionary["overlappingWindows"] as? Bool {
			training.overlappingWindows = overlappingWindows
		}
		if let samplingFrequency = dictionary["samplingFrequency"] as? Int16 {
			training.samplingFrequency = samplingFrequency
		}
		if let windowSize = dictionary["windowSize"] as? Double {
			training.windowSize = windowSize
		}
		if let startTime = dictionary["startTime"] as? NSDate {
			training.startTime = startTime
		}
		if let endTime = dictionary["endTime"] as? NSDate {
			training.endTime = endTime
		}
		if let weight = dictionary["weight"] as? NSNumber {
			training.weight = weight
		}
		if let height = dictionary["height"] as? NSNumber {
			training.height = height
		}
		if let gender = dictionary["gender"] as? NSNumber {
			training.gender = gender
		}
		if let age = dictionary["age"] as? NSNumber {
			training.age = age
		}
		
		guard let instances = dictionary["instances"] as? [[String:Any]] else { return training }
		for featuresDict in instances {
			let _ = self.insertFeatureSet(featuresDict, inTraining: training)
		}
		return training
	}
	
	// MARK: - Deletion
	func delete(object:NSManagedObject) {
		self.context.delete(object)
		self.saveContext()
	}
	
	// MARK: - Fetch
	var trainings:[Training]? {
		let request = NSFetchRequest<NSFetchRequestResult>()
		request.returnsObjectsAsFaults = false
		let entity = NSEntityDescription.entity(forEntityName: "Training", in: self.context)
		request.entity = entity
		
		let sortDesc = NSSortDescriptor(key: "startTime", ascending: false)
		request.sortDescriptors = [sortDesc]
		
		do {
			guard let trainings = try self.context.fetch(request) as? [Training] else {
				return nil
			}
			return trainings
		} catch {
			print("Error Fetching Trainings: \(error)")
			return nil
		}
	}
	
	func training(withStartTime startTime:Date) -> Training? {
		guard let trainings = self.trainings else { return nil }
		
		var calendar = Calendar.current
		if let timeZone = TimeZone(secondsFromGMT: 0) { calendar.timeZone = timeZone }
		
		for training in trainings {
			guard let date = training.startTime as Date? else { continue }
			let order = calendar.compare(startTime, to: date, toGranularity: .second)
			if order == .orderedSame { return training }
		}
		return nil
	}
	
#if os(watchOS)
	// MARK: - File Transfer
	private var tempFileURL:URL? {
		guard let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first as NSString? else { return nil }
		let filename = documentsDirectory.appendingPathComponent("TemporaryTrainingTransfer.xml")
		let fileURL = URL(fileURLWithPath: filename)
		return fileURL
	}
	
	func deleteTempFile() -> Bool {
		guard let tempFileURL = self.tempFileURL else { return false }
		guard WCSession.default.outstandingFileTransfers.count == 0 else { return false }
		guard FileManager.default.fileExists(atPath: tempFileURL.path) else { return false }
		do {
			try FileManager.default.removeItem(at: tempFileURL)
			return true
		} catch {
			print("Error removing temp file: \(error)")
		}
		return false
	}

	func transferTraining(_ training:Training) -> Bool {
		guard WCSession.isSupported() else { return false }
		let session = WCSession.default
		if session.activationState == .activated && session.isReachable {
			guard let fileURL = self.tempFileURL else { return false }
			
			do {
				let data = try PropertyListSerialization.data(fromPropertyList: training.dictionary(), format: .xml, options: 0)
				try data.write(to: fileURL)
				let _ = session.transferFile(fileURL, metadata: nil) // Return value: a WCSessionFileTransfer object
				return true
			} catch {
				print("\(error)")
				return false
			}
		}
		return false
	}
#endif

/*
#if os (iOS)
	// MARK: - iCloud Backup and Restore
	// Not fully working: for some reasons sometimes it may duplicate entires
	// probable reasons: (a) the persistent store is added instead than replaced?
	//					 (b) if the backup file already exists it may add the store twice?
	// Additional problem: it can't create the backup file in a subdirectory (see ICloudHelper)
	var helper:ICloudHelper?
	func saveICloudBackup(completionHandler: ((_ success:Bool) -> Void)?) {
		let helper = ICloudHelper()
		self.helper = helper
		helper.fileURLs(forFilename: "Backup.sqlite", inDirectory: nil) { [weak self] (urls, exists) in
			do {
				guard let backupURL = urls.first, backupURL != nil else { return }
				guard let model = self?.persistentContainer.persistentStoreCoordinator.managedObjectModel else {
					return
				}
				let storeCoordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
				guard let localStore = self?.persistentContainer.persistentStoreCoordinator.persistentStores.last else { return }
				guard let localStoreURL = localStore.url else { return }
				let newStore = try storeCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: localStoreURL, options: nil)
				let _ = try storeCoordinator.migratePersistentStore(newStore, to: backupURL!, options: nil, withType: NSSQLiteStoreType)
				completionHandler?(true)
				return
			} catch {
				print("Error backing up database: \(error)")
			}
			completionHandler?(false)
		}
	}
	
	func restoreICloudBackup(completionHandler: ((_ success:Bool) -> Void)?) {
		let helper = ICloudHelper()
		self.helper = helper
		helper.fileURLs(forFilename: "Backup.sqlite", inDirectory: nil) { [weak self] (urls, exists) in
			do {
				guard let backupURL = urls.first, backupURL != nil else { return }
				let storeCoordinator = self?.persistentContainer.persistentStoreCoordinator
				guard let localStore = storeCoordinator?.persistentStores.last else { return }
				guard let localStoreURL = localStore.url else { return }
				try storeCoordinator?.replacePersistentStore(at: localStoreURL, destinationOptions: nil, withPersistentStoreFrom: backupURL!, sourceOptions: nil, ofType: NSSQLiteStoreType)
				print("Restored database with success")
				completionHandler?(true)
				return
			} catch {
				print("Error backing up database: \(error)")
			}
			completionHandler?(false)
		}
	}
#endif
*/
}







