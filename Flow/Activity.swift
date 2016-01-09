//
//  Activity.swift
//  FlowLog
//
//  Created by Florian Pfisterer on 08/01/16.
//  Copyright © 2016 Florian Pfisterer. All rights reserved.
//

import Foundation
import CoreData


class Activity: NSManagedObject
{
    func getName() -> String
    {
        if let name = self.name
        {
            return name
        }
        
        return "Error"
    }

}
