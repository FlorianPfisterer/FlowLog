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
            if calendar.component(.Hour, fromDate: NSDate(timeIntervalSinceReferenceDate: log.createdAt)) == hour
            {
                logsInHour.append(log)
            }
        }
        
        return logsInHour
    }
    
    class func getAverageEnergyLevelInHour(hour: Int, inFlowState flowState: FlowState? = nil, context: NSManagedObjectContext) -> CGFloat
    {
        let logs = AnalysisHelper.getLogsInHour(hour, inFlowState: flowState, context: context)
        
        if logs.count > 0
        {
            var sum: Float = 0
            for log in logs
            {
                sum += log.energyLevel
            }
            
            return CGFloat(sum/Float(logs.count))
        }
        return 0
    }
    
    class func getAverageHappinessLevelInHour(hour: Int, inFlowState flowState: FlowState? = nil, context: NSManagedObjectContext) -> CGFloat
    {
        let logs = AnalysisHelper.getLogsInHour(hour, inFlowState: flowState, context: context)
        
        if logs.count > 0
        {
            var sum: Float = 0
            for log in logs
            {
                sum += log.happinessLevel
            }
            
            return CGFloat(sum/Float(logs.count))
        }
        return 0
    }
    
    class func getCombinedScoreInHour(hour: Int, inFlowState flowState: FlowState? = nil, context: NSManagedObjectContext) -> CGFloat
    {
        let averageEnergy = AnalysisHelper.getAverageEnergyLevelInHour(hour, context: context)
        let averageHappiness = AnalysisHelper.getAverageHappinessLevelInHour(hour, context: context)
        
        let logsGeneralCount = AnalysisHelper.getNumberOfLogsInHour(hour, context: context)
        if logsGeneralCount != 0
        {
            let logsInFlowCount = AnalysisHelper.getNumberOfLogsInHour(hour, inFlowState: flowState, context: context)
            let flowStateScore: CGFloat = CGFloat(logsInFlowCount) / CGFloat(logsGeneralCount)
            
            let combinedScore = (averageEnergy + averageHappiness + flowStateScore) / 3
            
            return combinedScore
        }
        
        return 0
    }
    
    class func getSortedActivities(fromFlowState flowState: FlowState? = nil, context: NSManagedObjectContext) -> [Activity]
    {
        // get all logs in given flowState
        let logs = AnalysisHelper.getLogs(inFlowState: flowState, context: context)
        var activitiesWithAmounts = [Activity : Int]()
        
        for log in logs
        {
            let addActivityToArray = {
                if let amount = activitiesWithAmounts[log.activity!]
                {
                    activitiesWithAmounts[log.activity!] = amount + 1
                }
                else
                {
                    activitiesWithAmounts[log.activity!] = 1
                }
            }
            
            guard let flowState = flowState else
            {
                addActivityToArray()
                continue
            }
            
            if log.flowStateIndex == flowState.rawValue
            {
                addActivityToArray()
            }
        }
        
        let sortedActivities = activitiesWithAmounts.sort({ $0.1 > $1.1 }).map({ $0.0 })
        return sortedActivities
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

extension AnalysisHelper
{
    class func getGraphValues(forState state: GraphDisplayState, context: NSManagedObjectContext) -> [CGFloat?]
    {
        var graphValues: [CGFloat?] = []
        
        for hour in LogHelper.alarmStartTime.hour...LogHelper.alarmEndTime.hour
        {
            switch state
            {
            case .FlowState:
                let logCountInFlowInHour = AnalysisHelper.getNumberOfLogsInHour(hour, inFlowState: .Flow, context: context)
                graphValues.append(logCountInFlowInHour == 0 ? nil : CGFloat(logCountInFlowInHour))
                
            case .Energy:
                let energyLevel = AnalysisHelper.getAverageEnergyLevelInHour(hour, context: context)
                graphValues.append(energyLevel == 0 ? nil : energyLevel)
                
            case .Happiness:
                let happinessLevel = AnalysisHelper.getAverageHappinessLevelInHour(hour, context: context)
                graphValues.append(happinessLevel == 0 ? nil : happinessLevel)
                
            case .AllCombined:
                let combinedScore = AnalysisHelper.getCombinedScoreInHour(hour, inFlowState: .Flow, context: context)
                graphValues.append(combinedScore == 0 ? nil : combinedScore)
            }
        }
        
        return graphValues
    }
}