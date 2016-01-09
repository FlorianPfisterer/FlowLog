//
//  FlowRecommendationsVC.swift
//  FlowLog
//
//  Created by Florian Pfisterer on 09/01/16.
//  Copyright © 2016 Florian Pfisterer. All rights reserved.
//

import UIKit

class FlowRecommendationsVC: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    // MARK: - IBOutlets
    @IBOutlet weak var diagramView: DiagramView!
    
    @IBOutlet weak var graphTitleLabel: UILabel!
    @IBOutlet weak var averageLabel: UILabel!
    @IBOutlet weak var maxLabel: UILabel!
    @IBOutlet weak var minLabel: UILabel!
    
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var middleLeftTimeLabel: UILabel!
    @IBOutlet weak var middleRightTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    
    @IBOutlet weak var graphKindSegmentedControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    var recommendations: [String] = []
    
    var graphDisplayState: GraphDisplayState = .FlowState {     // standard
        didSet (value)
        {
            self.setupGraphDisplay()
        }
    }
    
    let roundedStartHour: Int = {
        return LogHelper.alarmStartTime.roundedTimeHour()
    }()
    
    let roundedEndHour: Int = {
        return LogHelper.alarmEndTime.roundedTimeHour()
    }()
    
    // MARK: - View Lifecycle
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.setupGraphTimeLabels()
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 100
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.setupGraphDisplay()
    }
    
    // MARK: - Update UI
    func setupGraphTimeLabels()
    {
        self.startTimeLabel.text = "\(StringHelper.getLocalizedShortTimeDescriptionAtHour(self.roundedStartHour))"
        self.endTimeLabel.text = "\(StringHelper.getLocalizedShortTimeDescriptionAtHour(self.roundedEndHour))"
        
        // calculate middle hours
        let difference_3 = Int(round(Double(roundedEndHour - roundedStartHour) / 3))
        
        self.middleLeftTimeLabel.text = "\(StringHelper.getLocalizedShortTimeDescriptionAtHour(roundedStartHour + difference_3))"
        self.middleRightTimeLabel.text = "\(StringHelper.getLocalizedShortTimeDescriptionAtHour(roundedEndHour - difference_3))"
    }
    
    func setupGraphDisplay()
    {
        // 1. setup graph data points
        let context = CoreDataHelper.managedObjectContext()
        var graphValues: [CGFloat] = []
        
        for hour in LogHelper.alarmStartTime.hour...LogHelper.alarmEndTime.hour
        {
            switch self.graphDisplayState
            {
            case .FlowState:
                let logCountInFlowInHour = AnalysisHelper.getNumberOfLogsInHour(hour, inFlowState: .Flow, context: context)
                graphValues.append(CGFloat(logCountInFlowInHour))
            
            case .Energy:
                graphValues.append(AnalysisHelper.getAverageEnergyLevelInHour(hour, context: context))
            
            case .Happiness:
                graphValues.append(AnalysisHelper.getAverageHappinessLevelInHour(hour, context: context))
            
            case .AllCombined:
                graphValues.append(AnalysisHelper.getCombinedScoreInHour(hour, inFlowState: .Flow, context: context))
            }
        }
        
        self.diagramView.graphPoints = graphValues
        self.diagramView.setNeedsDisplay()
        
        // 2. setup average label
        if graphValues.count != 0
        {
            var sum: CGFloat = 0
            for item in graphValues
            {
                sum += item
            }
            
            let averageValue: CGFloat = sum/CGFloat(graphValues.count)
            switch self.graphDisplayState
            {
            case .FlowState:
                self.averageLabel.text = "\(StringHelper.format(".2", value: averageValue))"
            
            case .Happiness, .Energy, .AllCombined:
                self.averageLabel.text = "\(StringHelper.format(".0", value: averageValue*100))%"
            }
        }
        
        // 3. setup recommendations in tableView (async)
        RecommendationsHelper.getRecommendationsForGraphState(self.graphDisplayState, graphValues: graphValues, completion: { recommendations in
            self.recommendations = recommendations
            self.tableView.reloadData()
        }, context: context)
        
        // 4. setup min and max labels
        guard let maxValue = graphValues.maxElement() else { return }
        guard let minValue = graphValues.minElement() else { return }
        
        var maxValueInt: Int
        var minValueInt: Int
        
        switch self.graphDisplayState
        {
        case .FlowState:
            maxValueInt = Int(round(maxValue))
            minValueInt = Int(round(minValue))
            
        default:
            maxValueInt = Int(round(maxValue*100))
            minValueInt = Int(round(minValue*100))
        }

        self.minLabel.text = "\(minValueInt)"
        self.maxLabel.text = "\(maxValueInt)"
    }
    
    // MARK: - IBActions
    @IBAction func changeGraphKind(sender: UISegmentedControl)
    {
        if let newState = GraphDisplayState(rawValue: sender.selectedSegmentIndex)
        {
            self.graphDisplayState = newState
        }
        else
        {
            print("ERROR: couldn't find GraphDisplayState for index: \(sender.selectedSegmentIndex)")
        }
    }
    
    // MARK: - TableView
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.recommendations.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("recommendationCell") as! DynamicRecommendationCell
        cell.contentLabel.text = self.recommendations[indexPath.row]
        return cell
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        return "Recommendations"
    }
}
