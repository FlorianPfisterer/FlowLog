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
    var flowActivities: [(Activity, Float)] = []
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
        self.flowActivities.removeAll()
        
        let context = CoreDataHelper.managedObjectContext()
        let flowLogsCount: Int = AnalysisHelper.getNumberOfLogs(inFlowState: .Flow, context: context)
        
        if flowLogsCount >= 2
        {
            let allUsedFlowActivities = AnalysisHelper.getSortedActivities(fromFlowState: .Flow, context: context)
            
            var sum: Int = 0
            for activity in allUsedFlowActivities
            {
                sum += Int(activity.used)
            }
            
            if sum != 0
            {
                for activity in allUsedFlowActivities
                {
                    self.flowActivities.append((activity, Float(activity.used)/Float(sum)))
                }
            }
            
            self.flowActivities.sortInPlace({ $0.1 > $1.1 })
        }
        else
        {
            let alert = UIAlertController(title: "Not enough data yet", message: "Come back later after doing at least 2 logs with flow state.", preferredStyle: .Alert)
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
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.flowActivities.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("activityCell")!
        
        let (activity, percentage) = self.flowActivities[indexPath.row]
        
        cell.textLabel?.text = activity.getName()
        cell.detailTextLabel?.text = "\(Int(percentage*100))%"
        
        let maxPercentage = self.flowActivities.map({ $0.1 }).maxElement()!
        
        let alpha: CGFloat = 0.7 * (CGFloat(percentage) / CGFloat(maxPercentage))
        cell.backgroundColor = UIColor.gradientStartColor().colorWithAlphaComponent(alpha)
        cell.textLabel?.backgroundColor = UIColor.clearColor()
        cell.detailTextLabel?.backgroundColor = UIColor.clearColor()
        
        cell.textLabel?.textColor = alpha > 0.48 ? UIColor.whiteColor() : UIColor.blackColor()
        cell.detailTextLabel?.textColor = alpha > 0.48 ? UIColor.whiteColor() : UIColor.darkGrayColor()
        
        return cell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        if self.flowActivities.count > 0
        {
            return "Quota of all flow logs"
        }
        
        return nil
    }
}