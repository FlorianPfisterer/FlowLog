//
//  LogWeek+CoreDataProperties.swift
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

extension LogWeek
{
    @NSManaged var startDate: NSTimeInterval
    @NSManaged var entries: NSSet?
}
