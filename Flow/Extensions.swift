//
//  Extensions.swift
//  FlowLog
//
//  Created by Florian Pfisterer on 12/02/16.
//  Copyright © 2016 Florian Pfisterer. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController: LogStarterDelegate
{
    func startLog()
    {
        if let _ = self.presentedViewController
        {
            print("already presenting ViewController!")
            
            // in order not to end the notification process if another ViewController is presented (unrelated to log)
            NotificationHelper.scheduleNextNotification(completion: NOTIFICATION_COMPLETION_HANDLER_NONE)    // this notification will be deleted if a log is being created
            
            return
        }
        
        let message = "It's time to create a log!"
        let alert = UIAlertController(title: "Do a log now", message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { _ in
            // if the user cancels the log, no notification is left => process will end => schedule a new one
            let completion = AUTOMATIC_VC_NOTIFICATION_COMPLETION(vc: self, success: nil, failure: nil)
            NotificationHelper.scheduleNextNotification(completion: completion)
        }))
        alert.addAction(UIAlertAction(title: "Let's go!", style: .Default, handler: { _ in
            let storyboard = UIStoryboard(name: "Log", bundle: nil)
            if let rootVC = storyboard.instantiateInitialViewController()
            {
                self.presentViewController(rootVC, animated: true, completion: nil)
            }
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
}

extension NSDate
{
    var dateWithoutTime: NSDate {
        get
        {
            let dayComponents = calendar.components([.Day, .Month, .Year], fromDate: self)
            let dayOnlyDate = calendar.dateFromComponents(dayComponents)!
            return dayOnlyDate
        }
    }
}

extension CGRect
{
    var minDimension: CGFloat {
        get
        {
            return min(self.width, self.height)
        }
    }
}

extension CGFloat
{
    func inBetween(min min: CGFloat, max: CGFloat) -> Bool
    {
        return self >= min && self <= max
    }
    
    var radianValue: CGFloat {
        return CGFloat(self * π / 180)
    }
}

extension CGVector
{
    var length: CGFloat {
        get
        {
            return sqrt(self.dx * self.dx + self.dy * self.dy)
        }
    }
}

// http://stackoverflow.com/questions/28414999/html-format-in-uitextview
extension String
{
    var htmlAttributedString: NSAttributedString? {
        do
        {
            return try NSAttributedString(data: dataUsingEncoding(NSUTF8StringEncoding)!, options: [NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: NSUTF8StringEncoding], documentAttributes: nil)
        }
        catch
        {
            return nil
        }
    }
}

extension UIView
{
    var width: CGFloat {
        return self.bounds.size.width
    }
    
    var height: CGFloat {
        return self.bounds.size.height
    }
    
    var midX: CGFloat {
        return self.width/2
    }
    
    var midY: CGFloat {
        return self.height/2
    }
    
    var boundsCenter: CGPoint {
        return CGPoint(x: self.midX, y: self.midY)
    }
    
}

extension CGPoint
{
    static func fromRelativePoint(relativePoint: CGPoint, multiplier: CGSize) -> CGPoint
    {
        return CGPoint(x: relativePoint.x * multiplier.width, y: relativePoint.y * multiplier.height)
    }
}

extension UIColor
{
    static func gradientStartColor() -> UIColor
    {
        return UIColor(red: 31.0/255.0, green: 122.0/255.0, blue: 128.0/255.0, alpha: 1)
    }
    
    static func gradientEndColor() -> UIColor
    {
        return UIColor(red: 54.0/255.0, green: 54.0/255.0, blue: 54.0/255.0, alpha: 1)
    }
}








