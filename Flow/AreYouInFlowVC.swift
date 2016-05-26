//
//  AreYouInFlowVC.swift
//  Flow
//
//  Created by Florian Pfisterer on 03/01/16.
//  Copyright © 2016 Florian Pfisterer. All rights reserved.
//

import UIKit
import GoogleMobileAds

class AreYouInFlowVC: UIViewController
{
    @IBOutlet weak var flowView: FlowView!
    @IBOutlet weak var saveLogButton: UIButton!
    @IBOutlet weak var challengeAxisLabel: UILabel!
    @IBOutlet weak var bannerView: GADBannerView!
    @IBOutlet weak var bannerViewHeightConstraint: NSLayoutConstraint!
}

extension AreYouInFlowVC    // MARK: - View Lifecycle
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        
        self.challengeAxisLabel.center = CGPoint(x: self.flowView.frame.origin.x/2 + 5, y: self.flowView.frame.origin.y + self.challengeAxisLabel.bounds.size.width/2)
        
        self.flowView.delegate = self
        self.setNewSelectionLocation(x: 0.5, y: 0.5)
        
        self.saveLogButton.enabled = false
        
        self.bannerView.rootViewController = self
        if showAds()
        {
            setupBannerView(self.bannerView, forAd: .LogFlowBottomBanner)
        }
        else
        {
            self.bannerViewHeightConstraint.constant = 0
        }
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        self.handleAdBannerShowup(heightConstraint: self.bannerViewHeightConstraint)
    }
}

extension AreYouInFlowVC: FlowViewDelegate      // MARK: - FlowViewDelegate
{
    func setNewSelectionLocation(x x: CGFloat, y: CGFloat)
    {
        self.view.backgroundColor = UIColor(red: x, green: y, blue: 0.5, alpha: 1)
    }
    
    func updateFlowState(flowState: FlowState)
    {
        self.saveLogButton.enabled = true
        self.saveLogButton.setTitle("Save '" + String(flowState) + "'", forState: .Normal)
    }
}

extension AreYouInFlowVC        // MARK: - IBActions
{
    @IBAction func saveLog()
    {
        let delay = dispatch_time(DISPATCH_TIME_NOW, Int64(0.6 * Double(NSEC_PER_SEC))) // for better user experience
        
        self.saveLogButton.setTitle("SAVING...", forState: .Normal)
        self.saveLogButton.enabled = false
        
        dispatch_after(delay, dispatch_get_main_queue(), {
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
                        let completion = AUTOMATIC_VC_NOTIFICATION_COMPLETION(vc: self, success: {
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
                        }, failure: {
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
                        })
                        
                        NotificationHelper.scheduleNextNotification(completion: completion)        // after completing the log, schedule the next notification if needed
                    }
                    else
                    {
                        print("INFO: no next log scheduled!")
                        
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
                else
                {
                    self.saveLogButton.setTitle("ERROR. TRY AGAIN", forState: .Normal)
                    self.saveLogButton.enabled = true
                }
            }
        })
    }
}

extension AreYouInFlowVC
{
    override func startLog()
    {
        print("already doing log, incoming request")
    }
}
