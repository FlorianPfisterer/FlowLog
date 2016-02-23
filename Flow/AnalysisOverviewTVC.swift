//
//  AnalysisOverviewTVC.swift
//  FlowLog
//
//  Created by Florian Pfisterer on 08/01/16.
//  Copyright © 2016 Florian Pfisterer. All rights reserved.
//

import UIKit
import MessageUI

class AnalysisOverviewTVC: UITableViewController
{
    @IBAction func doneButtonPressed(sender: UIBarButtonItem)
    {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

extension AnalysisOverviewTVC: MFMailComposeViewControllerDelegate
{
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        if indexPath.section == 2       // tell us idea
        {
            let mailComposerVC = MFMailComposeViewController()
            mailComposerVC.mailComposeDelegate = self
            mailComposerVC.navigationBar.tintColor = TINT_COLOR
            
            mailComposerVC.setToRecipients(["flow@florianpfisterer.de"])
            mailComposerVC.setSubject("I've got a great idea for a new FlowLog analysis!")
            mailComposerVC.setMessageBody("<p>Here's my idea for a new FlogLog analysis:</p>", isHTML: true)
            
            if MFMailComposeViewController.canSendMail()
            {
                self.presentViewController(mailComposerVC, animated: true, completion: nil)
            }
            else
            {
                let alert = UIAlertController(title: "An error occured", message: "Please try again later.", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "Okay", style: .Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
                
                tableView.deselectRowAtIndexPath(indexPath, animated: true)
            }
        }
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?)
    {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
}