//
//  NotificationHelper.swift
//  Flow
//
//  Created by Florian Pfisterer on 04/01/16.
//  Copyright © 2016 Florian Pfisterer. All rights reserved.
//

import Foundation
import UIKit

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
        UIApplication.sharedApplication().cancelAllLocalNotifications()
    }
    
    class func scheduleRandomNotificationsStarting(startDate: NSDate, between startTime: Time, and endTime: Time, completion: (success: Bool) -> Void)
    {
        NotificationHelper.currentAbsoluteMinutes.removeAll()
        var remainingNotificationsCount = FLOW_LOGS_PER_WEEK_COUNT
        let minutesDelta = endTime.absoluteMinutes - startTime.absoluteMinutes
        var dates = [NSDate]()
        
        let alarmsPerDay = [6, 5, 5, 6, 6, 7, 5]    // = 40
        
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
                
                dates.append(calendar.dateFromComponents(thisDateComponents)!)
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
            var nr = 1
            for date in dates.sort({ $0.timeIntervalSinceNow < $1.timeIntervalSinceNow })
            {
                let notification = UILocalNotification()
                
                notification.fireDate = date
                notification.timeZone = NSCalendar.currentCalendar().timeZone
                
                notification.alertBody = NotificationHelper.getTitleForNotification(nr: nr)
                
                notification.applicationIconBadgeNumber++
                
                notification.userInfo = [
                    LOG_NR_NOTIFICATION_INT_KEY : nr
                ]
                
                UIApplication.sharedApplication().scheduleLocalNotification(notification)

                print("scheduled notifiation nr. \(nr) on \(date)")
                
                nr++
            }
            
            return true
        }
        return false
    }
    
    class func getTitleForNotification(nr nr: Int) -> String
    {
        return "Notification TODO Nr. \(nr)"
    }
}