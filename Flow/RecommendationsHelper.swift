//
//  RecommendationsHelper.swift
//  FlowLog
//
//  Created by Florian Pfisterer on 09/01/16.
//  Copyright © 2016 Florian Pfisterer. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class RecommendationsHelper     // MARK: - for different flow states
{
    class func getFlowReccomendations(flowValues graphValues: [CGFloat?], context: NSManagedObjectContext, completion: ([String]) -> Void)
    {
        dispatch_async(dispatch_get_main_queue(), {
            
            var recommendations = [String]()
            
            guard AnalysisHelper.getNumberOfLogs(context: context) > 5 else {
                completion(["Sorry, there is not enough data for any recommendations yet. Come back later."])
                return
            }
            
            if let maxIndex = maxIndex(graphValues)
            {
                guard let prefix = FlowState.Flow.recommendationPrefix else { return }
                let hour = maxIndex + LogHelper.alarmStartTime.hour
                let timeDescription = StringHelper.getLocalizedTimeDescriptionAtHour(hour)
                recommendations.append("\(prefix)\(timeDescription).")
            }
            
            let relevantFlowStates: [FlowState] = [.Relaxation, .Boredom, .Anxiety]
            _ = relevantFlowStates.map { state in
                
                let distribution = getStateDistributionForHoursFromFlowState(state, context: context)
                if let maxIndex = maxIndex(distribution)
                {
                    guard let prefix = state.recommendationPrefix else { return }
                    let hour = maxIndex + LogHelper.alarmStartTime.hour
                    
                    recommendations.append("\(prefix)\(StringHelper.getLocalizedTimeDescriptionAtHour(hour)).")
                }
            }
            
            completion(recommendations)
        })
    }
    
    private class func getStateDistributionForHoursFromFlowState(state: FlowState, context: NSManagedObjectContext) -> [CGFloat?]
    {
        var distribution = [CGFloat?]()
        for hour in LogHelper.alarmStartTime.hour...LogHelper.alarmEndTime.hour
        {
            let selectedLogCount = CGFloat(AnalysisHelper.getNumberOfLogsInHour(hour, inFlowState: state, context: context))
            distribution.append(selectedLogCount == 0 ? nil : CGFloat(selectedLogCount))
        }
        return distribution
    }
}

extension RecommendationsHelper     // MARK: - Energy, Happiness and Combined Recommendations
{
    class func getRecommendations(fromValues graphValues: [CGFloat?], graphState: GraphDisplayState, context: NSManagedObjectContext, completion: ([String]) -> Void)
    {
        dispatch_async(dispatch_get_main_queue(), {
            
            var recommendations = [String]()
            
            guard AnalysisHelper.getNumberOfLogs(context: context) > 5 else {
                completion(["Sorry, there is not enough data for any recommendations yet. Come back later."])
                return
            }
            
            if let maxIndex = maxIndex(graphValues)
            {
                let hour = maxIndex + LogHelper.alarmStartTime.hour
                let timeDescription = StringHelper.getLocalizedTimeDescriptionAtHour(hour)
                
                switch graphState
                {
                case .Energy:
                    recommendations.append("You have most energy at \(timeDescription). Do important and exhausting tasks at this time.")
                    
                case .Happiness:
                    recommendations.append("You are most happy at \(timeDescription). Try to find the reason for it and extend the time doing it.")
                    
                case .AllCombined:
                    recommendations.append("Your ultimate time is at \(timeDescription).")
                    recommendations.append("You feel energized, happy and are in flow state.")
                    recommendations.append("Try to extend and study these moments and how you can achieve them more often.")
                    
                default:
                    break
                }
            }
            
            if let minIndex = minIndex(graphValues)
            {
                let hour = minIndex + LogHelper.alarmStartTime.hour
                let timeDescription = StringHelper.getLocalizedTimeDescriptionAtHour(hour)
                
                switch graphState
                {
                case .Energy:
                    recommendations.append("You have least energy at \(timeDescription). Do unimportant and relaxing tasks at this time.")
                    
                case .Happiness:
                    recommendations.append("You are most unhappy at \(timeDescription). Try to do something that makes you happy at this time.")
                    
                default:
                    break
                }
            }
            
            completion(recommendations)
        })
    }
}