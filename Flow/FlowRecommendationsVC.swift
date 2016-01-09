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
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.setupGraphDisplay()
    }
    
    // MARK: - Update UI
    func setupGraphTimeLabels()
    {
        self.startTimeLabel.text = "\(self.roundedStartHour)"
        self.endTimeLabel.text = "\(self.roundedEndHour)"
        
        // calculate middle hours
        let difference_3 = Int(round(Double(roundedEndHour - roundedStartHour) / 3))
        
        self.middleLeftTimeLabel.text = "\(roundedStartHour + difference_3)"         // TODO! localized 3p 3a etc.
        self.middleRightTimeLabel.text = "\(roundedEndHour - difference_3)"
    }
    
    func setupGraphDisplay()
    {
        // 1. setup graph data
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
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("recommendationCell")!
        
        return cell
    }
}
