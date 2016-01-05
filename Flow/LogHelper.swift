//
//  LogHelper.swift
//  Flow
//
//  Created by Florian Pfisterer on 03/01/16.
//  Copyright © 2016 Florian Pfisterer. All rights reserved.
//

import Foundation
import UIKit

class LogHelper
{
    // temp log data variables
    static var occupationIndex: Int!
    
    static var happinessLevel: Float!
    static var energyLevel: Float!
    
    static var skillDimension: Float!
    static var challengeDimension: Float!
    
    // functions
    static func saveCurrentLog(completion: (success: Bool, logEntry: LogEntry!) -> Void)
    {
        let delay: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC))  // slight delay for experience reasons
        
        dispatch_after(delay, dispatch_get_main_queue(), {
            let context = CoreDataHelper.managedObjectContext()
            let logEntry = CoreDataHelper.insertManagedObject("LogEntry", managedObjectContext: context) as! LogEntry
            logEntry.logNr = Int16(0)    // TODO!
            
            logEntry.occupationIndex = Int16(LogHelper.occupationIndex)
            
            logEntry.happinessLevel = LogHelper.happinessLevel
            logEntry.energyLevel = LogHelper.energyLevel
            
            logEntry.flowStateIndex = LogHelper.getFlowStateFromDimensions(skill: LogHelper.skillDimension, challenge: LogHelper.challengeDimension).rawValue
            
            logEntry.week = LogHelper.currentWeek()
            
            do
            {
                try context.save()
                LogHelper.currentFlowLogCount = LogHelper.currentFlowLogCount + 1
                
                completion(success: true, logEntry: logEntry)
                
                LogHelper.occupationIndex = nil
                LogHelper.happinessLevel = nil
                LogHelper.energyLevel = nil
                LogHelper.skillDimension = nil
                LogHelper.challengeDimension = nil
            }
            catch
            {
                completion(success: false, logEntry: nil)
            }

        })
    }
    
    static func getRemainingFlowLogsInCurrentWeek() -> (Bool, Int!)
    {
        let difference =  FLOW_LOGS_PER_WEEK_COUNT - LogHelper.currentFlowLogCount
        if difference > 0
        {
            return (true, difference)
        }
        else
        {
            return (false, nil)
        }
       
    }
    
    // settings variables
    private static var tmpCurrentWeek: LogWeek?
    
    static func currentWeek() -> LogWeek
    {
        if let week = LogHelper.tmpCurrentWeek
        {
            return week
        }
        else
        {
            let context = CoreDataHelper.managedObjectContext()
            let week = CoreDataHelper.insertManagedObject("LogWeek", managedObjectContext: context) as! LogWeek
            week.startDate = NSDate().timeIntervalSince1970
            
            try! context.save()
            
            return week
        }
    }
    
    static func getFlowStateFromDimensions(skill skill: Float, challenge: Float) -> FlowState
    {
        return .Flow
    }
    
    static var currentFlowLogCount: Int {
        get
        {
            return NSUserDefaults.standardUserDefaults().integerForKey(CURRENT_FLOW_LOG_COUNT_INT_KEY)
        }
        
        set (newValue)
        {
            return NSUserDefaults.standardUserDefaults().setInteger(newValue, forKey: CURRENT_FLOW_LOG_COUNT_INT_KEY)
        }
    }
    
    static var flowLogWeekStartDate: NSDate? {
        get
        {
            return NSUserDefaults.standardUserDefaults().objectForKey(FLOW_LOG_WEEK_START_DATE_KEY) as? NSDate
        }
        
        set (newValue)
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
        
        set { }
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
        
        set { }
    }
    
    static var alarmSoundFileName: String {
        get
        {
            if let name = NSUserDefaults.standardUserDefaults().stringForKey(ALARM_SOUND_FILE_NAME_STRING_KEY)
            {
                return name
            }
            else
            {
                return ALARM_SOUND_STANDARD
            }
        }
        
        set (newValue)
        {
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: ALARM_SOUND_FILE_NAME_STRING_KEY)
        }
        
    }
}

struct Time
{
    var hour: Int
    var minute: Int
    
    static let standardStartTime = Time(hour: 9, minute: 0)
    static let standardEndTime = Time(hour: 19, minute: 0)
    
    init(hour: Int, minute: Int)
    {
        self.hour = hour
        self.minute = minute
    }
    
    init(date: NSDate)
    {
        let dateComponents = calendar.components([NSCalendarUnit.Hour, NSCalendarUnit.Minute], fromDate: date)
        self.hour = dateComponents.hour
        self.minute = dateComponents.minute
    }
    
    func timeString() -> String
    {
        if self.minute < 10
        {
            return "\(self.hour):0\(self.minute)"
        }
        else
        {
            return "\(self.hour):\(self.minute)"
        }
    }
}

protocol LogStarterDelegate
{
    func startLogWithOptions(options: [String : AnyObject]?)
}