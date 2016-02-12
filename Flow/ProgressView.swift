//
//  ProgressView.swift
//  FlowLog
//
//  Created by Florian Pfisterer on 25/01/16.
//  Copyright © 2016 Florian Pfisterer. All rights reserved.
//

import UIKit

@IBDesignable class ProgressView: UIView
{
    var outerArcShapeLayer = CAShapeLayer()
    var innerArcShapeLayer = CAShapeLayer()
    
    var daysRemainingLabel = UILabel()
    var logsRemainingLabel = UILabel()
    var remainingLabel = UILabel()
    
    @IBInspectable var numberOfLogsRemaining: Int = 40 {
        didSet
        {
            self.animateArcs()
            self.logsRemainingLabel.text = self.getLogsLabelText()
        }
    }
    
    @IBInspectable var numberOfDaysRemaining: Int = 7 {
        didSet
        {
            self.animateArcs()
            self.daysRemainingLabel.text = self.getDaysLabelText()
        }
    }
    
    @IBInspectable var outerStrokeColor: UIColor = BAR_TINT_COLOR
    @IBInspectable var innerStrokeColor: UIColor = UIColor.whiteColor()
    @IBInspectable var outerLineWidth: CGFloat = 13
    @IBInspectable var innerLineWidth: CGFloat = 10
    
    @IBInspectable var arcsMargin: CGFloat = 3
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        
        self.setupLabels()
        
        self.outerArcShapeLayer.removeFromSuperlayer()
        self.innerArcShapeLayer.removeFromSuperlayer()
        
        let center = CGPoint(x: self.bounds.size.width/2, y: self.bounds.size.height/2)
        let startAngle: CGFloat = (3/2) * π
        let endAngle: CGFloat = startAngle - 0.000001
        
