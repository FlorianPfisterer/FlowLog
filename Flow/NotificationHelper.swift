//
//  NotificationHelper.swift
//  Flow
//
//  Created by Florian Pfisterer on 04/01/16.
//  Copyright © 2016 Florian Pfisterer. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class NotificationHelper
{
    private static var currentAbsoluteMinutes = [Int]()
    
    // settings
    static var maySendNotifications: Bool {
        get
        {
            return NSUserDefaults.standardUserDefaults().boolForKey(MAY_SEND_NOTIFICATIONS_BOOL_KEY)
        }
        set (newValue)
        {
            NSUserDefaults.standardUserDefaults().setBool(newValue, forKey: MAY_SEND_NOTIFICATIONS_BOOL_KEY)
        }
    }
    
    
    // MARK: - helper functions
    class func unscheduleAllCurrentNotifications()
    {
        // unschedule scheduled notifications
        UIApplication.sharedApplication().cancelAllLocalNotifications()
    }
    
    class func shouldScheduleNotification() -> Bool
    {
        return Int(LogHelper.getCurrentLogNr()) <= FLOW_LOGS_PER_WEEK_COUNT
    }
    
    class func getLogIsDue() -> Bool
    {
        if let scheduledNotificationFireDate = UIApplication.sharedApplication().scheduledLocalNotifications?.first?.fireDate
        {
            // if it is after the current date, return true
            if NSDate().timeIntervalSinceReferenceDate > scheduledNotificationFireDate.timeIntervalSinceReferenceDate
            {
                return true
            }
        }
        
        return false
    }
    
    // schedules a new FlowLog Notification preferably at a time when there are few logs already existing => make analyses more exact
    class func scheduleNextNotification(starting startDate: NSDate = NSDate(),
        between startTime: Time = LogHelper.alarmStartTime,
        and endTime: Time = LogHelper.alarmEndTime,
        completion: ((success: Bool) -> Void)?)
    {
        if NotificationHelper.maySendNotifications
        {
            dispatch_async(dispatch_get_main_queue(), {
                
                let context = CoreDataHelper.managedObjectContext()
                
                // create the notification
                let notification = UILocalNotification()
                notification.timeZone = NSCalendar.currentCalendar().timeZone
                notification.soundName = UILocalNotificationDefaultSoundName
                notification.alertBody = NotificationHelper.getTitleForNotification()
                
                // standard values
                let today = NSDate()
                var day = startDate
                
                let nowTime = Time(date: NSDate())
                var earliestTimePossible = nowTime
                var hour: Int = nowTime.hour
                var minute: Int = nowTime.minute + 1
                
                // find out the ideal time for the notification
                // 1. find out day
                if isSameday(startDate, and: today)
                {
                    // check if there aren't enough notifications today already
                    let logsToday: Int = 3
                    
                    // if there are enough logs today already or it is already after the endTime currently
                    if logsToday >= 6 || earliestTimePossible.absoluteMinutes > endTime.absoluteMinutes
                    {
                        day = today.dateByAddingTimeInterval(NSTimeInterval(60*60*24))      // do it tomorrow
                        earliestTimePossible = startTime
                    }
                    else
                    {
                        // do it today
                    }
                }
                else
                {
                    earliestTimePossible = startTime
                }
                
                // 2. find out the perfect hour and set random minute
                
                // collect data to all hours
                var hoursWithLogs = [(hour: Int, logs: Int)]()
                for hour in startTime.hour...endTime.hour
                {
                    let logsInThatHour = AnalysisHelper.getNumberOfLogsInHour(hour, context: context)
                    hoursWithLogs.append((hour: hour, logs: logsInThatHour))
                }
                
                // sort the array to have the hours with the least existing logs first
                let sortedLogHours: [Int] = hoursWithLogs.sort({ $0.logs < $1.logs }).map({ $0.hour })
            
                if isSameday(day, and: today)       // if the log is to be scheduled today, we have to check that it is after the current time
                {
                    for testHour in sortedLogHours
                    {
                        if testHour >= nowTime.hour
                        {
                            hour = testHour
                            break
                        }
                    }
                    
                    // set minute
                    let currentMinuteOffset = UInt32(60 - nowTime.minute)
                    minute = Int(arc4random_uniform(currentMinuteOffset)) + nowTime.minute
                }
                else
                {
                    hour = sortedLogHours[0]
                    minute = Int(arc4random_uniform(60))    // random minute
                }
                
                // 3. finally, compose the fireDate and schedule the notification
                let dateComponents = calendar.components([.Day, .Month, .Year], fromDate: day)
                dateComponents.hour = hour
                dateComponents.minute = minute
                dateComponents.second = 59
                if let fireDate = calendar.dateFromComponents(dateComponents)
                {
                    notification.fireDate = fireDate
                    
                    UIApplication.sharedApplication().scheduleLocalNotification(notification)
                    print("scheduled notification at \(fireDate)")
                    
                    completion?(success: true)
                    return
                }
                else
                {
                    print("ERROR: couldn't compose notification fire date!")
                }
                
                completion?(success: false)
            })
        }
    }
    
    class func getTitleForNotification() -> String
    {
        return "Do a FlowLog now!"
    }
}