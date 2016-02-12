//
//  ColorWheelView.swift
//  FlowLog
//
//  Created by Florian Pfisterer on 02/02/16.
//  Copyright © 2016 Florian Pfisterer. All rights reserved.
//

import UIKit

class ColorWheelView: UIView
{
    @IBInspectable
    var arcWidth: CGFloat = 40 {
        didSet
        {
            self.setNeedsDisplay()
        }
    }
    
    var colorDelegate: ColorWheelViewDelegate!
    
    private let colorSegmentCount: Int = 400
}

extension ColorWheelView
{
    override func drawRect(rect: CGRect)
    {
        if let context = UIGraphicsGetCurrentContext()
        {
            self.drawColorWheel(inContext: context, inRect: rect)
        }
    }
}

extension ColorWheelView
{
    private func drawColorWheel(inContext context: CGContextRef, inRect rect: CGRect)
    {
        CGContextSaveGState(context)
        
        let arcRadius: CGFloat = (rect.minDimension - self.arcWidth) / 2
        
        // settings
        CGContextSetLineCap(context, .Butt)
        CGContextSetLineWidth(context, self.arcWidth)
        
        // draw arc proportion per segment
        for segment in 0..<self.colorSegmentCount
        {
            let proportion = CGFloat(segment) / CGFloat(self.colorSegmentCount)
            let nextProportion = CGFloat(segment + 1) / CGFloat(self.colorSegmentCount)
            
            let startAngle = proportion * 2 * π - (π/2)
            let endAngle = nextProportion * 2 * π - (π/2)
            
            self.colorDelegate?.getColorForColorWheel(atProportion: proportion).setStroke()
            
            // draw arc
            CGContextAddArc(context, rect.midX, rect.midY, arcRadius, startAngle, endAngle, 0)
            CGContextStrokePath(context)
        }
        
        CGContextRestoreGState(context)
    }
}

protocol ColorWheelViewDelegate
{
    func getColorForColorWheel(atProportion proportion: CGFloat) -> UIColor
}
