//
//  IntroLogWeekStartDateTVC.swift
//  Flow
//
//  Created by Florian Pfisterer on 05/01/16.
//  Copyright © 2016 Florian Pfisterer. All rights reserved.
//

import UIKit

class IntroLogWeekStartDateTVC: UITableViewController
{
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var quoteLabel: UILabel!
    
    var delegate: LogWeekStartDateSettingsDelegate!
    var datePreset: NSDate!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.startDatePicker.minimumDate = NSDate() // not earlier than today
        self.quoteLabel.text = self.getRandomProcrastinationQuote()
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.startDatePicker.date = self.datePreset
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        super.viewWillDisappear(animated)
        
        self.delegate.didSetStartDateTo(self.startDatePicker.date)
    }
    
    private func getRandomProcrastinationQuote() -> String
    {
        let procrastinationQuotes = ["Procrastination is the thief of time.", "A stitch in time saves nine.", "There is no time like the present.", "Never put off till tomorrow what you can do today."]
        let randomIndex = Int(arc4random_uniform(UInt32(procrastinationQuotes.count)))
        return "\"\(procrastinationQuotes[randomIndex])\""
    }
}

protocol LogWeekStartDateSettingsDelegate
{
    func didSetStartDateTo(date: NSDate)
}