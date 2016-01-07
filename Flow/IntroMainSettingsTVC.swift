//
//  IntroMainSettingsTVC.swift
//  Flow
//
//  Created by Florian Pfisterer on 05/01/16.
//  Copyright © 2016 Florian Pfisterer. All rights reserved.
//

import UIKit

class IntroMainSettingsTVC: UITableViewController, LogWeekStartDateSettingsDelegate
{
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    
    @IBOutlet weak var weekStartLabel: UILabel!
    
    var datePreset: NSDate?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "proceedToCreatingAlarms")
        
        // TODO! make sure that !endDate < startDate
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if segue.identifier == "setLogWeekDateSegue"
        {
            let destinationVC = segue.destinationViewController as! IntroLogWeekStartDateTVC
            destinationVC.delegate = self
            
            if let date = self.datePreset
            {
                destinationVC.datePreset = date
            }
            else
            {
                destinationVC.datePreset = NSDate() // today
            }
        }
    }
    
    // MARK: - IBActions
    func proceedToCreatingAlarms()
    {
        LogHelper.alarmStartTime = Time(date: self.startDatePicker.date)
        LogHelper.alarmEndTime = Time(date: self.endDatePicker.date)
        if let date = self.datePreset
        {
            LogHelper.flowLogWeekStartDate = date
        }
        else
        {
            LogHelper.flowLogWeekStartDate = NSDate()   // standard: today
        }
        
        self.performSegueWithIdentifier("proceedToCreatingAlarms", sender: nil)
    }
    
    // MARK: - LogWeekStartDateSettingsDelegate
    func didSetStartDateTo(date: NSDate)
    {
        self.datePreset = date
        self.weekStartLabel.text = getRelativeDateDescription(date)
    }
}