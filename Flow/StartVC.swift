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
    @IBOutlet weak var daysLabel: UILabel!
    @IBOutlet weak var alarmsLabel: UILabel!
    @IBOutlet weak var nextLogLabel: UILabel!
    @IBOutlet weak var quoteTextView: UITextView!
    
    private static let NEXT_LOG = "NEXT LOG: "
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.showQuoteOfTheDay()
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.updateProgressLabels()
    }
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)
        
        print("Checking if overdue notifications available")
        let (dueNotificationsAvailable, nr) = NotificationHelper.getDueLogNofitications()
        if dueNotificationsAvailable
        {
            LogHelper.currentLogNr = nr
            self.startLogWithLogNr(nr)
        }
        print("done checking if overdue notifications available")
    }
    
    // MARK: - View Update
    func updateProgressLabels()
    {
        self.daysLabel.text = "7"   // TODO!
        let (logsRemaning, difference) = LogHelper.getRemainingFlowLogsInCurrentWeek()
        if logsRemaning
        {
            self.alarmsLabel.text = "\(difference)"
        }
        else
        {
            // TODO!
        }
        
        // next log
        self.nextLogLabel.text = StartVC.NEXT_LOG + getRelativeDateDescription(NotificationHelper.getNextNotificationDate(), time: true)
    }
    
    func showQuoteOfTheDay()
    {
        guard let path = NSBundle.mainBundle().pathForResource("Quotes", ofType: "plist") else
        {
            return
        }
        
        let array = NSArray(contentsOfFile: path)!
        let randomQuote = array.objectAtIndex(Int(arc4random_uniform(UInt32(array.count)))) as! [String : String]
        
        self.quoteTextView.text = "\(randomQuote["quote"]!) - \(randomQuote["author"]!.uppercaseString)"
        self.quoteTextView.textColor = UIColor.whiteColor()
        self.quoteTextView.font = UIFont.systemFontOfSize(18)
        
        // WEITER: Überlegen, wie bei Intro die Alarmzeiten einstellen + kleine Einführung was die App macht
    }
    
    // MARK: - IBActions
    @IBAction func showStatisticsInfo()
    {
        
    }
}
