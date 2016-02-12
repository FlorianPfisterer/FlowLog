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
    func timeString() -> String // TODO! Localize
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
