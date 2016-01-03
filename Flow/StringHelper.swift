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
}