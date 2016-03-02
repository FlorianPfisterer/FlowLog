//
//  LogHelper.swift
//  Flow
//
//  Created by Florian Pfisterer on 03/01/16.
//  Copyright © 2016 Florian Pfisterer. All rights reserved.
//

import Foundation
import Darwin
import UIKit

class LogHelper
{
    // temp log data variables
    static var currentActivity: Activity!
    
    static var happinessLevel: Float!
    static var energyLevel: Float!
    
    static var flowState: FlowState!
}

extension LogHelper     // MARK: - Action Functions
{
    static func saveCurrentLog(seed: Bool = false, completion: (success: Bool, logEntry: LogEntry!) -> Void)
    {
        dispatch_async(dispatch_get_main_queue(), {
            
            let context = CoreDataHelper.managedObjectContext()
            
            // create and edit new LogEntry
            let logEntry = CoreDataHelper.insertManagedObject("LogEntry", managedObjectContext: context) as! LogEntry
            logEntry.logNr = LogHelper.getCurrentLogNr()
            
            logEntry.activity = LogHelper.currentActivity
            logEntry.happinessLevel = LogHelper.happinessLevel
            logEntry.energyLevel = LogHelper.energyLevel
            logEntry.flowStateIndex = LogHelper.flowState.rawValue
            logEntry.createdAt = NSDate().timeIntervalSinceReferenceDate
            
            LogHelper.currentActivity.used = LogHelper.currentActivity.used + 1
            
            do
            {
                try context.save()
                
                NotificationHelper.logFireDateScheduledNotYetExecuted = nil     // !
                completion(success: true, logEntry: logEntry)
                
                // reset static variables
                if !seed
                {
                    LogHelper.currentActivity = nil
                    LogHelper.happinessLevel = nil
                    LogHelper.energyLevel = nil
                    LogHelper.flowState = nil
                }
                
                return
            }
            catch
            {
                print("ERROR saving LogEntry: \(error)")
            }
            
            completion(success: false, logEntry: nil)
        })
    }
}

extension LogHelper     // MARK: - Help Functions
{
    static func getRemainingFlowLogsInCurrentWeek() -> (Bool, Int)
    {
        let weekIndex = NotificationHelper.currentWeekIndex     // 1 - n
        let remainingLogsCount = weekIndex*FLOW_LOGS_PER_WEEK_COUNT - Int(LogHelper.getCurrentLogNr()-1)
        
        print("INFO: weekIndex = \(weekIndex), remainingLogsCount = \(remainingLogsCount)")
        
        return (remainingLogsCount > 0, remainingLogsCount)
    }
    
    static func getRemainingDaysInCurrentWeek() -> Int
    {
        if let startDateTimeInterval: NSTimeInterval = LogHelper.flowLogWeekStartDate?.timeIntervalSinceReferenceDate
        {
            let secondsPerDay: NSTimeInterval = 60 * 60 * 24
            
            // calculate difference in days since the start date
            let secondsDifference: NSTimeInterval = NSDate().timeIntervalSinceReferenceDate - startDateTimeInterval
            let daysDifference: Int = Int(floor(secondsDifference / secondsPerDay))
            
            return 7 - min(daysDifference, 7)
        }
        
        return 7
    }
    
    class func getCurrentLogNr() -> Int16
    {
        let context = CoreDataHelper.managedObjectContext()
        let sortedLogs = AnalysisHelper.getLogs(context: context).sort({ $0.logNr > $1.logNr })
        
        if let largestLogNr = sortedLogs.first?.logNr
        {
            return largestLogNr + 1
        }
        
        return 1
    }
    
    // returns if the current time is in the timeframe that the user set up for FlowLogs to be done
    class func currentTimeIsInBoundaries() -> Bool
    {
        let currentTimeAbsM = Time(date: NSDate()).absoluteMinutes
        let startTimeAbsM = LogHelper.alarmStartTime.absoluteMinutes
        let endTimeAbsM = LogHelper.alarmEndTime.absoluteMinutes
        
        if endTimeAbsM > currentTimeAbsM && startTimeAbsM < currentTimeAbsM
        {
            return true
        }
        
        return false
    }
    
    // settings variables
    static func getFlowStateFromAngle(angle: CGFloat) -> FlowState
    {
        let α0: CGFloat = 360 / 8    // angle span of each segment: 45 degrees
        
        switch angle
        {
        case let α where α >= (15/2) * α0 || α < (1/2) * α0:          // top middle segment
            return .Arousal
            
        case let α where α >= (1/2) * α0 && α < (3/2) * α0:           // top right segment
            return .Flow
            
        case let α where α >= (3/2) * α0 && α < (5/2) * α0:     // right segment
            return .Control
            
        case let α where α >= (5/2) * α0 && α < (7/2) * α0:     // bottom right segment
            return .Relaxation
            
        case let α where α >= (7/2) * α0 && α < (9/2) * α0:     // bottom middle segment
            return .Boredom
            
        case let α where α >= (9/2) * α0 && α < (11/2) * α0:    // bottom left segment
            return .Apathy
            
        case let α where α >= (11/2) * α0 && α < (13/2) * α0:   // left segment
            return .Worry
            
        case let α where α >= (13/2) * α0 && α < (15/2) * α0:   // top left segment
            return .Anxiety
            
        default:
            return .Relaxation
        }
    }
}

extension LogHelper     // MARK: - Settings Variables
{
    static var flowLogWeekStartDate: NSDate? {
        get
        {
            return NSUserDefaults.standardUserDefaults().objectForKey(FLOW_LOG_WEEK_START_DATE_KEY) as? NSDate
        }
        
        set
        {
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: FLOW_LOG_WEEK_START_DATE_KEY)
        }
    }
    
    static var alarmStartTime: Time {
        get
        {
            if let date = NSUserDefaults.standardUserDefaults().objectForKey(ALARM_START_DATE_KEY) as? NSDate
            {
                return Time(date: date)
            }
            else
            {
                print("alarmStartTime not found, returning standardTime")
                return Time.standardStartTime
            }
        }
        
        set
        {
            NSUserDefaults.standardUserDefaults().setObject(newValue.getDate(), forKey: ALARM_START_DATE_KEY)
        }
    }
    
    static var alarmEndTime: Time {
        get
        {
            if let date = NSUserDefaults.standardUserDefaults().objectForKey(ALARM_END_DATE_KEY) as? NSDate
            {
                return Time(date: date)
            }
            else
            {
                print("alarmEndTime not found, returning standardTime")
                return Time.standardEndTime
            }
        }
        
        set
        {
            NSUserDefaults.standardUserDefaults().setObject(newValue.getDate(), forKey: ALARM_END_DATE_KEY)
        }
    }
}