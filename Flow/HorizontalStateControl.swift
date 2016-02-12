//
//  HorizontalStateControl.swift
//  FlowLog
//
//  Created by Florian Pfisterer on 03/02/16.
//  Copyright © 2016 Florian Pfisterer. All rights reserved.
//

import UIKit

@IBDesignable
class HorizontalStateControl: UIControl
{
    private var colorBarView: HorizontalColorBarView!
    
    @IBInspectable
    var startColor: UIColor = UIColor.blueColor() {
        didSet
        {
            self.setGradientColors()
        }
    }

    @IBInspectable
    var endColor: UIColor = UIColor.darkGrayColor() {
        didSet
        {
            self.setGradientColors()
        }
    }
    
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

extension HorizontalStateControl
{
    private func sharedInitialization()
    {
        self.layer.cornerRadius = 10
        
        self.colorBarView = HorizontalColorBarView()
        self.colorBarView.backgroundColor = UIColor.clearColor()
        
        self.colorBarView.clipsToBounds = true
        
        self.setGradientColors()
        
        self.addSubview(self.colorBarView)
    }
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        self.colorBarView.frame = self.bounds
    }
}

extension HorizontalStateControl
{
    private func setGradientColors()
    {
        self.colorBarView.colors = (self.startColor.CGColor, self.endColor.CGColor)
    }
}


























