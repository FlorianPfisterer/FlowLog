//
//  HorizontalColorBarView.swift
//  FlowLog
//
//  Created by Florian Pfisterer on 03/02/16.
//  Copyright © 2016 Florian Pfisterer. All rights reserved.
//

import UIKit

class HorizontalColorBarView: UIView
{
    var colors: (CGColorRef, CGColorRef)! {
        didSet
        {
            self.updateGradientLayer()
        }
    }
    
    private var gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.startPoint = CGPoint(x: 0, y: 0.5)
        layer.endPoint = CGPoint(x: 1, y: 0.5)
        return layer
    }()
    
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

extension HorizontalColorBarView
{
    private func sharedInitialization()
    {
        self.gradientLayer.masksToBounds = true
        self.layer.addSublayer(self.gradientLayer)
    }
}

extension HorizontalColorBarView
{
    override func layoutSubviews()
    {
        super.layoutSubviews()
        
        self.gradientLayer.frame = self.bounds
    }
}


extension HorizontalColorBarView
{
    func updateGradientLayer()
    {
        self.gradientLayer.colors = [self.colors.0, self.colors.1]
        self.gradientLayer.locations = [0, 1]
    }
}
