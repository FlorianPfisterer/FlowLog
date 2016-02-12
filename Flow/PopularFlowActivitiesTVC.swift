//
//  PopularFlowActivitiesTVC.swift
//  FlowLog
//
//  Created by Florian Pfisterer on 09/01/16.
//  Copyright © 2016 Florian Pfisterer. All rights reserved.
//

import UIKit

class PopularFlowActivitiesTVC: UITableViewController
{
    var upperFlowActivities: [(Activity, CGFloat)] = []
    var lowerFlowActivities: [(Activity, CGFloat)] = []
}

extension PopularFlowActivitiesTVC      // MARK: - View Lifecycle
{
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)
        
        self.loadFlowActivities()
        self.tableView.reloadData()
    }
    
}

extension PopularFlowActivitiesTVC      // MARK: - Load Data
{
    func loadFlowActivities()
    {
        let context = CoreDataHelper.managedObjectContext()
        let flowLogsCount: Int = AnalysisHelper.getNumberOfLogs(inFlowState: .Flow, context: context)
        let allUsedActivities = AnalysisHelper.getSortedActivities(fromFlowState: .Flow, context: context)
        
        self.upperFlowActivities.removeAll()
        self.lowerFlowActivities.removeAll()
        
        if allUsedActivities.count != 0 && flowLogsCount > 5
        {
            var sum: Int = 0
            for activity in allUsedActivities
            {
                sum += Int(activity.used)
            }
            
            if sum != 0
            {
                let averageActivityUse = CGFloat(sum) / CGFloat(allUsedActivities.count)
                
                for activity in allUsedActivities
                {
                    if CGFloat(activity.used) >= averageActivityUse
                    {
                        self.upperFlowActivities.append((activity, CGFloat(activity.used)/CGFloat(sum)))
                    }
                    else
                    {
                        self.lowerFlowActivities.append((activity, CGFloat(activity.used)/CGFloat(sum)))
                    }
                }
            }
        }
        else
        {
            let alert = UIAlertController(title: "Not enough data yet", message: "Come back later after doing a few logs.", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .Default, handler: { _ in
                self.navigationController?.popViewControllerAnimated(true)
            }))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
}

extension PopularFlowActivitiesTVC      // MARK: - TableView
{
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        switch section
        {
        case 0:
            return self.upperFlowActivities.count
        case 1:
            return self.lowerFlowActivities.count
        default:
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("activityCell")!
        var activity: Activity
        var percentage: CGFloat
        
        switch indexPath.section
        {
        case 0:
            (activity, percentage) = self.upperFlowActivities[indexPath.row]
        default:
            (activity, percentage) = self.lowerFlowActivities[indexPath.row]
        }
        
        cell.textLabel?.text = activity.getName()
        cell.detailTextLabel?.text = "\(Int(percentage*100))%"
        
        return cell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        if self.upperFlowActivities.count > 0
        {
            switch section
            {
            case 0:
                return "Activities with much flow potential"
            default:
                return "Activities with little flow potential"
            }
        }
        
        return nil
    }
}