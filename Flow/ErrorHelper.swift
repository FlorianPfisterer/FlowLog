//
//  ErrorHelper.swift
//  FlowLog
//
//  Created by Florian Pfisterer on 25.05.16.
//  Copyright © 2016 Florian Pfisterer. All rights reserved.
//

import Foundation
import UIKit

class ErrorHelper
{
    class func errorAlert(error: FlowLogError) -> UIAlertController
    {
        let (title, message) = error.alertTuple
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: EString.Okay, style: .Default, handler: nil))
        return alert
    }
}
