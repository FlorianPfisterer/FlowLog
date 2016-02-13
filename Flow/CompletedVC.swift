//
//  CompletedVC.swift
//  FlowLog
//
//  Created by Florian Pfisterer on 12.02.16.
//  Copyright © 2016 Florian Pfisterer. All rights reserved.
//

import UIKit

class CompletedVC: UIViewController
{
    @IBOutlet weak var awardView: AwardView!
    @IBOutlet weak var congratsLabel: UILabel!
    
    @IBOutlet weak var summaryTextView: UITextView!
    
    @IBOutlet weak var analysisButton: UIButton!
    @IBOutlet weak var newFlowLogWeekButton: UIButton!
}

extension CompletedVC   // MARK: View Lifecycle
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.summaryTextView.alpha = 0
        self.analysisButton.alpha = 0
        self.newFlowLogWeekButton.alpha = 0
        self.congratsLabel.alpha = 0
        self.awardView.alpha = 0
        
        self.awardView.transform = CGAffineTransformMakeScale(0.7, 0.7)
        self.congratsLabel.transform = CGAffineTransformMakeScale(0.6, 0.6)
    }
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)
        
        // animate the UI to pop in
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 2, options: .CurveEaseInOut, animations: {
            
            self.awardView.alpha = 1
            self.awardView.transform = CGAffineTransformMakeScale(1, 1)
            
        }, completion: nil)
        
        UIView.animateWithDuration(0.7, delay: 0.5, usingSpringWithDamping: 0.3, initialSpringVelocity: 4, options: .CurveEaseOut, animations: {
            
            self.congratsLabel.alpha = 1
            self.congratsLabel.transform = CGAffineTransformMakeScale(1, 1)
            
        }, completion: nil)
        
        UIView.animateWithDuration(0.4, delay: 1, options: .CurveEaseInOut, animations: {
            
            self.summaryTextView.alpha = 1
            
        }, completion: { _ in
            
            UIView.animateWithDuration(0.4, delay: 0.1, options: .CurveEaseOut, animations: {
                
                self.analysisButton.alpha = 1
                
            }, completion: nil)
            
            UIView.animateWithDuration(0.5, delay: 0.3, options: .CurveEaseOut, animations: {
                
                self.newFlowLogWeekButton.alpha = 1
                
            }, completion: nil)
            
        })
        
        
    }
}

extension CompletedVC   // MARK: - IBActions
{
    @IBAction func startNewFlowLogWeek()
    {
        NotificationHelper.scheduleNextNotification(completion: { success in
            
            if success
            {
                self.dismissViewControllerAnimated(true, completion: nil)
            }
            else
            {
                let alert = UIAlertController(title: "An error occurred.", message: "Please try again later", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "Okay", style: .Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
        })
    }
}
















