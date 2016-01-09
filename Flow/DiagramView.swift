//
//  DiagramView.swift
//  FlowLog
//
//  Created by Florian Pfisterer on 08/01/16.
//  Copyright © 2016 Florian Pfisterer. All rights reserved.
//

import UIKit

@IBDesignable class DiagramView: UIView
{
    @IBInspectable var startColor: UIColor = UIColor.redColor()
    @IBInspectable var endColor: UIColor = UIColor.greenColor()
    
    var graphPoints: [CGFloat] = [3, 6, 4, 21, 12, 3, 23, 3, 5, 8, 9, 2]        // example
    
    override func drawRect(rect: CGRect)
    {
        // make rounded corners
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: .AllCorners, cornerRadii: CGSize(width: 10, height: 10))
        path.addClip()
        
        // draw gradient
        let context = UIGraphicsGetCurrentContext()
        
        let colors = [self.startColor.CGColor, self.endColor.CGColor]
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let colorLocations: [CGFloat] = [0.0, 1.0]
        
        let gradient = CGGradientCreateWithColors(colorSpace, colors, colorLocations)
        
        var startPoint = CGPointZero
        var endPoint = CGPoint(x: 0, y: self.bounds.size.height)
        CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, .DrawsAfterEndLocation)
        
        // draw graph
        let margin: CGFloat = 20
        let topBorder: CGFloat = 60
        let bottomBorder: CGFloat = 50
        let graphHeight = rect.height - topBorder - bottomBorder
        
        if self.graphPoints.count > 1
        {
            // x coordinate
            let xFromColumn: (column: Int) -> CGFloat = { column in
                let space = (rect.width - margin*2 - 4) / CGFloat(self.graphPoints.count - 1)
                var x: CGFloat = CGFloat(column) * space
                x += margin + 2
                return x
            }
            
            // y coordinate
            if let maxValue = self.graphPoints.maxElement()
            {
                if maxValue != 0
                {
                    let yFromGraphPoint: (graphPoint: CGFloat) -> CGFloat = { graphPoint in
                        var y = graphPoint / maxValue * graphHeight
                        y = graphHeight + topBorder - y // flip
                        return y
                    }
                    
                    // draw graph
                    UIColor.whiteColor().setFill()
                    UIColor.whiteColor().setStroke()
                    
                    let path = UIBezierPath()
                    path.moveToPoint(CGPoint(x: xFromColumn(column: 0), y: yFromGraphPoint(graphPoint: self.graphPoints[0])))
                    
                    for i in 1..<self.graphPoints.count
                    {
                        let nextPoint = CGPoint(x: xFromColumn(column: i), y: yFromGraphPoint(graphPoint: self.graphPoints[i]))
                        path.addLineToPoint(nextPoint)
                    }
                    
                    // clipping graph gradient below graph
                    CGContextSaveGState(context)
                    
                    let clippingPath = path.copy() as! UIBezierPath
                    
                    clippingPath.addLineToPoint(CGPoint(x: xFromColumn(column: self.graphPoints.count - 1), y: rect.height))
                    clippingPath.addLineToPoint(CGPoint(x: xFromColumn(column: 0), y: rect.height))
                    clippingPath.closePath()
                    
                    clippingPath.addClip()
                    
                    let highestPointY = yFromGraphPoint(graphPoint: maxValue)
                    startPoint = CGPoint(x: margin, y: highestPointY)
                    endPoint = CGPoint(x: margin, y: self.bounds.height)
                    
                    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, .DrawsAfterEndLocation)
                    
                    path.lineWidth = 1
                    path.stroke()
                    
                    CGContextRestoreGState(context)
                    
                    let circleRadius: CGFloat = 3.0
                    // draw circles on graph
                    for i in 0..<self.graphPoints.count
                    {
                        var point = CGPoint(x: xFromColumn(column: i), y: yFromGraphPoint(graphPoint: self.graphPoints[i]))
                        point.x -= circleRadius/2
                        point.y -= circleRadius/2
                        
                        let circle = UIBezierPath(ovalInRect: CGRect(origin: point, size: CGSize(width: circleRadius, height: circleRadius)))
                        circle.fill()
                    }
                }
            }
        }
        // draw horizontal lines
        let linePath = UIBezierPath()
        
        // top line
        linePath.moveToPoint(CGPoint(x: margin, y: topBorder))
        linePath.addLineToPoint(CGPoint(x: rect.width - margin, y: topBorder))
        
        // center line
        linePath.moveToPoint(CGPoint(x: margin, y: graphHeight/2 + topBorder))
        linePath.addLineToPoint(CGPoint(x: rect.width - margin, y: graphHeight/2 + topBorder))
        
        // bottom line
        linePath.moveToPoint(CGPoint(x: margin, y: rect.height - bottomBorder))
        linePath.addLineToPoint(CGPoint(x: rect.width - margin, y: rect.height - bottomBorder))
        
        let lineColor = UIColor(white: 1, alpha: 0.3)
        lineColor.setStroke()
        
        linePath.lineWidth = 1
        linePath.stroke()
    }
}
