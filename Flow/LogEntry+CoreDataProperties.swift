//
//  LogEntry+CoreDataProperties.swift
//  FlowLog
//
//  Created by Florian Pfisterer on 12/02/16.
//  Copyright © 2016 Florian Pfisterer. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension LogEntry
{
    @NSManaged var createdAt: NSTimeInterval
    @NSManaged var energyLevel: Float
    @NSManaged var flowStateIndex: Int16
    @NSManaged var happinessLevel: Float
    @NSManaged var logNr: Int16
    @NSManaged var activity: Activity?
}
