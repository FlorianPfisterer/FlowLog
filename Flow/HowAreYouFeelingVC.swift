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
    var verticalSlider: UISlider!
    @IBOutlet weak var horizontalSlider: UISlider!
    @IBOutlet weak var nextButton: UIButton!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        
        self.horizontalSlider.alpha = 0
        self.nextButton.alpha = 0
        
        self.configureVerticalSlider()
    }
    
    func configureVerticalSlider()
    {
        self.verticalSlider = UISlider()
        self.verticalSlider.center = CGPoint(x: 30, y: 200)
        self.view.addSubview(self.verticalSlider)
        
        self.verticalSlider.minimumValue = 0
        self.verticalSlider.maximumValue = 1
        self.verticalSlider.value = 0.5
        
        let rotation = CGAffineTransformMakeRotation(CGFloat(M_PI * -0.5))
        self.verticalSlider.transform = rotation
        self.verticalSlider.frame.size = CGSize(width: 30, height: self.view.bounds.size.height - 200)
        
        // add actions
        self.verticalSlider.addTarget(self, action: "verticalSliderValueChanged:", forControlEvents: .ValueChanged)
        self.verticalSlider.addTarget(self, action: "verticalSliderEditingDidEnd", forControlEvents: .TouchUpInside)
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
    }
    
    // MARK: - Vertical Slider Actions
    func verticalSliderEditingDidEnd()
    {
        let startY = self.verticalSlider.frame.origin.y
        let ΔY = self.verticalSlider.bounds.size.width
        
        self.horizontalSlider.frame.origin = CGPoint(x: 70, y: startY + (1-CGFloat(self.verticalSlider.value))*ΔY-5)
        self.horizontalSlider.frame.size = CGSize(width: self.view.bounds.size.width - 120, height: 30)
        self.horizontalSlider.value = 0.5
        
        UIView.animateWithDuration(0.3, animations: {
            self.horizontalSlider.alpha = 1
            self.nextButton.alpha = 1
        })
    }
    
    func verticalSliderValueChanged(sender: UISlider)
    {
         // TODO! set color
    }
    
    // MARK: - Horizontal Slider Actions
    @IBAction func horizontalSliderValueChanged(sender: UISlider)
    {
        // TODO! set color
    }
    
    @IBAction func goToNextQuestion()
    {
        LogHelper.happinessLevel = self.horizontalSlider.value
        LogHelper.energyLevel = self.horizontalSlider.value
        self.performSegueWithIdentifier("toQuestion3Segue", sender: nil)
    }
    
    override func startLogWithLogNr(nr: Int)
    {
        print("already doing log, incoming request for nr \(nr)")
    }
}
