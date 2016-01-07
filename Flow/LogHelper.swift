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
    static var occupationIndex: Int!
    
    static var happinessLevel: Float!
    static var energyLevel: Float!
    
    static var flowState: FlowState!
    
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
            
            logEntry.flowStateIndex = LogHelper.flowState.rawValue
            
            logEntry.week = LogHelper.currentWeek()
            
            do
            {
                try context.save()
                LogHelper.currentFlowLogCount = LogHelper.currentFlowLogCount + 1
                
                completion(success: true, logEntry: logEntry)
                
                LogHelper.occupationIndex = nil
                LogHelper.happinessLevel = nil
                LogHelper.energyLevel = nil
                LogHelper.flowState = nil
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
        
        set (newValue)
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
        
        set (newValue)
        {
            NSUserDefaults.standardUserDefaults().setObject(newValue.getDate(), forKey: ALARM_END_DATE_KEY)
        }
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

func * (left: Vector2D, right: Vector2D) -> CGFloat
{
    return (left.dx * right.dx) + (left.dy * right.dy)
}

let π = CGFloat(M_PI)

struct Vector2D
{
    var dx: CGFloat
    var dy: CGFloat
    
    init(dx: CGFloat, dy: CGFloat)
    {
        self.dx = dx
        self.dy = dy
    }
    
    func abs() -> CGFloat
    {
        return sqrt((self.dx*self.dx) + (self.dy*self.dy))
    }
    
    func getAngleToVector(vector: Vector2D) -> CGFloat
    {
        // cos(α) = ( p*q ) / ( |p|*|q| )
        let α = acos((self * vector) / (self.abs() * vector.abs()))  // radian
        
        return (α * 180) / π
    }
    
    static let upYVector = Vector2D(dx: 0, dy: -1)
}

struct Time
{
    var hour: Int
    var minute: Int
    
    var absoluteMinutes: Int
    
    static let standardStartTime = Time(hour: 9, minute: 0)
    static let standardEndTime = Time(hour: 19, minute: 0)
    
    init(hour: Int, minute: Int)
    {
        self.hour = hour
        self.minute = minute
        
        self.absoluteMinutes = self.hour * 60 + self.minute
    }
    
    init(date: NSDate)
    {
        let dateComponents = calendar.components([NSCalendarUnit.Hour, NSCalendarUnit.Minute], fromDate: date)
        self.hour = dateComponents.hour
        self.minute = dateComponents.minute
        
        self.absoluteMinutes = self.hour * 60 + self.minute
    }
    
    init(absoluteMinutes: Int)
    {
        self.minute = absoluteMinutes % 60
        self.hour = (absoluteMinutes - self.minute) / 60
        
        self.absoluteMinutes = absoluteMinutes
    }
    
    // public
    func timeString() -> String // TODO! Localize
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
    
    func getDate() -> NSDate
    {
        let dateComponents = calendar.components([NSCalendarUnit.Day, NSCalendarUnit.Month, NSCalendarUnit.Year], fromDate: NSDate())

        dateComponents.hour = self.hour
        dateComponents.minute = self.minute
        dateComponents.second = 0
        
        return calendar.dateFromComponents(dateComponents)!
    }
}

protocol LogStarterDelegate
{
    func startLogWithOptions(options: [String : AnyObject]?)
}