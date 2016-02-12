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
    class func unscheduleAllCurrentNotifications(deleteData: Bool)
    {
        // unschedule scheduled notifications
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        
        if deleteData
        {
            // delete notification and log entries from database
            let context = CoreDataHelper.managedObjectContext()
            do
            {
                let notifications = try CoreDataHelper.fetchEntities("LogNotification", managedObjectContext: context, predicate: nil, sortDescriptor: nil) as! [LogNotification]
                let entries = try CoreDataHelper.fetchEntities("LogEntry", managedObjectContext: context, predicate: nil, sortDescriptor: nil) as! [LogEntry]
                
                for array in [notifications, entries]
                {
                    CoreDataHelper.deleteObjectsInArray(array as! [NSManagedObject], fromContext: context)
                }
            }
            catch
            {
                print("ERROR unscheduling old notifications and deleting from database: \(error)")
            }
        }
    }
    
    class func scheduleNextNotification(completion: (success: Bool) -> Void)
    {
        let numberOfCompletedNotificationsToday = 0
    }
    
    class func scheduleRandomNotificationsStarting(startDate: NSDate, between startTime: Time, and endTime: Time, progressView: UIProgressView, completion: (success: Bool) -> Void)
    {
        NotificationHelper.currentAbsoluteMinutes.removeAll()
        var remainingNotificationsCount = FLOW_LOGS_PER_WEEK_COUNT
        let minutesDelta = endTime.absoluteMinutes - startTime.absoluteMinutes
        let initialProgress = progressView.progress
        var dates = [NSDate]()
        
        var alarmsPerDay = [5, 6, 5, 7, 6, 5, 6]            // == 40 (Standard)
        
        if isSameday(startDate, and: NSDate())
        {
            let timeNow = Time(date: NSDate())
            let minutesDifference = endTime.absoluteMinutes - timeNow.absoluteMinutes
            
            switch minutesDifference
            {
            case let value where value < 30:                            // it's already to late for alarms today
                alarmsPerDay = [0, 6, 5, 4, 7, 7, 5, 6]     // == 40
                
            case 30...80:                                               // make some today, but not too much
                alarmsPerDay = [3, 6, 6, 7, 7, 5, 6]        // == 40
                
            case 101...150:                                             // make more today
                alarmsPerDay = [4, 6, 6, 7, 6, 5, 6]        // == 40
                
            default:
                alarmsPerDay = [5, 6, 5, 7, 6, 5, 6]        // == 40
            }
        }
 
        var day = 0
        for alarmsThisDay in alarmsPerDay
        {
            if alarmsThisDay != 0
            {
                for _ in 1...alarmsThisDay
                {
                    let thisDate = startDate.dateByAddingTimeInterval(Double(day * 60 * 60 * 24))    // day index multiplied by seconds per day
                    let thisDateComponents = calendar.components([.Day, .Month, .Year], fromDate: thisDate)
                    
                    var randomTimeMinutes: Int! = Int(arc4random_uniform(UInt32(minutesDelta)))
                    
                    while (!NotificationHelper.absoluteMinutesIsValid(randomTimeMinutes, startTimeAbsMinutes: startTime.absoluteMinutes, onDate: thisDate))    // repeat until it's valid
                    {
                        randomTimeMinutes = Int(arc4random_uniform(UInt32(minutesDelta)))
                    }
                    
                    let randomTime = Time(absoluteMinutes: randomTimeMinutes + startTime.absoluteMinutes)   // get time between specified bounds
                    
                    thisDateComponents.hour = randomTime.hour
                    thisDateComponents.minute = randomTime.minute
                    
                    let dueDate = calendar.dateFromComponents(thisDateComponents)!
                    dates.append(dueDate)
                    NotificationHelper.currentAbsoluteMinutes.append(randomTimeMinutes)
                    
                    let newProgress = initialProgress + (1-initialProgress) * (1/Float(remainingNotificationsCount))
                    progressView.setProgress(newProgress, animated: true)
                    
                    remainingNotificationsCount--
                }
                
                day++
            }
        }
        
        if remainingNotificationsCount != 0
        {
            print("ERROR: scheduled more or less notifications than planned: \(remainingNotificationsCount)")
            completion(success: false)
        }
        else
        {
            completion(success: NotificationHelper.createNotificationsForDates(dates))
        }
    }
    
    private static func absoluteMinutesIsValid(absoluteMinutes: Int, startTimeAbsMinutes: Int, onDate date: NSDate) -> Bool
    {
        // first check if it's today and too close to the current moment
        if isSameday(date, and: NSDate())
        {
            let currentAbsoluteMinutes = Time(date: NSDate()).absoluteMinutes - startTimeAbsMinutes
            
            if absoluteMinutes - currentAbsoluteMinutes < 2     // if it is before or fewer than 2 minutes after the current moment
            {
                return false
            }
        }
        
        // then check existing times
        for existingAbsoluteMinute in NotificationHelper.currentAbsoluteMinutes
        {
            if abs(existingAbsoluteMinute - absoluteMinutes) < 2   // no more than 1 notification in a 4 minute time frame
            {
                print("2 existingAbsM: \(existingAbsoluteMinute), absm: \(absoluteMinutes)")
                
                return false
            }
        }
        
        return true
    }
    
    class func createNotificationsForDates(dates: [NSDate]) -> Bool
    {
        if NotificationHelper.maySendNotifications
        {
            let context = CoreDataHelper.managedObjectContext()
            var nr = 1
            
            for date in dates.sort({ $0.timeIntervalSinceNow < $1.timeIntervalSinceNow })
            {
                let notification = UILocalNotification()
                
                notification.fireDate = date
                notification.timeZone = NSCalendar.currentCalendar().timeZone
                
                notification.alertBody = NotificationHelper.getTitleForNotification(nr: nr)
                
                notification.userInfo = [
                    LOG_NR_NOTIFICATION_INT_KEY : nr
                ]
                
                UIApplication.sharedApplication().scheduleLocalNotification(notification)
                
                // create notification object in database
                let logNotification = CoreDataHelper.insertManagedObject("LogNotification", managedObjectContext: context) as! LogNotification
                logNotification.dueDate = date.timeIntervalSinceReferenceDate
                logNotification.nr = Int16(nr)  // starting at 1
                logNotification.done = false

                print("scheduled notifiation and saved to database nr. \(nr) on \(date)")
                
                nr++
            }
            
            try! context.save()
            
            return true
        }
        return false
    }
    
    class func getTitleForNotification(nr nr: Int) -> String
    {
        return "Do a FlowLog now!"
    }
    
    // MARK: - Database Queries
    // checks if there are any overdue logs to do whose notifications haven't been clicked on / logs not completed
    // executed in viewDidAppear of StartVC
    class func getDueLogNofitications() -> (Bool, Int!)
    {
        let context = CoreDataHelper.managedObjectContext()
        
        do
        {
            let predicate = NSPredicate(format: "done == %@ AND dueDate <= %@", NSNumber(bool: false), NSDate())        // not completed and overdue
            let sortDescriptor = NSSortDescriptor(key: "nr", ascending: true)      // first notifications first
            
            let notifications = try CoreDataHelper.fetchEntities("LogNotification", managedObjectContext: context, predicate: predicate, sortDescriptor: sortDescriptor)  as! [LogNotification]
            
            print("INFO: \(notifications.count) overdue notification(s) found")
            if notifications.count > 0      // there is at least one overdue notification
            {
                return (true, Int(notifications.first!.nr))
            }
        }
        catch
        {
            print("ERROR fetching due notifications: \(error)")
        }
        
        
        return (false, nil)
    }
    
    class func getLogNotificationFromLogNr(nr: Int) -> LogNotification!
    {
        let context = CoreDataHelper.managedObjectContext()
        
        do
        {
            let predicate = NSPredicate(format: "nr == %d && done == %@", Int16(nr), NSNumber(bool: false))
            
            let notifications = try CoreDataHelper.fetchEntities("LogNotification", managedObjectContext: context, predicate: predicate, sortDescriptor: nil, limit: 1) as! [LogNotification]
            
            if let notification = notifications.last
            {
                return notification
            }
            else
            {
                print("ERROR fetching undone notification with nr \(nr)")
            }
        }
        catch
        {
            print("ERROR fetching undone notification with nr \(nr): \(error)")
        }
        
        return nil  // problem !
    }
    
    class func getNextNotificationDate() -> NSDate?
    {
        let context = CoreDataHelper.managedObjectContext()
        
        do
        {
            let now = NSDate()
            let predicate = NSPredicate(format: "done == %@ AND dueDate > %@", NSNumber(bool: false), now)
            let sortDescriptor = NSSortDescriptor(key: "dueDate", ascending: true)
            
            let notifications = try CoreDataHelper.fetchEntities("LogNotification", managedObjectContext: context, predicate: predicate, sortDescriptor: sortDescriptor, limit: 1) as! [LogNotification]
            
            if let notification = notifications.first
            {
                return NSDate(timeIntervalSinceReferenceDate: notification.dueDate)
            }
            else
            {
                print("trying to fetch next due notification, but no notifications found. Returning nil")
                return nil
            }
        }
        catch
        {
            print("ERROR fetching next undone notification with: \(error)")
        }
        
        return nil
    }
}