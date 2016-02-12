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
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .Done, target: self, action: "goToNextQuestion")
    }
}

extension HowAreYouFeelingVC    // Overall Log Management
{
    func goToNextQuestion()
    {
        LogHelper.happinessLevel = Float(self.stateWheelControl.percentage) / 100
        self.performSegueWithIdentifier("toQuestion3Segue", sender: nil)
    }
    
    override func startLogWithLogNr(nr: Int)
    {
        print("already doing log, incoming request for nr \(nr)")
    }
}
