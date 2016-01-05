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
    
    class func createNotificationsForDates(dates: [NSDate]) -> Bool
    {
        if NotificationHelper.maySendNotifications
        {
            var nr = 1
            for date in dates
            {
                let notification = UILocalNotification()
                
                notification.fireDate = date
                notification.timeZone = NSCalendar.currentCalendar().timeZone
                
                notification.alertBody = NotificationHelper.getTitleForNotification(nr: nr)
                
                notification.applicationIconBadgeNumber++
                
                notification.userInfo = [
                    LOG_NR_NOTIFICATION_INT_KEY : nr
                ]
                
                nr++
                
                UIApplication.sharedApplication().scheduleLocalNotification(notification)
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