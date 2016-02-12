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
    
    class func scheduleNextNotification(completion: (success: Bool) -> Void)
    {
        //let numberOfCompletedNotificationsToday = 0
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
                

                print("scheduled notifiation and saved to database nr. \(nr) on \(date)")   // TODO
                
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
}