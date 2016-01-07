//
//  AreYouInFlowVC.swift
//  Flow
//
//  Created by Florian Pfisterer on 03/01/16.
//  Copyright © 2016 Florian Pfisterer. All rights reserved.
//

import UIKit

class AreYouInFlowVC: UIViewController, FlowViewDelegate
{
    @IBOutlet weak var flowView: FlowView!
    @IBOutlet weak var saveLogButton: UIButton!
    @IBOutlet weak var challengeAxisLabel: UILabel!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        
        self.challengeAxisLabel.center = CGPoint(x: self.flowView.frame.origin.x/2 + 5, y: self.flowView.frame.origin.y + self.challengeAxisLabel.bounds.size.width/2)
        
        self.flowView.delegate = self
        self.setNewSelectionLocation(x: 0.5, y: 0.5, alpha: 1)
    }
    
    // MARK: - FlowViewDelegate
    func setNewSelectionLocation(x x: CGFloat, y: CGFloat, alpha: CGFloat = 0.9)
    {
        self.view.backgroundColor = UIColor(red: x, green: y, blue: 0.5, alpha: alpha)
    }
    
    func updateFlowState(flowState: FlowState)
    {
        self.saveLogButton.setTitle(String(flowState), forState: .Normal)
    }
    
    // MARK: - IBActions
    @IBAction func saveLog()
    {
        self.saveLogButton.setTitle("SAVING...", forState: .Normal)
        self.saveLogButton.enabled = false
        
        UIView.animateWithDuration(0.2, animations: {
            self.saveLogButton.backgroundColor = UIColor(red: 0.6, green: 0.84, blue: 0.29, alpha: 1)   // nice green color
        })
        
        LogHelper.flowState = self.flowView.getFlowState()
        
        LogHelper.saveCurrentLog() { success, logEntry in
            if success
            {
                self.saveLogButton.setTitle("LOG ENTRY SAVED", forState: .Normal)
                
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
        }
    }
    
    override func startLogWithOptions(options: [String : AnyObject]?)
    {
        print("already doing log")
    }
}
