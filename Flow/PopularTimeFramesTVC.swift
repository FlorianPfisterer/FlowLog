//
//  PopularTimeFramesTVC.swift
//  FlowLog
//
//  Created by Florian Pfisterer on 09/01/16.
//  Copyright © 2016 Florian Pfisterer. All rights reserved.
//

import UIKit

class PopularTimeFramesTVC: UITableViewController
{
    var timeFrames = [TimeFrame]()
}

extension PopularTimeFramesTVC      // MARK: - View Lifecycle
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.title = "Popular Time Frames"
    }
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)
        
        self.loadTimeFrames()
        self.tableView.reloadData()
    }
}

extension PopularTimeFramesTVC
{
    private func loadTimeFrames()
    {
        self.timeFrames.removeAll()
        
        let context = CoreDataHelper.managedObjectContext()
        let allFlowLogs = AnalysisHelper.getLogs(inFlowState: .Flow, context: context)
    
        if allFlowLogs.count >= 2
        {
            self.timeFrames = allFlowLogs.reduce([TimeFrame](), combine: { result, log in
            
                if let frame = result.filter({ $0 <=> log.date }).first
                {
                    frame.flowStateCount = frame.flowStateCount + 1
                    return result
                }
                else
                {
                    let newFrame = TimeFrame(startTime: Time(date: log.date))
                    return result + [newFrame]
                }
            }).sort({ $0.flowStateCount > $1.flowStateCount })
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

extension PopularTimeFramesTVC      // MARK: - Table View
{
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("timeFrameCell")!
        let timeFrame = self.timeFrames[indexPath.row]
        
        cell.textLabel?.text = timeFrame.title
        cell.detailTextLabel?.text = timeFrame.detail
        
        let maxFlowStateCount = self.timeFrames.map({ $0.flowStateCount }).maxElement()!
        
        let alpha: CGFloat = 0.7 * (CGFloat(timeFrame.flowStateCount) / CGFloat(maxFlowStateCount))
        cell.backgroundColor = UIColor.gradientStartColor().colorWithAlphaComponent(alpha)
        cell.textLabel?.backgroundColor = UIColor.clearColor()
        cell.detailTextLabel?.backgroundColor = UIColor.clearColor()
        
        cell.textLabel?.textColor = alpha > 0.48 ? UIColor.whiteColor() : UIColor.blackColor()
        cell.detailTextLabel?.textColor = alpha > 0.48 ? UIColor.whiteColor() : UIColor.darkGrayColor()
        
        return cell
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.timeFrames.count
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        return "Time frames with logs in flow state"
    }
}