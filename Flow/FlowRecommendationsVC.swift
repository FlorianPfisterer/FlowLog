//
//  FlowRecommendationsVC.swift
//  FlowLog
//
//  Created by Florian Pfisterer on 09/01/16.
//  Copyright © 2016 Florian Pfisterer. All rights reserved.
//

import UIKit
import CoreData

class FlowRecommendationsVC: UIViewController
{
    // MARK: - IBOutlets
    @IBOutlet weak var diagramView: DiagramView!
//    @IBOutlet weak var bannerView: GADBannerView!
//    @IBOutlet weak var bannerViewHeightConstraint: NSLayoutConstraint!
    
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
        didSet
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
}

extension FlowRecommendationsVC     // MARK: - View Lifecycle
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.setupGraphTimeLabels()
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 100
        
        // manage ad banner
//        self.bannerView.rootViewController = self
//        if DEBUG
//        {
//            self.bannerViewHeightConstraint.constant = 0
//        }
//        else
//        {
//            setupBannerView(self.bannerView, forAd: .AnalysisGeneralBottomBanner)
//        }
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.setupGraphDisplay()
        
//        handleAdBannerShowup(heightConstraint: self.bannerViewHeightConstraint)
    }
}

extension FlowRecommendationsVC     // MARK: - Update UI
{
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
        // 1. setup graph
        let context = CoreDataHelper.managedObjectContext()
        let graphValues = AnalysisHelper.getGraphValues(forState: self.graphDisplayState, context: context)
        let mappedGraphValues = graphValues.map({ $0 == nil ? 0 : $0! })
        
        self.diagramView.graphPoints = mappedGraphValues
        self.diagramView.setNeedsDisplay()
        
        // 2. setup average label
        self.setupAverageLabels(mappedGraphValues)
        
        // 3. setup recommendations in tableView (async)
        self.recommendations.removeAll()
        switch self.graphDisplayState
        {
        case .FlowState:
            RecommendationsHelper.getFlowReccomendations(flowValues: graphValues, context: context, completion: { recs in
                self.recommendations = recs
                self.tableView.reloadData()
            })
            
        default:
            RecommendationsHelper.getRecommendations(fromValues: graphValues, graphState: self.graphDisplayState, context: context, completion: { recs in
                self.recommendations = recs
                self.tableView.reloadData()
            })
        }
        
        // 4. setup title as well as min and max labels
        self.setupGraphLabels(mappedGraphValues)
    }
}

extension FlowRecommendationsVC
{
    private func setupAverageLabels(graphValues: [CGFloat])
    {
        if graphValues.count != 0
        {
            var sum: CGFloat = 0
            for item in graphValues
            {
                sum += item
            }
            
            let amount: Int = graphValues.filter({ $0 != 0 }).count
            
            if amount != 0
            {
                let averageValue: CGFloat = sum/CGFloat(amount)
                switch self.graphDisplayState
                {
                case .FlowState:
                    self.averageLabel.text = "\(StringHelper.format(".2", value: averageValue))"
                    
                case .Happiness, .Energy, .AllCombined:
                    self.averageLabel.text = "\(StringHelper.format(".0", value: averageValue*100))%"
                }
            }
            else
            {
                self.averageLabel.text = "None"
            }
        }
    }
    
    private func setupGraphLabels(graphValues: [CGFloat])
    {
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
        
        self.graphTitleLabel.text = self.graphDisplayState.stringDescription
    }
}

extension FlowRecommendationsVC     // MARK: - IBActions
{
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
}

extension FlowRecommendationsVC: UITableViewDelegate, UITableViewDataSource     // MARK: - TableView
{
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
