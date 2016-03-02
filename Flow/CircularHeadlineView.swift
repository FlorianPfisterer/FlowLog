//
//  CircularHeadlineView.swift
//  FlowLog
//
//  Created by Florian Pfisterer on 01.03.16.
//  Copyright © 2016 Florian Pfisterer. All rights reserved.
//

import UIKit

@IBDesignable
class CircularHeadlineView: UIView
{
    // MARK: - Public API
    @IBInspectable
    var numberString: String = "" {
        didSet
        {
            self.numberLabel.text = self.numberString
        }
    }
    
    @IBInspectable
    var title: String = "" {
        didSet
        {
            self.titleLabel.text = self.title
        }
    }
    
    @IBInspectable
    var subTitle: String = "" {
        didSet
        {
            self.subTitleLabel.text = self.subTitle
        }
    }
    
    @IBInspectable
    var numberLabelFontSize: CGFloat = 15 {
        didSet
        {
            self.configureNumberLabel()
        }
    }
    
    @IBInspectable
    var titleLabelFontSize: CGFloat = 15 {
        didSet
        {
            self.configureTitleLabel(self.titleLabel)
        }
    }
    
    @IBInspectable
    var subTitleLabelFontSize: CGFloat = 15 {
        didSet
        {
            self.configureSubTitleLabel()
        }
    }
    
    @IBInspectable
    var subTitleLabelHeight: CGFloat = 20 {
        didSet
        {
            self.setNeedsDisplay()
        }
    }
    
    @IBInspectable
    var numberLabelBackgroundColor: UIColor = UIColor.gradientStartColor() {
        didSet
        {
            self.configureNumberLabel()
        }
    }
    
    @IBInspectable
    var labelMargin: CGFloat = 5 {
        didSet
        {
            self.setNeedsDisplay()
        }
    }
    
    // MARK: - Private UI
    private var numberLabel: UILabel!
    private var titleLabel: UILabel!
    private var subTitleLabel: UILabel!
    private var maskLayer: CAShapeLayer!
    
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

extension CircularHeadlineView
{
    private func sharedInitialization()
    {
        self.numberLabel = UILabel()
        self.configureNumberLabel()
        self.addSubview(self.numberLabel)
        
        self.titleLabel = UILabel()
        self.configureTitleLabel(self.titleLabel)
        self.addSubview(self.titleLabel)
        
        self.subTitleLabel = UILabel()
        self.configureSubTitleLabel()
        self.addSubview(self.subTitleLabel)
        
        self.maskLayer = CAShapeLayer()
        self.numberLabel.layer.mask = self.maskLayer
    }

    override func layoutSubviews()
    {
        super.layoutSubviews()
        
        self.numberLabel.frame = CGRect(x: 0, y: 0, width: self.height, height: self.height)
        let circlePath = UIBezierPath(ovalInRect: self.numberLabel.bounds)
        self.maskLayer.path = circlePath.CGPath
        
        self.titleLabel.frame = CGRect(x: self.height + self.labelMargin, y: 0, width: self.width - self.height - self.labelMargin, height: self.height - self.subTitleLabelHeight)
        
        self.subTitleLabel.frame = CGRect(x: self.height + self.labelMargin, y: self.height - self.subTitleLabelHeight, width: self.width - self.height - self.labelMargin, height: self.subTitleLabelHeight)
        
    }
}

extension CircularHeadlineView
{
    private func configureNumberLabel()
    {
        self.numberLabel.backgroundColor = self.numberLabelBackgroundColor
        self.numberLabel.textColor = UIColor.whiteColor()
        self.numberLabel.font = UIFont.systemFontOfSize(self.numberLabelFontSize)
        self.numberLabel.textAlignment = .Center
    }
    
    private func configureTitleLabel(label: UILabel)
    {
        label.backgroundColor = UIColor.clearColor()
        label.textColor = UIColor.whiteColor()
        label.font = UIFont.systemFontOfSize(self.titleLabelFontSize)
        label.textAlignment = .Left
    }
    
    private func configureSubTitleLabel()
    {
        self.configureTitleLabel(self.subTitleLabel)
        self.subTitleLabel.font = UIFont.systemFontOfSize(self.subTitleLabelFontSize)
    }
}






























