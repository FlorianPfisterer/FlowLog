//
//  FlowView.swift
//  Flow
//
//  Created by Florian Pfisterer on 03/01/16.
//  Copyright © 2016 Florian Pfisterer. All rights reserved.
//

import UIKit

protocol FlowViewDelegate
{
    func setNewSelectionLocation(x x: CGFloat, y: CGFloat, alpha: CGFloat)
    func updateFlowState(flowState: FlowState)
}

class FlowView: UIView
{
    var axisThickness: CGFloat = 3
    var axisColor: UIColor = UIColor.whiteColor()
    var selectionImageViewSize: CGFloat = 60
    
    var yAxisView: UIView!
    var xAxisView: UIView!
    var centerImageView: UIImageView!
    
    var labels: [UILabel]!
    
    var delegate: FlowViewDelegate!
}

extension FlowView      // MARK: - Lifecycle
{
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        self.backgroundColor = UIColor.clearColor()
    }
    
    override func drawRect(rect: CGRect)
    {
        self.yAxisView?.removeFromSuperview()
        self.xAxisView?.removeFromSuperview()
        
        self.yAxisView = UIView(frame: CGRect(x: 0, y: 0, width: self.axisThickness, height: self.bounds.size.height))
        self.xAxisView = UIView(frame: CGRect(x: 0, y: self.bounds.size.height - self.axisThickness, width: self.bounds.size.width, height: self.axisThickness))
        
        self.yAxisView.backgroundColor = self.axisColor
        self.xAxisView.backgroundColor = self.axisColor
        
        self.addSubview(self.yAxisView)
        self.addSubview(self.xAxisView)
        
        _ = self.labels?.map({ $0.removeFromSuperview() })
        
        let labelWidth: CGFloat = 76
        let labelHeight: CGFloat = 20
        let labelMargin: CGFloat = 5
        let xy: [(CGFloat, CGFloat)] = [(labelMargin, 0),                                                           // Anxiety
            (self.bounds.width/2 - labelWidth/2, 0),                                                                // Arousal
            (self.bounds.width - labelWidth - labelMargin, 0),                                                      // Flow
            (self.bounds.width - labelWidth - labelMargin, self.bounds.height/2 - labelHeight/2),                   // Control
            (self.bounds.width - labelWidth - labelMargin, self.bounds.height - labelHeight - labelMargin),         // Relaxation
            (self.bounds.width/2 - labelWidth/2, self.bounds.height - labelHeight - labelMargin),                   // Boredom
            (labelMargin, self.bounds.height - labelHeight - labelMargin),                                          // Apathy
            (labelMargin, self.bounds.height/2 - labelHeight/2)]                                                    // Worry
        
        self.labels = [UILabel]()
        for i in 1...8
        {
            let (x, y) = xy[i-1]
            let label = UILabel(frame: CGRect(x: x, y: y, width: labelWidth, height: labelHeight))
            label.text = String(FlowState(rawValue: Int16(i))!)
            label.font = UIFont.systemFontOfSize(15)
            label.textColor = UIColor.whiteColor()
            
            
            switch i
            {
            case 3...5:
                label.textAlignment = .Right
                
            case 2, 6:
                label.textAlignment = .Center
            
            case 7, 8, 1:
                label.textAlignment = .Left
                
            default:
                break
            }
            
            self.labels.append(label)
            self.addSubview(label)
        }
        
        
        if self.centerImageView == nil
        {
            self.centerImageView = UIImageView(image: UIImage(named: "SelectionCenterIcon")!)
            self.centerImageView.frame = CGRect(x: self.bounds.size.width/2 - self.selectionImageViewSize/2, y: self.bounds.size.height/2 - self.selectionImageViewSize/2, width: self.selectionImageViewSize, height: self.selectionImageViewSize)
            self.centerImageView.userInteractionEnabled = true
            self.addSubview(self.centerImageView)
            
            let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "didPanSelectionCenter:")
            self.centerImageView.addGestureRecognizer(panGestureRecognizer)
        }
        
        let center = CGPoint(x: self.bounds.width/2, y: self.bounds.height/2)
        let radius: CGFloat = 2*Vector2D(dx: center.x, dy: center.y).abs()
        let separatorWidth: CGFloat = 1
        let separatorSize: CGFloat = radius
        let circleRect = CGRect(x: -separatorWidth/2, y: 0, width: separatorWidth, height: separatorSize)
        
        let context = UIGraphicsGetCurrentContext()
        
        // segment separators
        CGContextSaveGState(context)
        self.axisColor.setFill()
        
        let anglePerSegment: CGFloat = 1/4 * π
        let startAngle: CGFloat = anglePerSegment/2
        
        let separatorPath = UIBezierPath(rect: circleRect)
        
        CGContextTranslateCTM(context, rect.width/2, rect.height/2)
        
        for i in 1...9
        {
            CGContextSaveGState(context)
            
            let angle = anglePerSegment * CGFloat(i) + startAngle
            
            CGContextRotateCTM(context, angle)
            
            CGContextTranslateCTM(context, 0, rect.height/2 - separatorSize)
            
            //6 - fill the marker rectangle
            separatorPath.fill()
            
            //7 - restore the centred context for the next rotate
            CGContextRestoreGState(context)
        }
        
        CGContextRestoreGState(context)
    }
}

extension FlowView      // MARK: - Helper Functions
{
    func didPanSelectionCenter(gestureRecognizer: UIPanGestureRecognizer)
    {
        let translation = gestureRecognizer.translationInView(self)
        var recognizerFrame = gestureRecognizer.view!.frame
        
        recognizerFrame.origin.x += translation.x
        recognizerFrame.origin.y += translation.y
        
        if CGRectContainsRect(self.bounds, recognizerFrame)
        {
            gestureRecognizer.view!.frame = recognizerFrame
        }
        
        self.updateSelectionLocation()
        
        gestureRecognizer.setTranslation(CGPoint(x: 0, y: 0), inView: self)
    }
    
    func updateSelectionLocation()
    {
        let (relativeX, relativeY) = self.getFlowDimensions()
        self.delegate.setNewSelectionLocation(x: CGFloat(relativeX), y: CGFloat(relativeY), alpha: 0.9)
        
        self.updateVectorAngle()
    }
    
    func updateVectorAngle()
    {
        self.delegate.updateFlowState(self.getFlowState())
    }
    
    private func getCurrentAngle() -> CGFloat
    {
        let middlePoint = CGPoint(x: self.bounds.size.width/2, y: self.bounds.size.height/2)
        
        let newVector = Vector2D(dx: self.centerImageView.center.x - middlePoint.x, dy: self.centerImageView.center.y - middlePoint.y)  // vector from own middle point to the center of the selection image view
        
        var α = newVector.getAngleToVector(Vector2D.upYVector)  // angle in which the selection image view is positioned relative to the own middle point, 0 degrees is at the top (x == middlePoint.x)
        
        if middlePoint.x > self.centerImageView.center.x    // center is in the left half => change α
        {
            α = 360 - α
        }
        
        return α
    }
}

extension FlowView      // MARK: - Get Data
{
    func getFlowDimensions() -> (Float, Float)
    {
        let dimenX = Float(self.centerImageView.center.x / self.bounds.size.width)
        let dimenY = Float(self.centerImageView.center.y / self.bounds.size.height)
        
        return (dimenX, dimenY)
    }
    
    func getFlowState() -> FlowState
    {
        return LogHelper.getFlowStateFromAngle(self.getCurrentAngle())
    }
}
