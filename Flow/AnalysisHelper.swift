//
//  AnalysisHelper.swift
//  FlowLog
//
//  Created by Florian Pfisterer on 08/01/16.
//  Copyright © 2016 Florian Pfisterer. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class AnalysisHelper
{
    class func getLogs(inFlowState flowState: FlowState? = nil, context: NSManagedObjectContext) -> [LogEntry]
    {
        do
        {
            var predicate: NSPredicate? = nil
            if let state = flowState
            {
                predicate = NSPredicate(format: "flowStateIndex == %d", state.rawValue)
            }
            
            let logs = try CoreDataHelper.fetchEntities("LogEntry", managedObjectContext: context, predicate: predicate, sortDescriptor: nil) as! [LogEntry]
            
            return logs
        }
        catch
        {
            print("ERROR fetching logs in flowstate: \(flowState), error: \(error)")
        }
        
        return []
    }
    
    class func getLogsInHour(hour: Int, inFlowState flowState: FlowState? = nil, context: NSManagedObjectContext) -> [LogEntry]
    {
        let logs = AnalysisHelper.getLogs(inFlowState: flowState, context: context)
        var logsInHour = [LogEntry]()
        
        for log in logs
        {
            if calendar.component(.Hour, fromDate: NSDate(timeIntervalSince1970: log.createdAt)) == hour
            {
                logsInHour.append(log)
            }
        }
        
        return logsInHour
    }
    
    class func getAverageEnergyLevelInHour(hour: Int, inFlowState flowState: FlowState? = nil, context: NSManagedObjectContext) -> CGFloat
    {
        let logs = AnalysisHelper.getLogsInHour(hour, inFlowState: flowState, context: context)
        
        var sum: Float = 0
        for log in logs
        {
            sum += log.energyLevel
        }
        
        return CGFloat(sum/Float(logs.count))
    }
    
    class func getAverageHappinessLevelInHour(hour: Int, inFlowState flowState: FlowState? = nil, context: NSManagedObjectContext) -> CGFloat
    {
        let logs = AnalysisHelper.getLogsInHour(hour, inFlowState: flowState, context: context)
        
        var sum: Float = 0
        for log in logs
        {
            sum += log.happinessLevel
        }
        
        return CGFloat(sum/Float(logs.count))
    }
    
    class func getCombinedScoreInHour(hour: Int, inFlowState flowState: FlowState? = nil, context: NSManagedObjectContext) -> CGFloat
    {
        
        
        return 0
    }
    
    class func getNumberOfLogs(inFlowState flowState: FlowState? = nil, context: NSManagedObjectContext) -> Int
    {
        return AnalysisHelper.getLogs(inFlowState: flowState, context: context).count
    }
    
    class func getNumberOfLogsInHour(hour: Int, inFlowState flowState: FlowState? = nil, context: NSManagedObjectContext) -> Int
    {
        return AnalysisHelper.getLogsInHour(hour, inFlowState: flowState, context: context).count
    }
}