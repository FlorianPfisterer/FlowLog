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
let ALARM_START_DATE_KEY = "alarm_start_date"
let ALARM_END_DATE_KEY = "alarm_end_date"
let DATABASE_ACTIVITIES_SEED_DONE_BOOL_KEY = "database_activities_seed_done_bool"

let FLOW_LOG_WEEK_START_DATE_KEY = "flow_log_week_start_date"
let CURRENT_WEEK_INDEX_INT_KEY = "current_week_index_int"

let LOG_SCHEDULED_NOT_YET_EXECUTED_DATE_KEY = "log_scheduled_not_yet_executed_date_key"

// MARK: - Constants
let FLOW_LOGS_PER_WEEK_COUNT = 40
let π = CGFloat(M_PI)
let procrastinationQuotes = ["Procrastination is the thief of time.", "A stitch in time saves nine.", "There is no time like the present.", "Never put off till tomorrow what you can do today."]

// MARK: - Identifiers
//let LOG_NOTIFICATION_ACTION_IDENTIFIER = "log_notification_action"

// MARK: - Strings
let TODAY = "today"
let TOMORROW = "tomorrow"
let ACTIVITY_ADD_NEW_STRING = "Add New"
let NOTIFICATIONS_DISABLED_ALERT_STRINGS = ("Notifications are disabled", "In order to be able to use this app properly, you have to enable this app to send you notifications. Go to Settings -> Notifications -> FlowLog and try again.")

// MARK: - Colors
let TINT_COLOR = UIColor.whiteColor()
let BAR_TINT_COLOR =  UIColor(red: 0.12140575, green: 0.47735399, blue: 0.5, alpha: 0.9)

// MARK: - Computed Values
let calendar: NSCalendar = {
    let tempCalendar = NSCalendar.currentCalendar()
    tempCalendar.firstWeekday = 2
    tempCalendar.minimumDaysInFirstWeek = 4
    return tempCalendar
}()

let AUTOMATIC_VC_NOTIFICATION_COMPLETION: (vc: UIViewController, success: (() -> Void)?, failure: (() -> Void)?) -> ((NotificationScheduleResult) -> Void) = { vc, successClosure, failureClosure in
    
    let completionHandler: (NotificationScheduleResult) -> Void = { result in
        
        var alert: UIAlertController?
        switch result
        {
        case .Success:
            successClosure?()
            
        case .InvalidDate, .Other:
            alert = UIAlertController(title: "An error occured", message: "Please try again later. Thank you.", preferredStyle: .Alert)
            
        case .NotificationsDisabled:
            let (title, message) = NOTIFICATIONS_DISABLED_ALERT_STRINGS
            alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        }
        
        if let errorAlert = alert
        {
            errorAlert.addAction(UIAlertAction(title: "Okay", style: .Default, handler: { _ in
                failureClosure?()
            }))
            vc.presentViewController(errorAlert, animated: true, completion: nil)
        }
    }
    
    return completionHandler
}

let NOTIFICATION_COMPLETION_HANDLER_NONE: (NotificationScheduleResult) -> Void = {
    _ in
    return
}













