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
}

extension HowAreYouFeelingVC     // MARK: - View Lifecycle
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .Done, target: self, action: "goToNextQuestion")
    }
}

extension HowAreYouFeelingVC    // MARK: - Overall Log Management
{
    func goToNextQuestion()
    {
        LogHelper.happinessLevel = Float(self.stateWheelControl.percentage) / 100
        LogHelper.energyLevel = 0.5 // TODO!
        self.performSegueWithIdentifier("toQuestion3Segue", sender: nil)
    }
    
    override func startLog()
    {
        print("already doing log, incoming request")
    }
}
