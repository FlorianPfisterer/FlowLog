//
//  StartVC.swift
//  Flow
//
//  Created by Florian Pfisterer on 03/01/16.
//  Copyright © 2016 Florian Pfisterer. All rights reserved.
//

import UIKit

class StartVC: UIViewController
{
    @IBOutlet weak var daysLabel: UILabel!
    @IBOutlet weak var alarmsLabel: UILabel!
    @IBOutlet weak var quoteTextView: UITextView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.updateProgressLabels()
        self.showQuoteOfTheDay()
    }
    
    // MARK: - View Update
    func updateProgressLabels()
    {
        // TODO!
        let daysLeft = 7
        let alarmsLeft = 40
        
        self.daysLabel.text = "\(daysLeft)"
        self.alarmsLabel.text = "\(alarmsLeft)"
    }
    
    func showQuoteOfTheDay()
    {
        guard let path = NSBundle.mainBundle().pathForResource("Quotes", ofType: "plist") else
        {
            return
        }
        
        let array = NSArray(contentsOfFile: path)!
        let randomQuote = array.objectAtIndex(Int(arc4random_uniform(UInt32(array.count)))) as! [String : String]
        
        self.quoteTextView.text = randomQuote["quote"]! + " - " + randomQuote["author"]!.uppercaseString
    }
    
    // MARK: - IBActions
    @IBAction func showStatisticsInfo()
    {
        
    }
}
