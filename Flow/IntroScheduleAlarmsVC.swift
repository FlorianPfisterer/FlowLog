//
//  IntroScheduleAlarmsVC.swift
//  Flow
//
//  Created by Florian Pfisterer on 06/01/16.
//  Copyright © 2016 Florian Pfisterer. All rights reserved.
//

import UIKit

class IntroScheduleAlarmsVC: UIViewController
{
    @IBOutlet weak var weekStartDateLabel: UILabel!
    @IBOutlet weak var alarmTimeBoundariesLabel: UILabel!
    
    @IBOutlet weak var progressView: UIProgressView!

    @IBOutlet weak var proceedButton: UIButton!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.proceedButton.alpha = 0
    
        self.setupSettingsLabels()
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        super.viewWillDisappear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)
        
        NotificationHelper.unscheduleAllCurrentNotifications()  // DEBUG!?
        LogHelper.currentFlowLogCount = 0
        NotificationHelper.scheduleRandomNotificationsStarting(LogHelper.flowLogWeekStartDate!, between: LogHelper.alarmStartTime, and: LogHelper.alarmEndTime) { success in
            if !success
            {
                let alert = UIAlertController(title: "An error occured", message: "Please try again later", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "Okay", style: .Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
            else
            {
                UIView.animateWithDuration(0.4, animations: {
                    self.proceedButton.alpha = 1
                })
                NSUserDefaults.standardUserDefaults().setBool(true, forKey: INTRO_DONE_BOOL_KEY)
            }
        }
    }
    
    func setupSettingsLabels()
    {
        self.weekStartDateLabel.text = "starting \(getRelativeDateDescription(LogHelper.flowLogWeekStartDate!))"
        
        let startTimeDescription = "TODO"
        let endTimeDescription = "TODO"
        
        self.alarmTimeBoundariesLabel.text = "between \(startTimeDescription) and \(endTimeDescription)"
    }
    
    // MARK: - IBActions
    @IBAction func proceedToMainStoryboard()
    {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let initialVC = storyboard.instantiateInitialViewController()!
        
        
        
        self.presentViewController(initialVC, animated: true, completion: nil)
    }
}