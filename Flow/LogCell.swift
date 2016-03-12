//
//  LogCell.swift
//  FlowLog
//
//  Created by Florian Pfisterer on 09.03.16.
//  Copyright © 2016 Florian Pfisterer. All rights reserved.
//

import UIKit

class LogCell: UITableViewCell
{
    @IBOutlet weak var titleFlowStateLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var activityLabel: UILabel!
    @IBOutlet weak var happinessLabel: UILabel!
    @IBOutlet weak var energyLabel: UILabel!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)
    }
}
