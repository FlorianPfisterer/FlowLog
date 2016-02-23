//
//  DBSeedHelper.swift
//  FlowLog
//
//  Created by Florian Pfisterer on 08/01/16.
//  Copyright © 2016 Florian Pfisterer. All rights reserved.
//

import Foundation
import CoreData

class DBSeedHelper
{
    static let activityNames = [
        "Working out",
        "Listening to music",
        "Resting",
        "Programming",
        "Cooking",
        "Eating alone",
        "Eating together",
        "Hanging out",
        "Hanging out alone",
        "Reading (fiction)",
        "Reading (non-fiction)",
        "Reading (news)",
        "Studying",
        "Working (day job)",
        "Working (side project)",
        "Watching TV",
        "Watching videos",
        "Playing computer games",
        "Talking",
        "Talking on the phone",
        "Relaxing",
        "Being on the run",
        "Sightseeing",
        "Shopping alone",
        "Shopping together",
        "Online-Shopping",
        "Creating something",
        "Thinking",
        "Procrastinating",
        "Cleaning",
        "Household",
        "Writing",
        "Sunbathing",
        "Sleeping",
        "Writing E-Mail",
        "Scheduling/Planning",
        "Waiting",
        "Taking notes",
        "Designing",
        "Crafting something (DIY)",
        "Teaching",
        "Listening to audiobook",
        "Learning new things",
        "Styling",
        "Meditating"]
    
    class func seedActivities()
    {
        let context = CoreDataHelper.managedObjectContext()
        
        for name in DBSeedHelper.activityNames.sort()
        {
            let activity = CoreDataHelper.insertManagedObject("Activity", managedObjectContext: context) as! Activity
            activity.name = name
            activity.used = 0
        }
        
        try! context.save()
    }
}

extension DBSeedHelper
{
    class func seedLogs(count: Int = 25)
    {
        let context = CoreDataHelper.managedObjectContext()
        
        for nr in 1...count
        {
            LogHelper.currentActivity = Activity.randomActivity(context)
            LogHelper.happinessLevel = Float(arc4random_uniform(100)) / 100
            LogHelper.energyLevel = Float(arc4random_uniform(100)) / 100
            LogHelper.flowState = FlowState(rawValue: Int16(arc4random_uniform(7) + 1))!
            
            let logEntry = CoreDataHelper.insertManagedObject("LogEntry", managedObjectContext: context) as! LogEntry
            logEntry.logNr = LogHelper.getCurrentLogNr()
            
            logEntry.activity = LogHelper.currentActivity
            logEntry.happinessLevel = LogHelper.happinessLevel
            logEntry.energyLevel = LogHelper.energyLevel
            logEntry.flowStateIndex = LogHelper.flowState.rawValue
            logEntry.createdAt = NSDate().dateByAddingTimeInterval(60*60*Double(nr)).timeIntervalSinceReferenceDate
            
            LogHelper.currentActivity.used = LogHelper.currentActivity.used + 1
        }
        
        try! context.save()
    }
}






















