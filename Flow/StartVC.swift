//
//  StartVC.swift
//  Flow
//
//  Created by Florian Pfisterer on 03/01/16.
//  Copyright © 2016 Florian Pfisterer. All rights reserved.
//

import UIKit
import GoogleMobileAds

class StartVC: UIViewController
{
    @IBOutlet weak var progressView: ProgressView!
    @IBOutlet weak var nextLogLabel: UILabel!
    @IBOutlet weak var bannerView: GADBannerView!
    
    @IBOutlet weak var bannerViewHeightConstraint: NSLayoutConstraint!
    
    private var notificationAlertShown = false
}

extension StartVC
{
    // MARK: - View Lifecycle
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.bannerView.rootViewController = self
        
        if DEBUG
        {
            self.bannerViewHeightConstraint.constant = 0
        }
        else
        {
            setupBannerView(self.bannerView, forAd: .OverviewBottomBanner)
        }
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(self.proceedToLog))
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.updateProgress()
        
        handleAdBannerShowup(heightConstraint: self.bannerViewHeightConstraint)
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
        else if !self.notificationAlertShown
        {
            let completion = {
                // for security reasons, in case there is no notification scheduled
                if NotificationHelper.shouldScheduleNotification()
                {
                    let scheduleCompletion = AUTOMATIC_VC_NOTIFICATION_COMPLETION(vc: self, success: nil, failure: nil)
                    NotificationHelper.scheduleNextNotification(completion: scheduleCompletion)
                }
            }
            
            if let alert = checkNotificationsEnabled(completion)
            {
                self.presentViewController(alert, animated: true, completion: nil)
                self.notificationAlertShown = true
            }
        }
    }
}

extension StartVC
{
    override func startLog()
    {
        if let _ = self.presentedViewController
        {
            print("already presenting ViewController!")
            
            // in order not to end the notification process if another ViewController is presented (unrelated to log)
            NotificationHelper.scheduleNextNotification(completion: NOTIFICATION_COMPLETION_HANDLER_NONE)    // this notification will be deleted if a log is being created
            
            return
        }
        
        let message = "It's time to create a log!"
        let alert = UIAlertController(title: "Do a log now", message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { _ in
            // if the user cancels the log, no notification is left => process will end => schedule a new one
            let completion = AUTOMATIC_VC_NOTIFICATION_COMPLETION(vc: self, success: nil, failure: nil)
            NotificationHelper.scheduleNextNotification(completion: completion)
            
// NEW:     // reload Progress Views
            self.updateProgress()
        }))
        alert.addAction(UIAlertAction(title: "Let's go!", style: .Default, handler: { _ in
            self.proceedToLog()
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func proceedToLog()
    {
        let storyboard = UIStoryboard(name: "Log", bundle: nil)
        if let rootVC = storyboard.instantiateInitialViewController()
        {
            self.presentViewController(rootVC, animated: true, completion: nil)
        }
    }
}

extension StartVC   // MARK: - View Update
{
    func updateProgress()
    {
        // next log label
        if let fireDate = NotificationHelper.logFireDateScheduledNotYetExecuted
        {
            let timeDescription = getRelativeDateDescription(fireDate, time: true)
            self.nextLogLabel.text = NEXT_LOG + ": " + timeDescription
        }
        
        
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
