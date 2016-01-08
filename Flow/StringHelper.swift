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
    class func searchStringArrayForString(stringArray: [String], searchString: String, concerningKey key: String) -> [String]
    {
        var searchedStringArray = [String]()
        
        for string in stringArray
        {
            if let _ = string.lowercaseString.rangeOfString(searchString.lowercaseString)
            {
                searchedStringArray.append(string)
            }
        }
        
        return searchedStringArray
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