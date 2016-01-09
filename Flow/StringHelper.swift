//
//  StringHelper.swift
//  Flow
//
//  Created by Florian Pfisterer on 03/01/16.
//  Copyright © 2016 Florian Pfisterer. All rights reserved.
//

import Foundation

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
}