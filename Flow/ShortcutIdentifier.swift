//
//  ShortcutIdentifier.swift
//  FlowLog
//
//  Created by Florian Pfisterer on 21.04.16.
//  Copyright © 2016 Florian Pfisterer. All rights reserved.
//

import UIKit

enum ShortcutIdentifier: String
{
    case DoALog
    case Recommendations
    case AllLogs
    
    init?(fullType: String)
    {
        guard let last = fullType.componentsSeparatedByString(".").last else { return nil }
        self.init(rawValue: last)
    }
    
    var typeDescription: String {
        return NSBundle.mainBundle().bundleIdentifier! + ".\(self.rawValue)"
    }
}

extension ShortcutIdentifier
{
    var storyboardID: String {
        switch self
        {
        case .DoALog:
            return "Log"
        case .Recommendations:
            return "Analysis"
            
        case .AllLogs:
            return "Analysis"
        }
    }
    
    func performChanges()
    {
        switch self
        {
        case .DoALog:
            break
            
        case .Recommendations:
            // set up for navigation to main analysis
            QuickActionsHelper.navigateTo = .Recommendations
            break
            
        case .AllLogs:
            // set up for navigation to all logs
            QuickActionsHelper.navigateTo = .AllLogs
            break
        }
    }
}

extension ShortcutIdentifier
{
    var title: String {
        switch self
        {
        case .DoALog:
            return "Do a FlowLog now"
            
        case .AllLogs:
            return "View all Logs"
            
        case .Recommendations:
            return "View Recommendations"
        }
    }
    
    var associatedIconType: UIApplicationShortcutIconType {
        switch self
        {
        case .DoALog:
            return .Compose
            
        case .AllLogs:
            return .Search
            
        case .Recommendations:
            if #available(iOS 9.1, *)
            {
                return .Home
            }
            else
            {
                return .Share
            }
        }
    }
}