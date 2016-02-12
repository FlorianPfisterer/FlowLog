//
//  AngleGestureRecognizer.swift
//  FlowLog
//
//  Created by Florian Pfisterer on 02/02/16.
//  Copyright © 2016 Florian Pfisterer. All rights reserved.
//

import UIKit
import UIKit.UIGestureRecognizerSubclass

class AngleGestureRecognizer: UIPanGestureRecognizer
{
    private var gestureStartAngle: CGFloat?
    
    var currentTouchAngle: CGFloat = 0
    
    var angleDelta: CGFloat {
        guard let gestureStartAngle = self.gestureStartAngle else
        {
            return 0
        }
        return self.currentTouchAngle - gestureStartAngle
    }
    
    var currentDistanceToCenter: CGFloat = 0
    
    override init(target: AnyObject?, action: Selector)
    {
        super.init(target: target, action: action)
        
        self.minimumNumberOfTouches = 1
        self.maximumNumberOfTouches = 1
    }
}

extension AngleGestureRecognizer
{
    private func calculateAngleToPoint(point: CGPoint) -> CGFloat
    {
        guard let bounds = self.view?.bounds else
        {
            return 0
        }
        
        let centerOffset = CGVector(dx: point.x - bounds.midX, dy: point.y - bounds.midY)
        self.currentDistanceToCenter = centerOffset.length
        
        return atan2(centerOffset.dy, centerOffset.dx)
    }
    
    private func updateTouchAngleWithTouches(touches: Set<UITouch>)
    {
        if let touchPoint = touches.first?.locationInView(self.view)
        {
            self.currentTouchAngle = self.calculateAngleToPoint(touchPoint)
        }
    }
}

extension AngleGestureRecognizer
{
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent)
    {
        super.touchesBegan(touches, withEvent: event)
        
        self.updateTouchAngleWithTouches(touches)
        self.gestureStartAngle = self.currentTouchAngle
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent)
    {
        super.touchesMoved(touches, withEvent: event)
        
        self.updateTouchAngleWithTouches(touches)
    }
    
    override func touchesCancelled(touches: Set<UITouch>, withEvent event: UIEvent)
    {
        super.touchesCancelled(touches, withEvent: event)
        
        self.currentTouchAngle = 0
        self.gestureStartAngle = .None
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent)
    {
        super.touchesEnded(touches, withEvent: event)
        
        self.currentTouchAngle = 0
        self.gestureStartAngle = .None
    }
}
