//
//  HowAreYouFeelingVC.swift
//  Flow
//
//  Created by Florian Pfisterer on 03/01/16.
//  Copyright © 2016 Florian Pfisterer. All rights reserved.
//

import UIKit

class HowAreYouFeelingVC: UIViewController
{
    @IBOutlet weak var instructionLabel: UILabel!
    @IBOutlet weak var stateWheelControl: StateWheelControl!
    @IBOutlet weak var horizontalStateControl: HorizontalStateControl!
    @IBOutlet weak var energySliderHeightConstraint: NSLayoutConstraint!
}

extension HowAreYouFeelingVC     // MARK: - View Lifecycle
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .Done, target: self, action: "goToNextQuestion")
        
        if UIScreen.mainScreen().bounds.size.height < 568
        {
            // iPhone 4s
            self.horizontalStateControl.showLabels = false
            self.energySliderHeightConstraint.constant = 80
        }
        else
        {
            self.horizontalStateControl.showLabels = true
            self.energySliderHeightConstraint.constant = 97
        }
    }
}

extension HowAreYouFeelingVC    // MARK: - Overall Log Management
{
    func goToNextQuestion()
    {
        LogHelper.happinessLevel = Float(self.stateWheelControl.percentage) / 100
        LogHelper.energyLevel = Float(self.horizontalStateControl.percentage) / 100
        self.performSegueWithIdentifier("toQuestion3Segue", sender: nil)
    }
    
    override func startLog()
    {
        print("already doing log, incoming request")
    }
}
