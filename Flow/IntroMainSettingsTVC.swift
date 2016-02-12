//
//  IntroMainSettingsTVC.swift
//  Flow
//
//  Created by Florian Pfisterer on 05/01/16.
//  Copyright © 2016 Florian Pfisterer. All rights reserved.
//

import UIKit

class IntroMainSettingsTVC: UITableViewController
{
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    
    @IBOutlet weak var weekStartLabel: UILabel!
    
    var datePreset: NSDate?
}

extension IntroMainSettingsTVC      // MARK: - View Lifecycle
{
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
}

extension IntroMainSettingsTVC  // MARK: - IBActions
{
    func proceedToCreatingAlarms()
    {
        let startTime = Time(date: self.startDatePicker.date)
        let endTime = Time(date: self.endDatePicker.date)
        
        if endTime.absoluteMinutes - startTime.absoluteMinutes < 180        // to small time frame
        {
            let alert = UIAlertController(title: "Time frame too short", message: "Please select a time frame that is at least 3 hours long", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        else
        {
            LogHelper.alarmStartTime = startTime
            LogHelper.alarmEndTime = endTime
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
    }
    
    @IBAction func startDateValueChanged(sender: UIDatePicker)
    {
        self.endDatePicker.minimumDate = sender.date
    }
    
    @IBAction func endDateValueChanged(sender: UIDatePicker)
    {
        self.startDatePicker.maximumDate = sender.date
    }
}

extension IntroMainSettingsTVC: LogWeekStartDateSettingsDelegate      // MARK: - LogWeekStartDateSettingsDelegate
{
    func didSetStartDateTo(date: NSDate)
    {
        self.datePreset = date
        self.weekStartLabel.text = getRelativeDateDescription(date)
    }
}
