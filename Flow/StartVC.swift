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
    
    private static let NEXT_LOG = "Next log: "
    
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
        
        let (dueNotificationsAvailable, nr) = NotificationHelper.getDueLogNofitications()
        if dueNotificationsAvailable
        {
            LogHelper.currentLogNr = nr
            self.startLogWithLogNr(nr)
        }
    }
    
    // MARK: - View Update
    func updateProgressLabels()
    {
        self.daysLabel.text = "7"   // TODO!
        let (logsRemaning, difference) = LogHelper.getRemainingFlowLogsInCurrentWeek()
        if logsRemaning
        {
            self.alarmsLabel.text = "\(difference)"
            
            // next log
            self.nextLogLabel.text = StartVC.NEXT_LOG + getRelativeDateDescription(NotificationHelper.getNextNotificationDate(), time: true)
        }
        else
        {
            let alert = UIAlertController(title: "Congratulations!", message: "You have completed all notifications. Check out the analysis of the data. Do you want to start a new FlowLog-week (to make the analyses more exact)?", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "New Week", style: .Default, handler: { _ in
                
            }))
            alert.addAction(UIAlertAction(title: "Show Analyses", style: .Default, handler: { _ in
                self.performSegueWithIdentifier("showAnalysisSegue", sender: nil)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
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
    }
}
