//
//  LogCell.swift
//  FlowLog
//
//  Created by Florian Pfisterer on 09.03.16.
//  Copyright © 2016 Florian Pfisterer. All rights reserved.
//

import UIKit

@IBDesignable
class LogCell: UITableViewCell
{
    @IBOutlet weak var titleFlowStateLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var activityLabel: UILabel!
    @IBOutlet weak var happinessLabel: UILabel!
    @IBOutlet weak var energyLabel: UILabel!
    
    private let happinessPostfix = "% 😃"
    private let energyPostfix = "% ⚡️"
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?)
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.sharedInitialization()
    }

    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        self.sharedInitialization()
    }
}

extension LogCell
{
    private func sharedInitialization()
    {
        self.selectionStyle = .None
        self.backgroundColor = UIColor.whiteColor()
    }
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
    }
}

extension LogCell
{
    func configureWithLog(log: LogEntry)
    {
        guard let flowState = FlowState(rawValue: log.flowStateIndex) else { return }
        self.titleFlowStateLabel.text = String(flowState)
        
        let createdAt = NSDate(timeIntervalSinceReferenceDate: log.createdAt)
        
        // TODO: ohne Jahr
        self.dateLabel.text = StringHelper.getLocalizedDateDescription(createdAt)
        self.timeLabel.text = StringHelper.getLocalizedTimeDescription(createdAt)
        
        if let activity = log.activity
        {
            self.activityLabel.text = activity.getName()
        }
        else
        {
            print("ERROR: log has no activity")
            self.activityLabel.text = "Error"
        }
        
        self.setHappinessLevel(StringHelper.format(".0", value: CGFloat(log.happinessLevel) * 100))
        self.setEnergyLevel(StringHelper.format(".0", value: CGFloat(log.energyLevel) * 100))
        
        let alpha = flowState.weight*0.8
        self.backgroundColor = UIColor.gradientStartColor().colorWithAlphaComponent(alpha)
        
        self.setTextColor(alpha > 0.48 ? UIColor.whiteColor() : UIColor.blackColor())
    }
}

extension LogCell
{
    private func setTextColor(color: UIColor)
    {
        self.titleFlowStateLabel.textColor = color
        self.dateLabel.textColor = color
        self.timeLabel.textColor = color
        self.activityLabel.textColor = color
        self.happinessLabel.textColor = color
        self.energyLabel.textColor = color
    }
}

extension LogCell
{
    private func setHappinessLevel(happiness: String)
    {
        self.happinessLabel.text = "\(happiness)\(self.happinessPostfix)"
    }
    
    private func setEnergyLevel(energy: String)
    {
        self.energyLabel.text = "\(energy)\(self.energyPostfix)"
    }
}

























