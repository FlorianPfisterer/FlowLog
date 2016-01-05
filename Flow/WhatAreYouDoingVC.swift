//
//  WhatAreYouDoingVC.swift
//  Flow
//
//  Created by Florian Pfisterer on 03/01/16.
//  Copyright © 2016 Florian Pfisterer. All rights reserved.
//

import UIKit

class WhatAreYouDoingVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UITextFieldDelegate, UICollectionViewDelegateFlowLayout
{
    private let cellIdentifier = "actionCell"
    
    var actions = [[String : String]]()
    var searchedActions: [[String : String]]?
    
    @IBOutlet weak var actionsCollectionView: UICollectionView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        
        self.loadAvailableActions()
    }
    
    // MARK: - Load Data
    func loadAvailableActions()
    {
        guard let path = NSBundle.mainBundle().pathForResource("Actions", ofType: "plist") else
        {
            print("ERROR: available actions not found")
            return
        }
        
        self.actions = NSArray(contentsOfFile: path) as! [[String : String]]
        self.actionsCollectionView.reloadData()
    }
    
    func performSearchWithSearchString(searchString: String)
    {
        // perform search
        self.searchedActions = StringHelper.searchDictionaryArrayForString(self.actions, searchString: searchString, concerningKey: "name")
        
        self.actionsCollectionView.reloadData()
    }
    
    func clearSearch()
    {
        self.searchedActions = nil
        self.actionsCollectionView.reloadData()
    }
    
    // MARK: - Collection View
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)
    {
        let occupationIndex = indexPath.row
        LogHelper.occupationIndex = occupationIndex
        
        self.performSegueWithIdentifier("toQuestion2Segue", sender: nil)
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int
    {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(self.cellIdentifier, forIndexPath: indexPath) as! ActionCollectionCell
        var actionData: [String : String]!
        
        if let searched = self.searchedActions
        {
            actionData = searched[indexPath.row]
        }
        else
        {
            actionData = self.actions[indexPath.row]
        }
        
        cell.actionImageView.image = UIImage(named: actionData["imageName"]!)
        cell.titleLabel.text = actionData["name"]!
        cell.layer.borderColor = BAR_TINT_COLOR.CGColor
        cell.layer.borderWidth = 1
        cell.layer.cornerRadius = 5
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        if let searched = self.searchedActions
        {
            return searched.count
        }
        return self.actions.count
    }
    
    // MARK: - FlowLayout Delegate
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize
    {
        return CGSize(width: self.actionsCollectionView.bounds.size.width/2 - 5, height: 80)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets
    {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    // MARK: - TextField Delegate
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        if textField.text == ""
        {
            self.clearSearch()
        }
        else
        {
            self.performSearchWithSearchString(textField.text!)
        }
        
        textField.resignFirstResponder()
        return true
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool
    {
        let textFieldContent = (textField.text! as NSString).stringByReplacingCharactersInRange(range, withString: string)
        
        if textFieldContent == ""
        {
            self.clearSearch()
        }
        else
        {
            self.performSearchWithSearchString(textFieldContent)
        }
        
        return true
    }
    
    func textFieldShouldClear(textField: UITextField) -> Bool
    {
        self.clearSearch()
        return true
    }
    
    override func startLogWithOptions(options: [String : AnyObject]?)
    {
        print("already doing log")
    }
}
