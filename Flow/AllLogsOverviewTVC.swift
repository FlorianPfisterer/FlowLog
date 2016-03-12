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
    
}

extension AllLogsOverviewTVC
{
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("logCell") as! LogCell
        
        return cell
    }
}