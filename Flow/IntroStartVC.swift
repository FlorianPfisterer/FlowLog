//
//  IntroStartVC.swift
//  Flow
//
//  Created by Florian Pfisterer on 06/01/16.
//  Copyright © 2016 Florian Pfisterer. All rights reserved.
//

import UIKit

class IntroStartVC: UIViewController
{
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        super.viewWillDisappear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
}
