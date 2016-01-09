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

class RecommendationsHelper
{
    class func getRecommendationsForGraphState(graphState: GraphDisplayState, graphValues: [CGFloat], completion: ([String]) -> Void, context: NSManagedObjectContext)
    {
        dispatch_async(dispatch_get_main_queue(), {
            
            var recommendations: [String] = []
            
            if AnalysisHelper.getNumberOfLogs(context: context) > 5
            {
                switch graphState
                {
                case .FlowState:
                    
                    if let hourWithMaxFlow: Int = graphValues.indexOf({ $0 == graphValues.maxElement() })
                    {
                        recommendations.append("Work on flow activities at \(StringHelper.getLocalizedShortTimeDescriptionAtHour(hourWithMaxFlow + LogHelper.alarmStartTime.hour))")
                    }
                    
                    var relaxationAmounts: [Int] = []
                    var boredomAmounts: [Int] = []
                    var anxietyAmounts: [Int] = []
                    for hour in LogHelper.alarmStartTime.hour...LogHelper.alarmEndTime.hour
                    {
                        relaxationAmounts.append(AnalysisHelper.getNumberOfLogsInHour(hour, inFlowState: .Relaxation, context: context))
                        boredomAmounts.append(AnalysisHelper.getNumberOfLogsInHour(hour, inFlowState: .Boredom, context: context))
                        anxietyAmounts.append(AnalysisHelper.getNumberOfLogsInHour(hour, inFlowState: .Anxiety, context: context))
                    }
                    
                    if let hourWithMaxRelaxation: Int = relaxationAmounts.indexOf({ $0 == relaxationAmounts.maxElement() })
                    {
                        recommendations.append("Good relaxation time: \(StringHelper.getLocalizedShortTimeDescriptionAtHour(hourWithMaxRelaxation + LogHelper.alarmStartTime.hour)).")
                    }
                    
                    if let hourWithMaxBoredom: Int = boredomAmounts.indexOf({ $0 == boredomAmounts.maxElement() })
                    {
                        recommendations.append("Good time to do something interesting: \(StringHelper.getLocalizedShortTimeDescriptionAtHour(hourWithMaxBoredom + LogHelper.alarmStartTime.hour)).")
                    }
                    
                    if let hourWithMaxAnxiety: Int = anxietyAmounts.indexOf({ $0 == anxietyAmounts.maxElement() })
                    {
                        recommendations.append("Reduce your challenge level by relaxing at \(StringHelper.getLocalizedShortTimeDescriptionAtHour(hourWithMaxAnxiety + LogHelper.alarmStartTime.hour)).")
                    }
                    
                case .Energy:
                    
                    if let hourWithMaxEnergy: Int = graphValues.indexOf({ $0 == graphValues.maxElement() })
                    {
                        recommendations.append("You have most energy at \(StringHelper.getLocalizedShortTimeDescriptionAtHour(hourWithMaxEnergy + LogHelper.alarmStartTime.hour)). Do important and exhausting tasks at this time.")
                    }
                    
                    if let hourWithLeastEnergy: Int = graphValues.indexOf({ $0 == graphValues.minElement() })
                    {
                        recommendations.append("You have least energy at \(StringHelper.getLocalizedShortTimeDescriptionAtHour(hourWithLeastEnergy + LogHelper.alarmStartTime.hour)). Do unimportant and relaxing tasks at this time.")
                    }
                    
                case .Happiness:
                    
                    if let hourWithMostHappiness: Int = graphValues.indexOf({ $0 == graphValues.maxElement() })
                    {
                        recommendations.append("You are most happy at \(StringHelper.getLocalizedShortTimeDescriptionAtHour(hourWithMostHappiness + LogHelper.alarmStartTime.hour)). Try to find the reason for it and extend the time doing it.")
                    }
                    
                    if let hourWithLeastHappiness: Int = graphValues.indexOf({ $0 == graphValues.minElement() })
                    {
                        recommendations.append("You most unhappy at \(StringHelper.getLocalizedShortTimeDescriptionAtHour(hourWithLeastHappiness + LogHelper.alarmStartTime.hour)). Try to do something that makes you happy at this time.")
                    }
                    
                    
                case .AllCombined:
                    
                    if let hourWithBestCombinedScore: Int = graphValues.indexOf({ $0 == graphValues.maxElement() })
                    {
                        recommendations.append("Your ultimate time is at \(StringHelper.getLocalizedShortTimeDescriptionAtHour(hourWithBestCombinedScore)). You feel energized, happy and are in flow state. Try to extend and study these moments and how you can achieve them more often.")
                    }
                }
            }
            
            if recommendations.count == 0
            {
                recommendations.append("Sorry, there is not enough data for any recommendations yet. Come back later.")
            }
            
            completion(recommendations)
        })
    }
}