//
//  ActionCollectionCell.swift
//  Flow
//
//  Created by Florian Pfisterer on 03/01/16.
//  Copyright © 2016 Florian Pfisterer. All rights reserved.
//

import UIKit

class ActionCollectionCell: UICollectionViewCell
{
    @IBOutlet weak var titleLabel: UILabel!
    
    private enum CellSelectionState
    {
        case Selected
        case Normal
    }
    
    private var selectionState: CellSelectionState = .Normal
    
    private var normalBackgroundColor: UIColor!
    private let selectedBackgroundColor: UIColor = UIColor.darkGrayColor()
}

extension ActionCollectionCell
{
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        super.touchesBegan(touches, withEvent: event)
        self.normalBackgroundColor = self.backgroundColor
        
        self.changeCellSelectionState(.Selected)
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?)
    {
        super.touchesCancelled(touches, withEvent: event)
        self.changeCellSelectionState(.Normal)
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        super.touchesEnded(touches, withEvent: event)
        self.changeCellSelectionState(.Normal)
    }
}

extension ActionCollectionCell
{
    private func changeCellSelectionState(state: CellSelectionState)
    {
        UIView.animateWithDuration(state == .Normal ? 0.3 : 0.05, animations: {      // fast when selected, slower when deselected
            self.backgroundColor = state == .Selected ? self.selectedBackgroundColor : self.normalBackgroundColor
            self.layer.borderColor = self.backgroundColor?.CGColor
        })
    }
}
