//
//  IntroHowItWorksVC.swift
//  FlowLog
//
//  Created by Florian Pfisterer on 28.02.16.
//  Copyright © 2016 Florian Pfisterer. All rights reserved.
//

import UIKit

class IntroHowItWorksVC: UIViewController
{
    @IBOutlet weak var timeIntervalPicker: TimeIntervalPicker!
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBarHidden = true
    }
}

extension IntroHowItWorksVC
{
    @IBAction func proceedToNextStep()
    {
        LogHelper.alarmStartTime = self.timeIntervalPicker.getStartTime()
        LogHelper.alarmEndTime = self.timeIntervalPicker.getEndTime()
        LogHelper.flowLogWeekStartDate = NSDate()
        
        self.performSegueWithIdentifier("goToFlowLogInfoSegue", sender: nil)
    }
}