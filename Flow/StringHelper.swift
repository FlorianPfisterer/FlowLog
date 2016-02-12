//
//  StringHelper.swift
//  Flow
//
//  Created by Florian Pfisterer on 03/01/16.
//  Copyright © 2016 Florian Pfisterer. All rights reserved.
//

import Foundation
import UIKit

class StringHelper
{
    class func searchActivityArrayForString(activityArray: [Activity], searchString: String) -> [Activity]
    {
        var searchedArray = [Activity]()
        
        for activity in activityArray
        {
            if activity.getName().lowercaseString.rangeOfString(searchString.lowercaseString) != nil || activity.getName() == ACTIVITY_ADD_NEW_STRING       // always include the add new activity
            {
                searchedArray.append(activity)
            }
        }
        
        return searchedArray
    }
    
    class func getLocalizedTimeDescription(date: NSDate) -> String
    {
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale.autoupdatingCurrentLocale()
        dateFormatter.timeStyle = .ShortStyle
        dateFormatter.dateStyle = .NoStyle
        
        return dateFormatter.stringFromDate(date)
    }
    
    class func getLocalizedShortTimeDescriptionAtHour(hour: Int) -> String
    {
        let dateComponents = calendar.components([.Day, .Month, .Year], fromDate: NSDate())
        dateComponents.calendar = calendar
        dateComponents.hour = hour
        
        if let date = dateComponents.date
        {
            let dateFormatter = NSDateFormatter()
            dateFormatter.locale = NSLocale.autoupdatingCurrentLocale()
            dateFormatter.timeStyle = .ShortStyle
            dateFormatter.dateStyle = .NoStyle
            
            let fullDescription = StringHelper.getLocalizedTimeDescription(date)
            
            let is24 = fullDescription.rangeOfString(dateFormatter.AMSymbol) == nil && fullDescription.rangeOfString(dateFormatter.PMSymbol) == nil
            
            if is24
            {
                return "\(hour)"
            }
            else
            {
                if hour > 12
                {
                    return "\(hour-12)p"
                }
                else if hour == 24 || hour == 0
                {
                    return "12a"
                }
                else if hour == 12
                {
                    return "12p"
                }
                else
                {
                    return "\(hour)a"
                }
            }
        }
        return "\(hour)"
    }
    
    class func format(format: String, value: CGFloat) -> String
    {
        return NSString(format: "%\(format)f", Double(value)) as String
    }
    
    class func sEventually(number: Int) -> String
    {
        if number == 1||number == -1
        {
            return ""
        }
        return "s"
    }
}