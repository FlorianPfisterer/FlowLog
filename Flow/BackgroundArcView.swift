//
//  BackgroundArcView.swift
//  FlowLog
//
//  Created by Florian Pfisterer on 29.02.16.
//  Copyright © 2016 Florian Pfisterer. All rights reserved.
//

import UIKit

@IBDesignable class BackgroundArcView: UIView
{
    private var gradientBackgroundView: GradientBackgroundView!
    private var arcMaskLayer: CAShapeLayer!
    
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

extension BackgroundArcView
{
    private func sharedInitialization()
    {
        self.gradientBackgroundView = GradientBackgroundView(frame: self.bounds, relativeStartPoint: CGPoint(x: 0.5, y: 0), relativeEndPoint: CGPoint(x: 0.5, y: 1))
        self.gradientBackgroundView.firstColor = UIColor.gradientStartColor()
        self.gradientBackgroundView.secondColor = UIColor.gradientEndColor()
        self.addSubview(self.gradientBackgroundView)
        
        self.arcMaskLayer = CAShapeLayer()
        self.layer.mask = self.arcMaskLayer
    }
}

extension BackgroundArcView
{
    override func layoutSubviews()
    {
        super.layoutSubviews()
        
        self.gradientBackgroundView.frame = self.bounds
        
        let arcPath = UIBezierPath(ovalInRect: CGRect(x: 0, y: 0, width: self.width, height: self.height*2))
        self.arcMaskLayer.path = arcPath.CGPath
    }
}














