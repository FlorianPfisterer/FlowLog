//
//  GradientBackgroundView.swift
//  Flow
//
//  Created by Florian Pfisterer on 05/01/16.
//  Copyright © 2016 Florian Pfisterer. All rights reserved.
//

import UIKit

@IBDesignable class GradientBackgroundView: UIView
{
    @IBInspectable var firstColor: UIColor = UIColor(red: 99/255.0, green: 99/255.0, blue: 99/255.0, alpha: 1)
    @IBInspectable var secondColor: UIColor = UIColor.blackColor()
    
    @IBInspectable var firstLocation: CGFloat = 0
    @IBInspectable var secondLocation: CGFloat = 1
    
    private var relativeStartPoint: CGPoint?
    private var relativeEndPoint: CGPoint?
    
    // MARK: - Init
    init(frame: CGRect, relativeStartPoint: CGPoint, relativeEndPoint: CGPoint)
    {
        super.init(frame: frame)
        
        self.relativeStartPoint = relativeStartPoint
        self.relativeEndPoint = relativeEndPoint
    }
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    override func drawRect(rect: CGRect)
    {
        if let context = UIGraphicsGetCurrentContext()
        {
            let colors = [self.firstColor.CGColor, self.secondColor.CGColor]
            let locations: [CGFloat] = [self.firstLocation, self.secondLocation]
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            
            let gradient = CGGradientCreateWithColors(colorSpace, colors, locations)
            
            var startPoint = CGPoint(x: 0, y: 0)
            var endPoint = CGPoint(x: self.bounds.size.width, y: self.bounds.size.height)
            
            if let relativeStartPoint = self.relativeStartPoint
            {
                startPoint = CGPoint.fromRelativePoint(relativeStartPoint, multiplier: self.bounds.size)
            }
            
            if let relativeEndPoint = self.relativeEndPoint
            {
                endPoint = CGPoint.fromRelativePoint(relativeEndPoint, multiplier: self.bounds.size)
            }
            
            CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, .DrawsBeforeStartLocation)
        }
        else
        {
            print("ERROR: couldn't get current UIGraphicsContext")
        }
        
        super.drawRect(rect)
    }
}

