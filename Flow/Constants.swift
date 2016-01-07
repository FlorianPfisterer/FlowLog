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

let FLOW_LOG_WEEK_START_DATE_KEY = "flow_log_week_start_date"

// MARK: - Constants
let FLOW_LOGS_PER_WEEK_COUNT = 40

// MARK: - Identifiers
//let LOG_NOTIFICATION_ACTION_IDENTIFIER = "log_notification_action"

// MARK: - Strings
let ALARM_SOUND_STANDARD = "not set"
let TODAY = "today"
let TOMORROW = "tomorrow"

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
    
    static let colors: [UIColor] = [
        UIColor(red: 0, green: 0, blue: 0.5, alpha: 0.9),
        UIColor(red: 0.5, green: 0, blue: 0.5, alpha: 0.9),
        UIColor(red: 1, green: 0, blue: 0.5, alpha: 0.9),
        UIColor(red: 1, green: 1, blue: 0.5, alpha: 0.9),
        UIColor(red: 0.5, green: 1, blue: 0.5, alpha: 0.9),
        UIColor(red: 0, green: 1, blue: 0.5, alpha: 0.9),
        UIColor(red: 0, green: 0.5, blue: 0.5, alpha: 0.9)]
    
    static func getCGColors() -> [CGColor]
    {
        return FlowState.colors.map({ $0.CGColor })
    }
    
    static func getLocations() -> [CGFloat]
    {
        return [0, 1/8, 2/8, 3/8, 4/8, 5/8, 6/8, 7/8]
    }
    
    func color() -> UIColor
    {
        return FlowState.colors[Int(self.rawValue-1)]
    }
    
}

// MARK: - General Functions
func getRelativeDateDescription(date: NSDate) -> String
{
    let dateDay = calendar.component(NSCalendarUnit.Day, fromDate: date)
    let nowDay = calendar.component(NSCalendarUnit.Day, fromDate: NSDate())
    
    switch (dateDay - nowDay)
    {
    case 0:
        return TODAY
    case 1:
        return TOMORROW
    case let value where value > 1:
        return "in \(value) days"
    default:
        return "in \(dateDay - nowDay) days"
    }
}

// MARK: - Extensions
extension UIViewController: LogStarterDelegate
{
    func startLogWithOptions(options: [String : AnyObject]?)
    {
        var message = "It's time to create "
        if let logNr = options?[LOG_NR_NOTIFICATION_INT_KEY] as? Int
        {
            message += "log no. \(logNr)!"
        }
        else
        {
            message += "a log!"
        }
        
        let alert = UIAlertController(title: "Do a log now", message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Let's go!", style: .Default, handler: { _ in
            let storyboard = UIStoryboard(name: "Log", bundle: nil)
            if let rootVC = storyboard.instantiateInitialViewController()
            {
                self.presentViewController(rootVC, animated: true, completion: nil)
            }
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
}

// MARK: - Computed Values
let calendar: NSCalendar = {
    let tempCalendar = NSCalendar.currentCalendar()
    tempCalendar.firstWeekday = 2
    tempCalendar.minimumDaysInFirstWeek = 4
    return tempCalendar
}()