//
//  Showhistory+CoreDataProperties.swift
//  Darshan_Mistry_FE_8967753
//
//  Created by user236106 on 4/17/24.
//
//

import Foundation
import CoreData


extension Showhistory {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Showhistory> {
        return NSFetchRequest<Showhistory>(entityName: "Showhistory")
    }

    @NSManaged public var cityName: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var distance: String?
    @NSManaged public var from: String?
    @NSManaged public var historyID: UUID?
    @NSManaged public var humidity: String?
    @NSManaged public var interactionType: String?
    @NSManaged public var modeOfTravel: String?
    @NSManaged public var newsAuthor: String?
    @NSManaged public var newsDescription: String?
    @NSManaged public var newsSource: String?
    @NSManaged public var newsTitle: String?
    @NSManaged public var temperature: String?
    @NSManaged public var to: String?
    @NSManaged public var weatherDate: String?
    @NSManaged public var weatherTime: String?
    @NSManaged public var windSpeed: String?

}

extension Showhistory : Identifiable {

}
