//
//  Supporting Structs.swift
//  FlowLog
//
//  Created by Florian Pfisterer on 12/02/16.
//  Copyright © 2016 Florian Pfisterer. All rights reserved.
//

import Foundation
import UIKit

// MARK: - Protocols
protocol LogStarterDelegate
{
    func startLog()
}

protocol LogWeekStartDateSettingsDelegate
{
    func didSetStartDateTo(date: NSDate)
}

// MARK: - Enums
enum FlowState: Int16
{
    case Anxiety = 1
    case Arousal = 2
    case Flow = 3
    case Control = 4
    case Relaxation = 5
    case Boredom = 6
    case Apathy = 7
    case Worry = 8
}

extension FlowState
{
    var weight: CGFloat {
        switch self
        {
        case .Flow:
            return 0.8
        case .Control:
            return 0.6
        case .Arousal:
            return 0.6
        case .Relaxation:
            return 0.3
        case .Boredom:
            return 0.2
        case .Apathy:
            return 0.1
        case .Worry:
            return 0.3
        case .Anxiety:
            return 0.6
        }
    }
}

extension FlowState
{
    var recommendationPrefix: String? {
        switch self
        {
        case .Flow:
            return "Work on flow activities at "
        case .Relaxation:
            return "Good time to relax: "
        case .Boredom:
            return "Good time to do something interesting: "
        case .Anxiety:
            return "Reduce your challenge level at "
        default:
            return nil
        }
    }
}

extension FlowState
{
    var color: UIColor {
        switch self
        {
        case .Anxiety:
            return UIColor(red: 0, green: 0, blue: 1, alpha: 1)
        case .Arousal:
            return UIColor(red: 0.5, green: 0, blue: 1, alpha: 1)
        case .Flow:
            return UIColor(red: 1, green: 0, blue: 1, alpha: 1)
        case .Control:
            return UIColor(red: 1, green: 0.5, blue: 0.5, alpha: 1)
        case .Relaxation:
            return UIColor(red: 1, green: 1, blue: 0, alpha: 1)
        case .Boredom:
            return UIColor(red: 0.5, green: 1, blue: 0, alpha: 1)
        case .Apathy:
            return UIColor(red: 0, green: 1, blue: 0, alpha: 1)
        case .Worry:
            return UIColor(red: 0, green: 0.5, blue: 0.5, alpha: 1)
        }
    }
}

enum GraphDisplayState: Int
{
    case FlowState = 0
    case Energy
    case Happiness
    case AllCombined
    
    var stringDescription: String {
        switch self
        {
        case .FlowState: return "Flow State"
        case .Energy: return "Energy Level"
        case .Happiness: return "Happiness Level"
        case .AllCombined: return "All Combined"
        }
    }
}

enum NotificationScheduleResult: Int
{
    case Success = 0
    case InvalidDate
    case NotificationsDisabled
    case Other
}

enum SliderViewSelectionState
{
    case None
    case TookLeft
    case TookRight
}

enum GoogleAdUnitID: String
{
    case Test =                        "ca-app-pub-3940256099942544/2934735716"
    case OverviewBottomBanner =        "ca-app-pub-7799956148305568/3910022535"
    case LogActivityBottomBanner =     "ca-app-pub-7799956148305568/5886283333"
    case LogFlowBottomBanner =         "ca-app-pub-7799956148305568/8839749734"
    case AnalysisGeneralBottomBanner = "ca-app-pub-7799956148305568/3865029732"
}

enum TimeAccuracy
{
    case Hours
    case HalfHours
    case Minutes
}

// MARK: - Classes
class TimeFrame
{
    let startTime: Time
    var flowStateCount = 1
    
    init(startTime: Time)
    {
        self.startTime = Time(hour: startTime.hour, minute: startTime.minute >= 30 ? 30 : 0)
    }
    
    var title: String {
        let endTime = Time(absoluteMinutes: self.startTime.absoluteMinutes + 30)
        return "\(self.startTime.timeString()) - \(endTime.timeString())"
    }
    
    var detail: String {
        return "\(self.flowStateCount) FlowLog\(StringHelper.sEventually(self.flowStateCount))"
    }
}

// MARK: - Structs
struct Vector2D
{
    var dx: CGFloat
    var dy: CGFloat
    
    static let upYVector = Vector2D(dx: 0, dy: -1)
    
    init(dx: CGFloat, dy: CGFloat)
    {
        self.dx = dx
        self.dy = dy
    }
}

extension Vector2D  // public API
{
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
}

struct Time
{
    var hour: Int
    var minute: Int
    
    var absoluteMinutes: Int {
        return self.hour * 60 + self.minute
    }
    
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
    
    init(absoluteMinutes: Int)
    {
        self.minute = absoluteMinutes % 60
        self.hour = (absoluteMinutes - self.minute) / 60
    }
}

extension Time      // public API
{
    func timeString() -> String
    {
        return StringHelper.getLocalizedTimeDescription(self.getDate())
    }
    
    func roundedTimeHour() -> Int
    {
        let hoursDouble: Double = Double(self.hour) + Double(self.minute)/60
        return Int(round(hoursDouble))
    }
    
    func getDate() -> NSDate
    {
        let dateComponents = calendar.components([NSCalendarUnit.Day, NSCalendarUnit.Month, NSCalendarUnit.Year], fromDate: NSDate())
        
        if self.hour == 24
        {
            dateComponents.hour = 23
            dateComponents.minute = 59
            dateComponents.second = 59
        }
        else
        {
            dateComponents.hour = self.hour
            dateComponents.minute = self.minute
            dateComponents.second = 0
        }
        
        guard let date = calendar.dateFromComponents(dateComponents) else { return NSDate() }
        return date
    }
}

extension Time
{
    static func fromFraction(fraction: CGFloat, accuracy: TimeAccuracy = .Minutes) -> Time
    {
        switch accuracy
        {
        case .Hours:
            let hours: CGFloat = 24 * fraction
            return Time(absoluteMinutes: Int(floor(hours)) * 60)
            
        case .HalfHours:
            let halfhours: CGFloat = 24 * 2 * fraction
            return Time(absoluteMinutes: Int(floor(halfhours)) * 30)
            
        case .Minutes:
            let minutes: CGFloat = 24 * 60 * fraction
            return Time(absoluteMinutes: Int(floor(minutes)))
        }
    }
}
