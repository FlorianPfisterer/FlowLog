//
//  Constants.swift
//  Flow
//
//  Created by Florian Pfisterer on 03/01/16.
//  Copyright © 2016 Florian Pfisterer. All rights reserved.
//

import Foundation
import UIKit

// MARK: - Keys
let INTRO_DONE_BOOL_KEY = "intro_done_bool"
let MAY_SEND_NOTIFICATIONS_BOOL_KEY = "may_send_notifications_bool"
let LOG_NR_NOTIFICATION_INT_KEY = "log_nr_notification_int"
let ALARM_START_DATE_KEY = "alarm_start_date"
let ALARM_END_DATE_KEY = "alarm_end_date"
let ALARM_SOUND_FILE_NAME_STRING_KEY = "alarm_sound_file_name_string"
let CURRENT_FLOW_LOG_COUNT_INT_KEY = "current_flow_log_count_int"
let DATABASE_ACTIVITIES_SEED_DONE_BOOL_KEY = "database_activities_seed_done_bool"

let FLOW_LOG_WEEK_START_DATE_KEY = "flow_log_week_start_date"

// MARK: - Constants
let FLOW_LOGS_PER_WEEK_COUNT = 40

// MARK: - Identifiers
//let LOG_NOTIFICATION_ACTION_IDENTIFIER = "log_notification_action"

// MARK: - Strings
let ALARM_SOUND_STANDARD = "not set"
let TODAY = "today"
let TOMORROW = "tomorrow"
let ACTIVITY_ADD_NEW_STRING = "Add New"

// MARK: - Colors
let TINT_COLOR = UIColor.whiteColor()
let BAR_TINT_COLOR =  UIColor(red: 0.12140575, green: 0.47735399, blue: 0.5, alpha: 0.9)

// MARK: - Enums
enum FlowState: Int16
{
    case Anxiety = 1
    case Arousal
    case Flow
    case Control
    case Relaxation
    case Boredom
    case Apathy
    case Worry
}

enum GraphDisplayState: Int
{
    case FlowState = 0
    case Energy
    case Happiness
    case AllCombined
}

// MARK: - General Functions
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

func isSameday(left: NSDate, and right: NSDate) -> Bool
{
    let leftComponents = calendar.components([NSCalendarUnit.Day, NSCalendarUnit.Month, NSCalendarUnit.Year], fromDate: left)
    let rightComponents = calendar.components([NSCalendarUnit.Day, NSCalendarUnit.Month, NSCalendarUnit.Year], fromDate: right)
    
    
    return leftComponents.day == rightComponents.day && leftComponents.month == rightComponents.month && leftComponents.year == rightComponents.year
}

// MARK: - Extensions
extension UIViewController: LogStarterDelegate
{    
    func startLogWithLogNr(nr: Int)
    {
        if let _ = self.presentedViewController
        {
            print("already presenting viewcontroller!")
            return
        }
        
        let message = "It's time to create log no. \(nr)!"
        let alert = UIAlertController(title: "Do a log now", message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { _ in
            LogHelper.currentLogNr = nil
        }))
        alert.addAction(UIAlertAction(title: "Let's go!", style: .Default, handler: { _ in
            LogHelper.didDueLog = true
            let storyboard = UIStoryboard(name: "Log", bundle: nil)
            if let rootVC = storyboard.instantiateInitialViewController()
            {
                self.presentViewController(rootVC, animated: true, completion: nil)
            }
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
}

extension NSDate
{
    var dateWithoutTime: NSDate {
        get
        {
            let dayComponents = calendar.components([.Day, .Month, .Year], fromDate: self)
            let dayOnlyDate = calendar.dateFromComponents(dayComponents)!
            return dayOnlyDate
        }
    }
}

extension CGRect
{
    var minDimension: CGFloat {
        get
        {
            return min(self.width, self.height)
        }
    }
}

extension CGFloat
{
    func inBetween(min min: CGFloat, max: CGFloat) -> Bool
    {
        return self >= min && self <= max
    }
}

extension CGVector
{
    var length: CGFloat {
        get
        {
            return sqrt(self.dx * self.dx + self.dy * self.dy)
        }
    }
}

// MARK: - Computed Values
let calendar: NSCalendar = {
    let tempCalendar = NSCalendar.currentCalendar()
    tempCalendar.firstWeekday = 2
    tempCalendar.minimumDaysInFirstWeek = 4
    return tempCalendar
}()

func doDelayed(inSeconds seconds: Double, completion: () -> Void)
{
    let delay: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(seconds * Double(NSEC_PER_SEC)))
    dispatch_after(delay, dispatch_get_main_queue(), completion)
}







