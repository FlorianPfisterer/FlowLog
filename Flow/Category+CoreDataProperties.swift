//
//  Category+CoreDataProperties.swift
//  FlowLog
//
//  Created by Florian Pfisterer on 14.02.16.
//  Copyright © 2016 Florian Pfisterer. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Category
{
    @NSManaged var name: String?
    @NSManaged var activities: NSSet?
}
