//
//  TimeIntervalPicker.swift
//  FlowLog
//
//  Created by Florian Pfisterer on 29.02.16.
//  Copyright © 2016 Florian Pfisterer. All rights reserved.
//

import UIKit

@IBDesignable
class TimeIntervalPicker: UIControl
{
    private var backgroundArcView: BackgroundArcView!
    private var sliderRecognizer: UIPanGestureRecognizer!
    
    private var leftSectionView: TimeIntervalSelectionView!
    private var rightSectionView: TimeIntervalSelectionView!
    
    private var sliderViewState: SliderViewSelectionState = .None
    
    // MARK: - Public API
    var leftSectionFraction: CGFloat = 0.3 {
        didSet
        {
            self.updateLeftSectionView()
        }
    }
    
    var rightSectionFraction: CGFloat = 0.7 {
        didSet
        {
            self.updateRightSectionView()
        }
    }
    
    @IBInspectable
    var sectionViewWidth: CGFloat = 60
    
    @IBInspectable
    var sliderViewWidth: CGFloat = 18
    
    @IBInspectable
    var arcBackgroundHeight: CGFloat = 130
    
    @IBInspectable
    var arcViewTopMargin: CGFloat = 15
    
    // MARK: - Init
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

extension TimeIntervalPicker
{
    private func sharedInitialization()
    {
        self.backgroundArcView = BackgroundArcView()
        self.addSubview(self.backgroundArcView)
        
        self.sliderRecognizer = UIPanGestureRecognizer(target: self, action: "didPanSegmentSlider:")
        self.addGestureRecognizer(self.sliderRecognizer)
        
        self.leftSectionView = TimeIntervalSelectionView()
        self.configureForegroundSectionView(self.leftSectionView)
        self.addSubview(self.leftSectionView)
        
        self.rightSectionView = TimeIntervalSelectionView()
        self.configureForegroundSectionView(self.rightSectionView)
        self.addSubview(self.rightSectionView)
    }
    
    private func configureForegroundSectionView(view: TimeIntervalSelectionView)
    {
        view.backgroundColor = UIColor.clearColor()
        view.sliderViewWidth = self.sliderViewWidth
    }
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        
        let arcViewHorizontalMargin: CGFloat = (self.sectionViewWidth - self.sliderViewWidth)/2
        self.backgroundArcView.frame = CGRect(x: arcViewHorizontalMargin, y: self.arcViewTopMargin, width: self.width - 2*arcViewHorizontalMargin, height: self.arcBackgroundHeight - self.arcViewTopMargin)
        
        self.recalculateForegroundSections()
    }
}

extension TimeIntervalPicker
{
    private var leftSectionRect: CGRect {
        let x = (self.width - self.sectionViewWidth) * self.leftSectionFraction       // max * current
        return CGRect(x: x, y: 0, width: self.sectionViewWidth, height: self.height)
    }
    
    private var rightSectionRect: CGRect {
        let x = (self.width - self.sectionViewWidth) * self.rightSectionFraction        // max * current
        return CGRect(x: x, y: 0, width: self.sectionViewWidth, height: self.height)
    }
    
    private func recalculateForegroundSections()
    {
        self.updateLeftSectionView()
        self.updateRightSectionView()
        
        self.leftSectionView.frame = self.leftSectionRect
        self.rightSectionView.frame = self.rightSectionRect
    }
    
    private func updateLeftSectionView()
    {
        let newStartTime = Time.fromFraction(self.leftSectionFraction, accuracy: .HalfHours)
        self.leftSectionView.time = newStartTime
    }
    
    private func updateRightSectionView()
    {
        let newEndTime = Time.fromFraction(self.rightSectionFraction, accuracy: .HalfHours)
        self.rightSectionView.time = newEndTime
    }
}

extension TimeIntervalPicker
{
    private var expandedLeftSectionFrame: CGRect {
        return CGRect(x: self.leftSectionView.frame.origin.x, y: 0, width: self.sectionViewWidth, height: self.bounds.size.height)
    }
    
    private var expandedRightSectionFrame: CGRect {
        return CGRect(x: self.rightSectionView.frame.origin.x, y: 0, width: self.sectionViewWidth, height: self.bounds.size.height)
    }
    
    func didPanSegmentSlider(recognizer: UIPanGestureRecognizer)
    {
        let location = recognizer.locationInView(self)
        switch recognizer.state
        {
        case .Began:
            if CGRectContainsPoint(self.expandedLeftSectionFrame, location)
            {
                self.sliderViewState = .TookLeft
                let translation = recognizer.translationInView(self)
                self.moveSelectionSegment(translationX: translation.x)
            }
            else if CGRectContainsPoint(self.expandedRightSectionFrame, location)
            {
                self.sliderViewState = .TookRight
                let translation = recognizer.translationInView(self)
                self.moveSelectionSegment(translationX: translation.x)
            }
            
        case .Changed:
            if self.sliderViewState != .None
            {
                let translation = recognizer.translationInView(self)
                self.moveSelectionSegment(translationX: translation.x)
            }
            
        case .Ended, .Cancelled, .Failed:
            self.sliderViewState = .None
            
        case .Possible:
            break
        }
        
        recognizer.setTranslation(CGPointZero, inView: self)
    }
    
    private func moveSelectionSegment(translationX translationX: CGFloat)
    {
        switch self.sliderViewState
        {
        case .None:
            return
            
        case .TookLeft:
            let newX = self.leftSectionView.center.x + translationX
            if translationX < 0     // move left
            {
                self.leftSectionView.center.x = max(self.sectionViewWidth/2, newX)
            }
            else            // move right
            {
                self.leftSectionView.center.x = min(self.rightSectionView.frame.origin.x - self.sectionViewWidth/2, newX)
            }

            self.leftSectionFraction = (self.leftSectionView.center.x - self.sectionViewWidth/2) / (self.width - self.sectionViewWidth)
            
        case .TookRight:
            let newX = self.rightSectionView.center.x + translationX
            if translationX < 0     // move left
            {
                self.rightSectionView.center.x = max(self.leftSectionView.frame.origin.x + self.sectionViewWidth*(3/2), newX)
            }
            else            // move right
            {
                self.rightSectionView.center.x = min(self.bounds.size.width - self.sectionViewWidth/2, newX)
            }
            
            self.rightSectionFraction = (self.rightSectionView.center.x - self.sectionViewWidth/2) / (self.width - self.sectionViewWidth)
        }
    }
}

extension TimeIntervalPicker
{
    func getStartTime() -> Time
    {
        return self.leftSectionView.time
    }
    
    func getEndTime() -> Time
    {
        return self.rightSectionView.time
    }
}

