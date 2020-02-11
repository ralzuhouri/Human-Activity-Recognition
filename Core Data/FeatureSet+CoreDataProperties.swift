//
//  FeatureSet+CoreDataProperties.swift
//  Human Activity Recognition
//
//  Created by Ramy Al Zuhouri on 14/11/17.
//  Copyright © 2017 Ramy Al Zuhouri. All rights reserved.
//
//

import Foundation
import CoreData


extension FeatureSet {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FeatureSet> {
        return NSFetchRequest<FeatureSet>(entityName: "FeatureSet")
    }

    @NSManaged public var sequenceNumber: Int16
    @NSManaged public var groups: NSSet?
    @NSManaged public var training: Training?

}

// MARK: Generated accessors for groups
extension FeatureSet {

    @objc(addGroupsObject:)
    @NSManaged public func addToGroups(_ value: FeatureGroup)

    @objc(removeGroupsObject:)
    @NSManaged public func removeFromGroups(_ value: FeatureGroup)

    @objc(addGroups:)
    @NSManaged public func addToGroups(_ values: NSSet)

    @objc(removeGroups:)
    @NSManaged public func removeFromGroups(_ values: NSSet)

}
