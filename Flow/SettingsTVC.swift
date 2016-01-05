//
//  SettingsTVC.swift
//  Flow
//
//  Created by Florian Pfisterer on 03/01/16.
//  Copyright © 2016 Florian Pfisterer. All rights reserved.
//

import UIKit

class SettingsTVC: UITableViewController
{
    @IBOutlet weak var alarmsStartLabel: UILabel!
    @IBOutlet weak var alarmsEndLabel: UILabel!
    
    @IBOutlet weak var excludedTimeFramesLabel: UILabel!
    
    @IBOutlet weak var alarmSoundLabel: UILabel!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        self.setupLabels()
    }
    
    // MARK: - set up UI
    func setupLabels()
    {
        self.alarmsStartLabel.text = LogHelper.alarmStartTime.timeString()
        self.alarmsEndLabel.text = LogHelper.alarmEndTime.timeString()
        
        // TODO! exludedTimeFrames
        
        self.alarmSoundLabel.text = LogHelper.alarmSoundFileName
    }
}
