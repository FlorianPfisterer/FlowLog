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
    
    class func scheduleRandomNotificationsStarting(startDate: NSDate, between startTime: Time, and endTime: Time, completion: (success: Bool) -> Void)
    {
        NotificationHelper.currentAbsoluteMinutes.removeAll()
        var remainingNotificationsCount = FLOW_LOGS_PER_WEEK_COUNT
        let minutesDelta = endTime.absoluteMinutes - startTime.absoluteMinutes
        var dates = [NSDate]()
        
        let alarmsPerDay = [6, 5, 5, 6, 6, 7, 5]    // = 40     // TODO+: if first day is already gone => loop + moving to other days
        
        var day = 0
        for alarmsThisDay in alarmsPerDay
        {
            for _ in 1...alarmsThisDay
            {
                let thisDate = startDate.dateByAddingTimeInterval(Double(day * 60 * 60 * 24))    // day index multiplied by seconds per day
                let thisDateComponents = calendar.components([.Day, .Month, .Year], fromDate: thisDate)
                
                var randomTimeMinutes: Int! = Int(arc4random_uniform(UInt32(minutesDelta)))
                
                while (!NotificationHelper.absoluteMinutesIsValid(randomTimeMinutes, startTimeAbsMinutes: startTime.absoluteMinutes, onDate: thisDate))    // repeat while it's not valid
                {
                    randomTimeMinutes = Int(arc4random_uniform(UInt32(minutesDelta)))
                }
                
                let randomTime = Time(absoluteMinutes: randomTimeMinutes + startTime.absoluteMinutes)   // get time between specified bounds
                
                thisDateComponents.hour = randomTime.hour
                thisDateComponents.minute = randomTime.minute
                
                let dueDate = calendar.dateFromComponents(thisDateComponents)!
                dates.append(dueDate)
                NotificationHelper.currentAbsoluteMinutes.append(randomTimeMinutes)
            
                remainingNotificationsCount--
            }
            
            day++
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
    
    private static func absoluteMinutesIsValid(absoluteMinutes: Int, startTimeAbsMinutes: Int, onDate date: NSDate) -> Bool     // TODO! may produce ∞ loop
    {
        // first check if it's today and too close to the current moment
        if calendar.component(.Day, fromDate: NSDate()) == calendar.component(.Day, fromDate: date)
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
            if abs(existingAbsoluteMinute - absoluteMinutes) < 10   // no more than 1 notification in a 10 minute time frame
            {
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
                logNotification.dueDate = date.timeIntervalSince1970
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
        return "Notification TODO Nr. \(nr)"
    }
    
    // MARK: - Database Queries
    // checks if there are any overdue logs to do whose notifications haven't been clicked on / logs not completed
    // executed in viewDidAppear of StartVC
    class func getDueLogNofitications() -> (Bool, Int!)
    {
        let context = CoreDataHelper.managedObjectContext()
        
        do
        {
            let predicate = NSPredicate(format: "done == %@ AND dueDate < %@", NSNumber(bool: false), NSDate())        // not completed and overdue
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
    
    class func getNextNotificationDate() -> NSDate!
    {
        let context = CoreDataHelper.managedObjectContext()
        
        do
        {
            let predicate = NSPredicate(format: "done == %@ AND dueDate > %@", NSNumber(bool: false), NSDate())
            let sortDescriptor = NSSortDescriptor(key: "dueDate", ascending: true)
            
            let notifications = try CoreDataHelper.fetchEntities("LogNotification", managedObjectContext: context, predicate: predicate, sortDescriptor: sortDescriptor, limit: 1) as! [LogNotification]
            
            if let notification = notifications.first
            {
                return NSDate(timeIntervalSince1970: notification.dueDate)
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