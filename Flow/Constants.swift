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
let π = CGFloat(M_PI)

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

// MARK: - Computed Values
let calendar: NSCalendar = {
    let tempCalendar = NSCalendar.currentCalendar()
    tempCalendar.firstWeekday = 2
    tempCalendar.minimumDaysInFirstWeek = 4
    return tempCalendar
}()