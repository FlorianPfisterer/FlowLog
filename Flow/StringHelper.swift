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
    class func localizedStringForKey(key: String) -> String
    {
        return NSLocalizedString(key, comment: "comment")
    }
    
    class func searchDictionaryArrayForString(dictionaryArray: [[String : String]], searchString: String, concerningKey key: String) -> [[String : String]]
    {
        var searchedDictionaryArray = [[String : String]]()
        
        for dictionary in dictionaryArray
        {
            if let value = dictionary[key]
            {
                if let _ = value.lowercaseString.rangeOfString(searchString.lowercaseString)
                {
                    searchedDictionaryArray.append(dictionary)
                }
            }
        }
        
        return searchedDictionaryArray
    }
}