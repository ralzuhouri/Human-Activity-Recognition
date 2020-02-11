//
//  Training+CoreDataProperties.swift
//  Human Activity Recognition
//
//  Created by Ramy Al Zuhouri on 14/11/17.
//  Copyright © 2017 Ramy Al Zuhouri. All rights reserved.
//
//

import Foundation
import CoreData

extension Training {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Training> {
        return NSFetchRequest<Training>(entityName: "Training")
    }

    @NSManaged public var activity: String?
    @NSManaged public var crownOrientation: Int16
    @NSManaged public var endTime: NSDate?
    @NSManaged public var overlappingWindows: Bool
    @NSManaged public var samplingFrequency: Int16
    @NSManaged public var startTime: NSDate?
    @NSManaged public var windowSize: Double
    @NSManaged public var wristLocation: Int16
    @NSManaged public var weight: NSNumber?
    @NSManaged public var height: NSNumber?
    @NSManaged public var gender: NSNumber?
    @NSManaged public var age: NSNumber?
    @NSManaged public var sets: NSSet?

}

// MARK: Generated accessors for sets
extension Training {

    @objc(addSetsObject:)
    @NSManaged public func addToSets(_ value: FeatureSet)

    @objc(removeSetsObject:)
    @NSManaged public func removeFromSets(_ value: FeatureSet)

    @objc(addSets:)
    @NSManaged public func addToSets(_ values: NSSet)

    @objc(removeSets:)
    @NSManaged public func removeFromSets(_ values: NSSet)

}