        // 1. create outer arc
        let outerRadius: CGFloat = self.bounds.size.height/2 - self.outerLineWidth/2
        let outerArcPath = UIBezierPath(arcCenter: center, radius: outerRadius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        
        // configure the outer shape layer
        self.outerArcShapeLayer.path = outerArcPath.CGPath
        self.configureShapeLayer(self.outerArcShapeLayer)
        self.outerArcShapeLayer.strokeColor = self.outerStrokeColor.CGColor
        self.outerArcShapeLayer.lineWidth = self.outerLineWidth
        self.outerArcShapeLayer.strokeEnd = self.getStrokeEndForOuterArc()
        
        self.layer.addSublayer(self.outerArcShapeLayer)
        
        // 2. create inner arc
        let innerRadius = self.bounds.size.height/2 - self.outerLineWidth - self.arcsMargin - self.innerLineWidth/2
        let innerArcPath = UIBezierPath(arcCenter: center, radius: innerRadius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        
        self.innerArcShapeLayer.path = innerArcPath.CGPath
        self.configureShapeLayer(self.innerArcShapeLayer)
        self.innerArcShapeLayer.strokeColor = self.innerStrokeColor.CGColor
        self.innerArcShapeLayer.lineWidth = self.innerLineWidth
        self.innerArcShapeLayer.strokeEnd = self.getStrokeEndForInnerArc()
        
        self.layer.addSublayer(self.innerArcShapeLayer)
    }
    
    // MARK: - Calculation and Configuration
    func getStrokeEndForOuterArc() -> CGFloat
    {
        return 1 - CGFloat(self.numberOfLogsRemaining) / CGFloat(FLOW_LOGS_PER_WEEK_COUNT)
    }
    
    func getStrokeEndForInnerArc() -> CGFloat
    {
        return 1 - CGFloat(self.numberOfDaysRemaining) / CGFloat(7)
    }
    
    func configureShapeLayer(shapeLayer: CAShapeLayer)
    {
        shapeLayer.fillColor = UIColor.clearColor().CGColor
        shapeLayer.backgroundColor = UIColor.clearColor().CGColor
        shapeLayer.lineCap = kCALineCapRound
        shapeLayer.strokeStart = 0
    }
    
    func configureLabel(label: UILabel, withFontSize fontSize: CGFloat, textColor: UIColor)
    {
        label.font = UIFont.systemFontOfSize(fontSize)
        label.textColor = textColor
        label.textAlignment = .Center
    }
    
    func getLogsLabelText() -> String
    {
        return "\(self.numberOfLogsRemaining) log" + StringHelper.sEventually(self.numberOfLogsRemaining)
    }
    
    func getDaysLabelText() -> String
    {
        return "\(self.numberOfDaysRemaining) day" + StringHelper.sEventually(self.numberOfDaysRemaining)
    }
    
    // MARK: - Drawing Helpers
    func setupLabels()
    {
        let labelWidth: CGFloat = 125
        let labelHeight: CGFloat = 32
        let labelMargin: CGFloat = 75
        
        let labelX: CGFloat = self.bounds.size.width/2 - labelWidth/2
        
        self.logsRemainingLabel.removeFromSuperview()
        self.daysRemainingLabel.removeFromSuperview()
        self.remainingLabel.removeFromSuperview()
        
        // 1. logs remaining label
        self.logsRemainingLabel.text = self.getLogsLabelText()
        self.logsRemainingLabel.frame = CGRect(x: labelX, y: labelMargin, width: labelWidth, height: labelHeight + 10)
        self.configureLabel(self.logsRemainingLabel, withFontSize: 36, textColor: self.outerStrokeColor)
        self.addSubview(self.logsRemainingLabel)
        
        // 2. days remaining label
        self.daysRemainingLabel.text = self.getDaysLabelText()
        self.daysRemainingLabel.frame = CGRect(x: labelX, y: labelMargin + labelHeight + 10, width: labelWidth, height: labelHeight)
        self.configureLabel(self.daysRemainingLabel, withFontSize: 30, textColor: self.innerStrokeColor)
        self.addSubview(self.daysRemainingLabel)
        
        // 3. remaining label
        self.remainingLabel.text = "remaining"
        self.remainingLabel.frame = CGRect(x: labelX, y: self.bounds.size.height - labelMargin, width: labelWidth, height: labelHeight)
        self.configureLabel(self.remainingLabel, withFontSize: 19, textColor: UIColor.whiteColor())
        self.addSubview(self.remainingLabel)
        
    }
    
    let ARC_ANIMATION_KEY = "arcAnimationStrokeEnd"
    func animateArcs()
    {
        // 1. animate outer arc
        var fromValueOuter = self.outerArcShapeLayer.strokeEnd
        let toValueOuter = self.getStrokeEndForOuterArc()
        
        // if there is already an animation running, pick the current strokeEnd
        if let presentationLayer = self.outerArcShapeLayer.presentationLayer() as? CAShapeLayer
        {
            fromValueOuter = presentationLayer.strokeEnd
        }
        
        let arcAnimation = CABasicAnimation(keyPath: "strokeEnd")
        arcAnimation.fromValue = fromValueOuter
        arcAnimation.toValue = toValueOuter
        arcAnimation.duration = CFTimeInterval(abs(fromValueOuter - toValueOuter) * 3)
        arcAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        
        self.outerArcShapeLayer.removeAnimationForKey(self.ARC_ANIMATION_KEY)
        self.outerArcShapeLayer.addAnimation(arcAnimation, forKey: self.ARC_ANIMATION_KEY)
        
        // 2. animate inner arc
        var fromValueInner = self.innerArcShapeLayer.strokeEnd
        let toValueInner = self.getStrokeEndForInnerArc()
        
        if let presentationLayer = self.innerArcShapeLayer.presentationLayer()
        {
            fromValueInner = presentationLayer.strokeEnd
        }
        
        arcAnimation.fromValue = fromValueInner
        arcAnimation.toValue = toValueInner
        arcAnimation.duration = CFTimeInterval(abs(fromValueInner - toValueInner) * 3)
        
        self.innerArcShapeLayer.removeAnimationForKey(self.ARC_ANIMATION_KEY)
        self.innerArcShapeLayer.addAnimation(arcAnimation, forKey: self.ARC_ANIMATION_KEY)
        
        // save changes of both animations
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        self.outerArcShapeLayer.strokeEnd = toValueOuter
        self.innerArcShapeLayer.strokeEnd = toValueInner
        CATransaction.commit()
    }
}
