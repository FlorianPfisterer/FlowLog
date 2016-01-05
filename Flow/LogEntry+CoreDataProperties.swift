//
//  LogEntry+CoreDataProperties.swift
//  Flow
//
//  Created by Florian Pfisterer on 05/01/16.
//  Copyright © 2016 Florian Pfisterer. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension LogEntry
{
    @NSManaged var occupationIndex: Int16
    @NSManaged var happinessLevel: Float
    @NSManaged var energyLevel: Float
    @NSManaged var flowStateIndex: Int16
    @NSManaged var logNr: Int16
    @NSManaged var week: NSManagedObject?
}
