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
}

extension StartVC
{
    // MARK: - View Lifecycle
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.updateProgress()
    }
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)
        
        self.checkDueLogs()
    }
    
    override func viewDidDisappear(animated: Bool)
    {
        super.viewDidDisappear(animated)
        
        // reset progress
        self.progressView.numberOfDaysRemaining = 7
        self.progressView.numberOfLogsRemaining = FLOW_LOGS_PER_WEEK_COUNT
    }
}

extension StartVC   // MARK: - Helper Functions
{
    private func checkDueLogs()
    {
        if NotificationHelper.getLogIsDue()
        {
            self.startLog()
        }
    }
}

extension StartVC   // MARK: - View Update
{
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
        }
        else
        {
            let storyboard = self.storyboard!
            self.presentViewController(storyboard.instantiateViewControllerWithIdentifier("CompletedVC"), animated: true, completion: nil)
        }
    }
}
