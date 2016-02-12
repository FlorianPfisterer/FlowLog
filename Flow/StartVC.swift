//
//  StartVC.swift
//  Flow
//
//  Created by Florian Pfisterer on 03/01/16.
//  Copyright © 2016 Florian Pfisterer. All rights reserved.
//

import UIKit

class StartVC: UIViewController
{
    @IBOutlet weak var progressView: ProgressView!
    @IBOutlet weak var nextLogLabel: UILabel!
    
    private static let NEXT_LOG = "Next log: "
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)
        
        //let storyboard = self.storyboard!
        //self.presentViewController(storyboard.instantiateViewControllerWithIdentifier("CompletedVC"), animated: true, completion: nil)
        
        self.updateProgress()
        
        if !LogHelper.didDueLog
        {
            self.checkDueLogs()
        }
        else
        {
            doDelayed(inSeconds: 180, completion: {
                LogHelper.didDueLog = false
                self.checkDueLogs()
            })
        }
    }
    
    private func checkDueLogs()
    {
        let (dueNotificationsAvailable, nr) = NotificationHelper.getDueLogNofitications()
        if dueNotificationsAvailable && LogHelper.currentTimeIsInBoundaries()
        {
            LogHelper.currentLogNr = nr
            self.startLogWithLogNr(nr)
        }
    }
    
    override func viewDidDisappear(animated: Bool)
    {
        super.viewDidDisappear(animated)
        
        // reset progress
        self.progressView.numberOfDaysRemaining = 7
        self.progressView.numberOfLogsRemaining = FLOW_LOGS_PER_WEEK_COUNT
    }
    
    // MARK: - View Update
    func updateProgress()
    {
        let (logsRemaningBool, numberOfLogsRemaining) = LogHelper.getRemainingFlowLogsInCurrentWeek()
        if logsRemaningBool
        {
            // 1. days
            let numberOfDaysRemaining = LogHelper.getRemainingDaysInCurrentWeek()
            self.progressView.numberOfDaysRemaining = numberOfDaysRemaining
            
            // 2. logs
            self.progressView.numberOfLogsRemaining = numberOfLogsRemaining
            
            // 3. next log date
            if let nextLogDate = NotificationHelper.getNextNotificationDate()
            {
                self.nextLogLabel.text = StartVC.NEXT_LOG + getRelativeDateDescription(nextLogDate, time: true)
            }
            else
            {
                
                self.nextLogLabel.text = "All current logs completed!"
            }
        }
        else
        {
            /*let alert = UIAlertController(title: "Congratulations!", message: "You have completed all FlowLogs. Check out the analysis of the data. Do you want to start a new FlowLog-week (to make the analyses more exact)?", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "New Week", style: .Default, handler: { _ in
                
            }))
            alert.addAction(UIAlertAction(title: "Show Analyses", style: .Default, handler: { _ in
                self.performSegueWithIdentifier("showAnalysisSegue", sender: nil)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)*/
        }
    }
}
