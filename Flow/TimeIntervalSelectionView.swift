//
//  TimeIntervalSelectionView.swift
//  FlowLog
//
//  Created by Florian Pfisterer on 01.03.16.
//  Copyright © 2016 Florian Pfisterer. All rights reserved.
//

import UIKit

class TimeIntervalSelectionView: UIView
{
    private var sliderView: UIView!
    private var infoLabel: UILabel!
    
    // MARK: - Public API
    var sliderViewWidth: CGFloat = 25
    var infoLabelHeight: CGFloat = 30
    
    var time: Time! {
        didSet
        {
            let timeDescription = self.time.timeString()
            self.infoLabel.text = timeDescription
        }
    }
    
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

extension TimeIntervalSelectionView
{
    private func sharedInitialization()
    {
        self.sliderView = UIView()
        self.configureBorderView(self.sliderView)
        self.addSubview(self.sliderView)
        
        self.infoLabel = UILabel()
        self.configureLabel(self.infoLabel)
        self.addSubview(self.infoLabel)
    }
    
    private func configureBorderView(view: UIView)
    {
        view.layer.cornerRadius = 6
        view.backgroundColor = UIColor.clearColor()
        view.layer.borderColor = UIColor.gradientStartColor().CGColor
        view.layer.borderWidth = 4
    }
    
    private func configureLabel(label: UILabel)
    {
        label.backgroundColor = UIColor.gradientStartColor()
        label.textColor = UIColor.whiteColor()
        label.font = UIFont.systemFontOfSize(13)
        label.textAlignment = .Center
        label.layer.cornerRadius = 7
        label.clipsToBounds = true
    }
}

extension TimeIntervalSelectionView
{
    override func layoutSubviews()
    {
        super.layoutSubviews()
        
        self.sliderView.frame = CGRect(x: (self.width - self.sliderViewWidth)/2, y: 0, width: self.sliderViewWidth, height: self.height - self.infoLabelHeight + 4)
        
        self.infoLabel.frame = CGRect(x: 0, y: self.height - self.infoLabelHeight, width: self.width, height: self.infoLabelHeight)
    }
}
