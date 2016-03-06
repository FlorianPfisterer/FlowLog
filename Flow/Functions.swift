//
//  Functions.swift
//  FlowLog
//
//  Created by Florian Pfisterer on 12/02/16.
//  Copyright © 2016 Florian Pfisterer. All rights reserved.
//

import Foundation
import UIKit
import GoogleMobileAds

func setupBannerView(bannerView: GADBannerView, forAd: GoogleAdUnitID)
{
    bannerView.adUnitID = forAd.rawValue
    
    let request = GADRequest()
    request.testDevices = [kGADSimulatorID]
    bannerView.loadRequest(request)
}

func resetAllData()
{
    // 1. delete logs
    let context = CoreDataHelper.managedObjectContext()
    CoreDataHelper.deleteAllDataFromClassNames(["LogEntry"], fromContext: context)
    
    // 2. reset settings
    NSUserDefaults.standardUserDefaults().setBool(false, forKey: INTRO_DONE_BOOL_KEY)
    
    LogHelper.alarmStartTime = Time.standardStartTime
    LogHelper.alarmEndTime = Time.standardEndTime
    LogHelper.flowLogWeekStartDate = nil
    
    
    NotificationHelper.currentWeekIndex = 1
    NotificationHelper.logFireDateScheduledNotYetExecuted = nil
}

func getRelativeDateDescription(date: NSDate, time: Bool = false) -> String
{
    let nowComponents = calendar.components([.Day, .Month], fromDate: NSDate())
    let thenComponents = calendar.components([.Day, .Month], fromDate: date)
    
    if NSDate().timeIntervalSinceReferenceDate > date.timeIntervalSinceReferenceDate       // already overdue
    {
        return "now"
    }
    
    var dayDifference: Int = 1
    switch thenComponents.month - nowComponents.month
    {
    case 0:
        dayDifference = thenComponents.day - nowComponents.day
        
    case 1:
        dayDifference = Int((date.timeIntervalSinceReferenceDate - NSDate().timeIntervalSinceReferenceDate) / (60*60*24))
        
    default:
        return "in 30+ days"
    }
    
    var timeString = ""
    if time
    {
        timeString = ", \(StringHelper.getLocalizedTimeDescription(date))"
    }
    
    switch (dayDifference)
    {
    case 0:
        return "today" + timeString
        
    case 1:
        return "tomorrow" + timeString
        
    case let value where value > 1:
        return "in \(value) days" + timeString
        
    default:
        return "in \(dayDifference) days" + timeString
    }
}

func * (left: Vector2D, right: Vector2D) -> CGFloat
{
    return (left.dx * right.dx) + (left.dy * right.dy)
}

func isSameday(left: NSDate, and right: NSDate) -> Bool
{
    let leftComponents = calendar.components([NSCalendarUnit.Day, NSCalendarUnit.Month, NSCalendarUnit.Year], fromDate: left)
    let rightComponents = calendar.components([NSCalendarUnit.Day, NSCalendarUnit.Month, NSCalendarUnit.Year], fromDate: right)
    
    
    return leftComponents.day == rightComponents.day && leftComponents.month == rightComponents.month && leftComponents.year == rightComponents.year
}

func checkNotificationsEnabled(completion: (() -> Void)?) -> UIAlertController?
{
    if !NotificationHelper.maySendNotifications
    {
        let (title, message) = NOTIFICATIONS_DISABLED_ALERT_STRINGS
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .Default, handler: { _ in
            completion?()
        }))
        return alert
    }
    return nil
}

func handleAdBannerShowup(heightConstraint heightConstraint: NSLayoutConstraint, usualHeight: CGFloat = 50)
{
    if !internetConnectionAvailable()
    {
        heightConstraint.constant = 0
    }
    else
    {
        heightConstraint.constant = usualHeight
    }
}

//infix operator =!= { associativity left }
func == (lhs: NSIndexPath, rhs: (Int, Int)) -> Bool
{
    return lhs.section == rhs.0 && lhs.row == rhs.1
}

infix operator <=> { associativity left }
func <=> (frame: TimeFrame, date: NSDate) -> Bool
{
    let time = Time(date: date)
    
    if time.minute >= 30
    {
        return frame.startTime.hour == time.hour && frame.startTime.minute == 30
    }
    else
    {
        return frame.startTime.hour == time.hour
    }
}




















