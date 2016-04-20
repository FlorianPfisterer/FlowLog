//
//  HorizontalStateControl.swift
//  FlowLog
//
//  Created by Florian Pfisterer on 03/02/16.
//  Copyright © 2016 Florian Pfisterer. All rights reserved.
//

import UIKit

@IBDesignable
class HorizontalStateControl: UIControl
{
    private var colorBarView: HorizontalColorBarView!
    private var selectedSegmentView: UIView!
    
    private var percentageLabel: UILabel!
    private var indicatorLabel: UILabel!
    
    private var sliderRecognizer: UIPanGestureRecognizer!
    private var userTookSliderView = false
    
    var percentage: Int = 50
    
    var showLabels: Bool = true {
        didSet
        {
            self.percentageLabel.alpha = self.showLabels ? 1 : 0
            self.indicatorLabel.alpha = self.showLabels ? 1 : 0
        }
    }
    
    @IBInspectable
    var percentageLabelHeight: CGFloat = 25 {
        didSet
        {
            self.setNeedsDisplay()
        }
    }
    
    @IBInspectable
    var percentageLabelMargin: CGFloat = 0 {
        didSet
        {
            self.setNeedsDisplay()
        }
    }
    
    @IBInspectable
    var indicatorLabelHeight: CGFloat = 22 {
        didSet
        {
            self.setNeedsDisplay()
        }
    }
    
    @IBInspectable
    var indicatorLabelMargin: CGFloat = 8 {
        didSet
        {
            self.setNeedsDisplay()
        }
    }
    
    @IBInspectable
    var selectedSegmentViewWidth: CGFloat = 30 {
        didSet
        {
            self.setNeedsDisplay()
        }
    }
    
    @IBInspectable
    var startColor: UIColor = UIColor.blueColor() {
        didSet
        {
            self.setGradientColors()
        }
    }

    @IBInspectable
    var endColor: UIColor = UIColor.darkGrayColor() {
        didSet
        {
            self.setGradientColors()
        }
    }
    
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

extension HorizontalStateControl
{
    private func sharedInitialization()
    {
        // create background gradient
        self.colorBarView = HorizontalColorBarView()
        self.colorBarView.backgroundColor = UIColor.clearColor()
        self.colorBarView.clipsToBounds = true
        self.setGradientColors()
        self.addSubview(self.colorBarView)
        
        // create percentage label
        self.percentageLabel = UILabel()
        self.configureLabel(self.percentageLabel, fontSize: 32)
        self.updatePercentageLabel()
        self.addSubview(self.percentageLabel)
        
        // create indicator label
        self.indicatorLabel = UILabel()
        self.configureLabel(self.indicatorLabel, fontSize: 20)
        self.indicatorLabel.text = "energy"
        self.addSubview(self.indicatorLabel)
        
        // create segment slider
        self.selectedSegmentView = UIView()
        self.selectedSegmentView.backgroundColor = UIColor.clearColor()
        self.selectedSegmentView.layer.borderColor = UIColor(white: 0, alpha: 0.3).CGColor
        self.selectedSegmentView.layer.borderWidth = 3
        self.selectedSegmentView.layer.cornerRadius = 5
        self.addSubview(self.selectedSegmentView)
        
        // create slider recognizer
        self.sliderRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.didPanSegmentSlider))
        self.addGestureRecognizer(self.sliderRecognizer)
    }
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        
        let topSpace = self.percentageLabelHeight + self.percentageLabelMargin + self.indicatorLabelHeight + self.indicatorLabelMargin
        
        self.colorBarView.frame = CGRect(x: 0, y: topSpace, width: self.bounds.size.width, height: self.bounds.size.height - topSpace)
        
        self.percentageLabel.frame = CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.percentageLabelHeight)
        
        self.indicatorLabel.frame = CGRect(x: 0, y: self.percentageLabelHeight + self.percentageLabelMargin, width: self.bounds.width, height: self.indicatorLabelHeight)
        
        self.selectedSegmentView.frame = CGRect(x: (self.bounds.size.width - self.selectedSegmentViewWidth)/2, y: topSpace, width: self.selectedSegmentViewWidth, height: self.bounds.size.height - topSpace)
    }
}

extension HorizontalStateControl
{
    private func configureLabel(label: UILabel, fontSize: CGFloat)
    {
        label.textAlignment = .Center
        label.textColor = UIColor.whiteColor()
        label.font = UIFont.systemFontOfSize(fontSize)
    }
    
    func didPanSegmentSlider(recognizer: UIPanGestureRecognizer)
    {
        let location = recognizer.locationInView(self)
        
        switch recognizer.state
        {
        case .Began:
            if CGRectContainsPoint(CGRect(x: self.selectedSegmentView.frame.origin.x - 10, y: 0, width: self.selectedSegmentViewWidth + 20, height: self.bounds.size.height), location)
            {
                self.userTookSliderView = true
                let translation = recognizer.translationInView(self)
                self.moveSelectionSegment(translationX: translation.x)
            }
            
        case .Changed:
            if self.userTookSliderView
            {
                let translation = recognizer.translationInView(self)
                self.moveSelectionSegment(translationX: translation.x)
            }
            
        case .Ended, .Cancelled, .Failed:
            self.userTookSliderView = false
            
        case .Possible:
            break
        }
        
        recognizer.setTranslation(CGPointZero, inView: self)
    }
    
    private func moveSelectionSegment(translationX translationX: CGFloat)
    {
        let newX = self.selectedSegmentView.center.x + translationX
        if translationX < 0
        {
            self.selectedSegmentView.center.x = max(self.selectedSegmentViewWidth/2, newX)
        }
        else
        {
            self.selectedSegmentView.center.x = min(self.bounds.size.width - self.selectedSegmentViewWidth/2, newX)
        }
        
        self.percentage = Int((self.selectedSegmentView.center.x - self.selectedSegmentViewWidth/2) / (self.bounds.size.width - self.selectedSegmentViewWidth) * 100)
        self.updatePercentageLabel()
    }
    
    private func updatePercentageLabel()
    {
        self.percentageLabel.text = "\(self.percentage)%"
    }
}

extension HorizontalStateControl
{
    private func setGradientColors()
    {
        self.colorBarView.colors = (self.startColor.CGColor, self.endColor.CGColor)
    }
}


























