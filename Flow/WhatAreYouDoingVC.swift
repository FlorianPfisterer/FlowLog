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
    
    var activities = [Activity]()
    var searchedActivities: [Activity]?
    
    @IBOutlet weak var actionsCollectionView: UICollectionView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        
        self.actionsCollectionView.backgroundView = UIView(frame: CGRectZero)
        self.actionsCollectionView.backgroundColor = UIColor.clearColor()
        
        self.loadAvailableActions()
    }
    
    // MARK: - Load Data
    func loadAvailableActions()
    {
        let context = CoreDataHelper.managedObjectContext()
        
        do
        {
            let sortDescriptor = NSSortDescriptor(key: "used", ascending: false)
            let activities = try CoreDataHelper.fetchEntities("Activity", managedObjectContext: context, predicate: nil, sortDescriptor: sortDescriptor) as! [Activity]
            self.activities = activities
            self.actionsCollectionView.reloadData()
        }
        catch
        {
            print("ERROR fetching activities: \(error)")
        }
    }
    
    func performSearchWithSearchString(searchString: String)
    {
        // perform search
        self.searchedActivities = StringHelper.searchActivityArrayForString(self.activities, searchString: searchString)
        
        self.actionsCollectionView.reloadData()
    }
    
    func clearSearch()
    {
        self.searchedActivities = nil
        self.actionsCollectionView.reloadData()
    }
    
    // MARK: - Collection View
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)
    {
        let activityIndex = indexPath.row
        
        if activityIndex == 0       // first cell
        {
            let alert = UIAlertController(title: "Add New Activity", message: "Type the name of the activity", preferredStyle: .Alert)
            alert.addTextFieldWithConfigurationHandler({ textField in
                textField.placeholder = "activity name"
                textField.keyboardType = .Default   // TODO+: textField did return => SO edited question by me
            })
            alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Save and proceed", style: .Default, handler: {
                _ in
                
                // TODO+ check if activity not available yet
                let context = CoreDataHelper.managedObjectContext()
                let newActivityName = alert.textFields![0].text!
                let newActivity = CoreDataHelper.insertManagedObject("Activity", managedObjectContext: context) as! Activity
                
                newActivity.name = newActivityName
                newActivity.used = 1
                
                self.activities.append(newActivity)
                
                try! context.save()
                
                // proceed
                LogHelper.currentActivity = newActivity
                self.performSegueWithIdentifier("toQuestion2Segue", sender: nil)
            }))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        else
        {
            LogHelper.currentActivity = self.activities[activityIndex - 1]
            
            self.performSegueWithIdentifier("toQuestion2Segue", sender: nil)
        }
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int
    {
        return 1
    }
    
    var standardFontSize: CGFloat?
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(self.cellIdentifier, forIndexPath: indexPath) as! ActionCollectionCell
        if let fontSize = self.standardFontSize
        {
            cell.titleLabel.font = UIFont.systemFontOfSize(fontSize)
        }
        else
        {
            self.standardFontSize = cell.titleLabel.font.pointSize
        }
        
        if indexPath.row == 0       // first cell
        {
            cell.titleLabel.text = "+"
            cell.titleLabel.font = UIFont.systemFontOfSize(self.standardFontSize! + 20)
        }
        else        // other cells
        {
            var activity: Activity!
            let row = indexPath.row - 1
            
            if let searched = self.searchedActivities
            {
                activity = searched[row]
            }
            else
            {
                activity = self.activities[row]
            }
            
            cell.titleLabel.text = activity.getName()
        }
        
        cell.layer.borderColor = BAR_TINT_COLOR.CGColor
        cell.layer.borderWidth = 2
        cell.layer.cornerRadius = 5
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        if let searched = self.searchedActivities
        {
            return searched.count + 1
        }
        return self.activities.count + 1
    }
    
    // MARK: - FlowLayout Delegate
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize
    {
        return CGSize(width: self.actionsCollectionView.bounds.size.width/2 - 5, height: 45)
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
    
    override func startLogWithLogNr(nr: Int)
    {
        print("already doing log, incoming request for nr \(nr)")
    }
}
