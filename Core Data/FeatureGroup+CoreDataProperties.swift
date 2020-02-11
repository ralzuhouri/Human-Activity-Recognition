//
//  FeatureGroup+CoreDataProperties.swift
//  Human Activity Recognition
//
//  Created by Ramy Al Zuhouri on 14/11/17.
//  Copyright © 2017 Ramy Al Zuhouri. All rights reserved.
//
//

import Foundation
import CoreData


extension FeatureGroup {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FeatureGroup> {
        return NSFetchRequest<FeatureGroup>(entityName: "FeatureGroup")
    }

    @NSManaged public var data: String?
    @NSManaged public var deviation: NSNumber?
    @NSManaged public var energy: NSNumber?
    @NSManaged public var entropy: NSNumber?
    @NSManaged public var interQuartileRange: NSNumber?
    @NSManaged public var kurtosis: NSNumber?
    @NSManaged public var max: NSNumber?
    @NSManaged public var mean: NSNumber?
    @NSManaged public var median: NSNumber?
    @NSManaged public var min: NSNumber?
    @NSManaged public var skewness: NSNumber?
    @NSManaged public var variance: NSNumber?
    @NSManaged public var set: FeatureSet?

}
