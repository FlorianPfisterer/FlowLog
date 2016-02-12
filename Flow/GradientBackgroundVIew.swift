//
//  GradientBackgroundVIew.swift
//  Flow
//
//  Created by Florian Pfisterer on 05/01/16.
//  Copyright © 2016 Florian Pfisterer. All rights reserved.
//

import UIKit

@IBDesignable class GradientBackgroundVIew: UIView
{
    @IBInspectable var firstColor: UIColor = UIColor(red: 99/255.0, green: 99/255.0, blue: 99/255.0, alpha: 1)
    @IBInspectable var secondColor: UIColor = UIColor.blackColor()
    
    @IBInspectable var firstLocation: CGFloat = 0
    @IBInspectable var secondLocation: CGFloat = 1
}

extension GradientBackgroundVIew    // MARK: - Lifecycle
{
    override func drawRect(rect: CGRect)
    {
        if let context = UIGraphicsGetCurrentContext()
        {
            let colors = [self.firstColor.CGColor, self.secondColor.CGColor]
            let locations: [CGFloat] = [self.firstLocation, self.secondLocation]
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            
            let gradient = CGGradientCreateWithColors(colorSpace, colors, locations)
            
            CGContextDrawLinearGradient(context, gradient, CGPoint(x: 0, y: 0), CGPoint(x: self.bounds.size.width, y: self.bounds.size.height), .DrawsBeforeStartLocation)
        }
        else
        {
            print("ERROR: couldn't get current UIGraphicsContext")
        }
        
        super.drawRect(rect)
    }
}

