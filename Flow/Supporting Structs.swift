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
        
        dateComponents.hour = self.hour
        dateComponents.minute = self.minute
        dateComponents.second = 0
        
        return calendar.dateFromComponents(dateComponents)!
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
