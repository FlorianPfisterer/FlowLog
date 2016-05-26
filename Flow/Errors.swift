//
//  Errors.swift
//  FlowLog
//
//  Created by Florian Pfisterer on 25.05.16.
//  Copyright © 2016 Florian Pfisterer. All rights reserved.
//

import Foundation

struct EString
{
    static let ErrorOccurred = "An error occured"
    static let TryAgainLater = "Please try again later"
    static let Okay = "Okay"
}

enum FlowLogError: ErrorType
{
    case VCCouldntBeInstantiated
    
    var alertTuple: (String, String?) {
        switch self
        {
        case .VCCouldntBeInstantiated: return (EString.ErrorOccurred, EString.TryAgainLater)
        }
    }
}