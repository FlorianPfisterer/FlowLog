//
//  AllLogsOverviewTVC.swift
//  FlowLog
//
//  Created by Florian Pfisterer on 09.03.16.
//  Copyright © 2016 Florian Pfisterer. All rights reserved.
//

import UIKit

class AllLogsOverviewTVC: UITableViewController
{
    var logs = [LogEntry]()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.title = "All Logs"
        
        self.view.backgroundColor = UIColor.whiteColor()
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        self.reloadLogData()
    }
}

extension AllLogsOverviewTVC
{
    private func reloadLogData()
    {
        let context = CoreDataHelper.managedObjectContext()
        self.logs = AnalysisHelper.getLogs(context: context).sort { $0.createdAt > $1.createdAt }
        self.tableView.reloadData()
    }
}

extension AllLogsOverviewTVC
{
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        return self.logs.count == 0 ? nil : "Ordered by date (\(self.logs.count))"
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.logs.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("logCell") as! LogCell
        cell.configureWithLog(self.logs[indexPath.row])
        return cell
    }
}