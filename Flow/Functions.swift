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

func getRelativeDateDescription(date: NSDate, time: Bool = false) -> String
{
    let dateDay = calendar.component(NSCalendarUnit.Day, fromDate: date)
    let nowDay = calendar.component(NSCalendarUnit.Day, fromDate: NSDate())
    
    var timeString = ""
    
    if time
    {
        timeString = ", \(StringHelper.getLocalizedTimeDescription(date))"
    }
    
    switch (dateDay - nowDay)
    {
    case 0:
        return TODAY + timeString
        
    case 1:
        return TOMORROW + timeString
        
    case let value where value > 1:
        return "in \(value) days" + timeString
        
    default:
        return "in \(dateDay - nowDay) days" + timeString
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
