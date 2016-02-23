//
//  Activity.swift
//  FlowLog
//
//  Created by Florian Pfisterer on 08/01/16.
//  Copyright © 2016 Florian Pfisterer. All rights reserved.
//

import Foundation
import CoreData

class Activity: NSManagedObject
{
    func getName() -> String
    {
        if let name = self.name
        {
            return name
        }
        return "Error"
    }
    
    class func randomActivity(context: NSManagedObjectContext) -> Activity
    {
        let activities = try! CoreDataHelper.fetchEntities("Activity", managedObjectContext: context, predicate: nil, sortDescriptor: nil) as! [Activity]
        return activities[Int(arc4random_uniform(UInt32(activities.count)))]
    }
}
