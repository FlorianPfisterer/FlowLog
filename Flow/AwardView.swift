//
//  AwardView.swift
//  FlowLog
//
//  Created by Florian Pfisterer on 01/02/16.
//  Copyright © 2016 Florian Pfisterer. All rights reserved.
//

import UIKit

@IBDesignable
class AwardView: UIView
{
    private let graphPoints: [CGFloat] = [1, 5, 18, 68, 170, 370]
    private var diagramView: DiagramView!
    
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
    
    // MARK: - Public API @IBInspectable
    @IBInspectable var startColor: UIColor = BAR_TINT_COLOR {
        didSet
        {
            self.diagramView.startColor = self.startColor
        }
    }
    
    @IBInspectable var endColor: UIColor = UIColor.darkGrayColor() {
        didSet
        {
            self.diagramView.endColor = self.endColor
        }
    }
}

extension AwardView
{
    private func sharedInitialization()
    {
        self.diagramView = DiagramView()
        self.diagramView.backgroundColor = UIColor.clearColor()
        self.diagramView.graphPoints = self.graphPoints
        self.diagramView.setNeedsDisplay()
        
        self.addSubview(self.diagramView)
    }
}

extension AwardView
{
    private func getGraphViewFrame() -> CGRect
    {
        let height = self.bounds.size.height * 0.9
        let width = self.bounds.size.width * 1.0
        
        return CGRect(x: (self.bounds.size.width - width)/2,
            y: (self.bounds.size.height - height)/2,
            width: width, height: height)
    }
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        
        self.diagramView.frame = self.getGraphViewFrame()
    }
}
