//
//  ActivityHelper.swift
//  FlowLog
//
//  Created by Florian Pfisterer on 23.02.16.
//  Copyright © 2016 Florian Pfisterer. All rights reserved.
//

import Foundation
import CoreData

class ActivityHelper
{
    class func activityIsAlreadyAvailableWithName(name: String, context: NSManagedObjectContext) -> Activity?
    {
        let activities = AnalysisHelper.getSortedActivities(context: context)
        
        for activity in activities
        {
            if activity.name == name
            {
                return activity
            }
        }
        
        return nil
    }
}