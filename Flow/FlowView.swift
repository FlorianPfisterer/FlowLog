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
}

class FlowView: UIView
{
    var axisThickness: CGFloat = 3
    var axisColor: UIColor = UIColor.whiteColor()
    var selectionImageViewSize: CGFloat = 60
    
    var yAxisView: UIView!
    var xAxisView: UIView!
    var centerImageView: UIImageView!
    
    var delegate: FlowViewDelegate!
    
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
        
        if self.centerImageView == nil
        {
            self.centerImageView = UIImageView(image: UIImage(named: "SelectionCenterIcon")!)
            self.centerImageView.frame = CGRect(x: self.bounds.size.width/2 - self.selectionImageViewSize/2, y: self.bounds.size.height/2 - self.selectionImageViewSize/2, width: self.selectionImageViewSize, height: self.selectionImageViewSize)
            self.centerImageView.userInteractionEnabled = true
            self.addSubview(self.centerImageView)
            
            let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "didPanSelectionCenter:")
            self.centerImageView.addGestureRecognizer(panGestureRecognizer)
        }
    }
    
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
    }
    
    // MARK: - Get Data
    func getFlowDimensions() -> (Float, Float)
    {
        let dimenX = Float(self.centerImageView.center.x / self.bounds.size.width)
        let dimenY = Float((self.bounds.size.height - self.centerImageView.center.y) / self.bounds.size.height)
        
        return (dimenX, dimenY)
    }
}
