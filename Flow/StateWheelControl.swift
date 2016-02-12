//
//  StateWheelControl.swift
//  FlowLog
//
//  Created by Florian Pfisterer on 02/02/16.
//  Copyright © 2016 Florian Pfisterer. All rights reserved.
//

import UIKit

@IBDesignable
class StateWheelControl: UIControl
{
    private var colorWheel: ColorWheelView!
    private var transformAtStartOfGesture: CGAffineTransform?
    
    private var angleRecognizer: AngleGestureRecognizer!
    
    @IBInspectable
    var wheelPadding: CGFloat = 10 {
        didSet
        {
            self.setNeedsDisplay()
        }
    }
    
    @IBOutlet weak var percentageLabel: UILabel! {
        didSet
        {
            self.updatePercentageLabel()
        }
    }
    
    var percentage: Int = 100
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        self.sharedInitialization()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        self.sharedInitialization()
    }
}

extension StateWheelControl
{
    private func sharedInitialization()
    {
        // create the outer ColorWheelView
        self.colorWheel = ColorWheelView()
        self.colorWheel.colorDelegate = self
        self.colorWheel.backgroundColor = UIColor.clearColor()
        self.addSubview(self.colorWheel)
        
        self.colorWheel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activateConstraints([
            self.colorWheel.leftAnchor.constraintEqualToAnchor(self.leftAnchor),
            self.colorWheel.rightAnchor.constraintEqualToAnchor(self.rightAnchor),
            self.colorWheel.topAnchor.constraintEqualToAnchor(self.topAnchor),
            self.colorWheel.bottomAnchor.constraintEqualToAnchor(self.bottomAnchor)])
        
        
        // create selection rectangle
        let selectedSegmentView = UIView()
        selectedSegmentView.translatesAutoresizingMaskIntoConstraints = false
        selectedSegmentView.backgroundColor = UIColor.clearColor()
        selectedSegmentView.layer.borderColor = UIColor(white: 0, alpha: 0.3).CGColor
        selectedSegmentView.layer.borderWidth = 3
        self.addSubview(selectedSegmentView)
        
        NSLayoutConstraint.activateConstraints([
            selectedSegmentView.centerXAnchor.constraintEqualToAnchor(self.centerXAnchor),
            selectedSegmentView.topAnchor.constraintEqualToAnchor(self.topAnchor),
            selectedSegmentView.widthAnchor.constraintEqualToAnchor(self.widthAnchor, multiplier: 0.05),
            selectedSegmentView.heightAnchor.constraintEqualToAnchor(self.heightAnchor, multiplier: 0.3)])
        
        // create rotating gesture recognizers
        self.angleRecognizer = AngleGestureRecognizer(target: self, action: "handleAngleGestureChange")
        self.addGestureRecognizer(self.angleRecognizer)
    }
}

extension StateWheelControl
{
    func handleAngleGestureChange()
    {
        let angleDelta = self.angleRecognizer.angleDelta
        switch self.angleRecognizer.state
        {
        case .Began:
            self.transformAtStartOfGesture = self.colorWheel.transform
            
        case .Changed:
            self.colorWheel.transform = CGAffineTransformRotate(self.transformAtStartOfGesture!, angleDelta)
            
            
        default:
            self.transformAtStartOfGesture = .None
        }
        
        self.updatePercentageLabel()
    }
}

extension StateWheelControl
{
    private func updatePercentageLabel()
    {
        if let angle = self.colorWheel.layer.valueForKeyPath("transform.rotation.z") as? CGFloat
        {
            if angle < 0    // left side, postive green
            {
                self.percentage = Int((π - abs(angle) + π) / (2*π) * 100)
            }
            else        // right side, negative red
            {
                self.percentage = Int(angle / (2*π) * 100)
            }
        }
        else
        {
            self.percentage = 100       // default
        }
        
        self.percentageLabel.text = "\(self.percentage)%"
    }
}

extension StateWheelControl: ColorWheelViewDelegate
{
    func getColorForColorWheel(atProportion proportion: CGFloat) -> UIColor
    {
        return UIColor(red: proportion * (1.2+proportion), green: (1-proportion) * (1+proportion), blue: 0, alpha: 1)
    }
}