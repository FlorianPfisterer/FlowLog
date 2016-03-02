//
//  IntroAnalysesInfoVC.swift
//  FlowLog
//
//  Created by Florian Pfisterer on 01.03.16.
//  Copyright © 2016 Florian Pfisterer. All rights reserved.
//

import UIKit

class IntroAnalysesInfoVC: UIViewController
{
    @IBOutlet weak var bottomHeadlineView: CircularHeadlineView!
    
    private var changeToMainOverviewOnNextPresentation = false
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        if UIScreen.mainScreen().bounds.size.height < 568
        {
            // iPhone 4s
            self.bottomHeadlineView.alpha = 0
        }
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBarHidden = true
    }
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)
        
        if self.changeToMainOverviewOnNextPresentation
        {
            self.changeToMainOverviewOnNextPresentation = false
            let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
            if let rootVC = mainStoryboard.instantiateInitialViewController()
            {
                self.presentViewController(rootVC, animated: true, completion: nil)
            }
        }
    }
}

extension IntroAnalysesInfoVC
{
    @IBAction func proceedToFirstLog()
    {
        NotificationHelper.currentWeekIndex = 1
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: INTRO_DONE_BOOL_KEY)
        
        let storyboard = UIStoryboard(name: "Log", bundle: nil)
        if let rootVC = storyboard.instantiateInitialViewController()
        {
            self.changeToMainOverviewOnNextPresentation = true
            self.presentViewController(rootVC, animated: true, completion: nil)
        }
        else
        {
            let alert = UIAlertController(title: "An error occured", message: "Please try again later. Thank you.", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
        // for security reasons, schedule a log immediately
        if NotificationHelper.shouldScheduleNotification()
        {
            let scheduleCompletion = AUTOMATIC_VC_NOTIFICATION_COMPLETION(vc: self, success: nil, failure: nil)
            NotificationHelper.scheduleNextNotification(completion: scheduleCompletion)
        }
    }
}
