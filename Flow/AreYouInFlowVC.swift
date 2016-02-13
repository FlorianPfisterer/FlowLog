//
//  AreYouInFlowVC.swift
//  Flow
//
//  Created by Florian Pfisterer on 03/01/16.
//  Copyright © 2016 Florian Pfisterer. All rights reserved.
//

import UIKit

class AreYouInFlowVC: UIViewController
{
    @IBOutlet weak var flowView: FlowView!
    @IBOutlet weak var saveLogButton: UIButton!
    @IBOutlet weak var challengeAxisLabel: UILabel!
}

extension AreYouInFlowVC    // MARK: - View Lifecycle
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        
        self.challengeAxisLabel.center = CGPoint(x: self.flowView.frame.origin.x/2 + 5, y: self.flowView.frame.origin.y + self.challengeAxisLabel.bounds.size.width/2)
        
        self.flowView.delegate = self
        self.setNewSelectionLocation(x: 0.5, y: 0.5, alpha: 1)
    }
}

extension AreYouInFlowVC: FlowViewDelegate      // MARK: - FlowViewDelegate
{
    func setNewSelectionLocation(x x: CGFloat, y: CGFloat, alpha: CGFloat = 0.9)
    {
        self.view.backgroundColor = UIColor(red: x, green: y, blue: 0.5, alpha: alpha)
    }
    
    func updateFlowState(flowState: FlowState)
    {
        self.saveLogButton.setTitle("SAVE " + String(flowState), forState: .Normal)
    }
}

extension AreYouInFlowVC        // MARK: - IBActions
{
    @IBAction func saveLog()
    {
        self.saveLogButton.setTitle("SAVING...", forState: .Normal)
        self.saveLogButton.enabled = false
        
        UIView.animateWithDuration(0.2, animations: {
            self.saveLogButton.backgroundColor = BAR_TINT_COLOR
        })
        
        LogHelper.flowState = self.flowView.getFlowState()
        
        LogHelper.saveCurrentLog() { success, logEntry in
            if success
            {
                self.saveLogButton.setTitle("LOG SAVED", forState: .Normal)
                
                if NotificationHelper.shouldScheduleNotification()
                {
                    NotificationHelper.scheduleNextNotification(completion: nil)        // after completing the log, schedule the next notification if needed
                }
                
                if let _ = self.presentingViewController
                {
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
                else
                {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let destinationVC = storyboard.instantiateInitialViewController()!
                    
                    self.presentViewController(destinationVC, animated: true, completion: nil)
                }
            }
            else
            {
                self.saveLogButton.setTitle("ERROR. TRY AGAIN", forState: .Normal)
                self.saveLogButton.enabled = true
            }
        }
    }
}

extension AreYouInFlowVC
{
    override func startLog()
    {
        print("already doing log, incoming request")
    }
}
