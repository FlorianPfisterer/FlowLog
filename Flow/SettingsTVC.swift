//
//  SettingsTVC.swift
//  Flow
//
//  Created by Florian Pfisterer on 03/01/16.
//  Copyright © 2016 Florian Pfisterer. All rights reserved.
//

import UIKit
import MessageUI

class SettingsTVC: UITableViewController
{
    
}

extension SettingsTVC       // MARK: - View Lifecycle
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.title = "More"
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
    }
}

extension SettingsTVC: MFMailComposeViewControllerDelegate      // MARK: - Table View
{
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        if indexPath.section == 0 && indexPath.row == 1       // "Get Involved" Cell
        {
            let mailComposerVC = MFMailComposeViewController()
            mailComposerVC.mailComposeDelegate = self
            mailComposerVC.navigationBar.tintColor = TINT_COLOR
            
            mailComposerVC.setToRecipients(["flow@florianpfisterer.de"])
            mailComposerVC.setSubject("I would like to get involved in the FlowLog app!")
            mailComposerVC.setMessageBody("<p>Hey Florian, <br /></p>", isHTML: true)
            
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
        else if indexPath.section == 0 && indexPath.row == 0
        {
            if let url = NSURL(string: "http://florianpfisterer.de/flow")
            {
                UIApplication.sharedApplication().openURL(url)
            }
            else
            {
                let alert = UIAlertController(title: "An error occured", message: "Please try again later. Thank you.", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "Okay", style: .Cancel, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?)
    {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
}