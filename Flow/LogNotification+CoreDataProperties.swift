//
//  LogNotification+CoreDataProperties.swift
//  FlowLog
//
//  Created by Florian Pfisterer on 08/01/16.
//  Copyright © 2016 Florian Pfisterer. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension LogNotification {

    @NSManaged var done: Bool
    @NSManaged var dueDate: NSTimeInterval
    @NSManaged var nr: Int16
    @NSManaged var entry: LogEntry?

}
