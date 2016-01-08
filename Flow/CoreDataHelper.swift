//
//  CoreDataHelper.swift
//  Flow
//
//  Created by Florian Pfisterer on 05/01/16.
//  Copyright © 2016 Florian Pfisterer. All rights reserved.
//

import Foundation
import CoreData
import UIKit

enum CoreDataError: ErrorType
{
    case FetchingError
}

class CoreDataHelper
{
    class func managedObjectContext() -> NSManagedObjectContext
    {
        return (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    }
    
    class func insertManagedObject(className: String, managedObjectContext: NSManagedObjectContext) -> AnyObject
    {
        let managedObject = NSEntityDescription.insertNewObjectForEntityForName(className, inManagedObjectContext: managedObjectContext)
        return managedObject
    }
    
    class func fetchEntities(className: String, managedObjectContext: NSManagedObjectContext, predicate: NSPredicate?, sortDescriptor: NSSortDescriptor?, limit: Int? = nil) throws -> NSArray
    {
        let fetchRequest = NSFetchRequest()
        fetchRequest.returnsObjectsAsFaults = false
        let entityDesciption = NSEntityDescription.entityForName(className, inManagedObjectContext: managedObjectContext)
        
        fetchRequest.entity = entityDesciption
        
        if let _ = predicate
        {
            fetchRequest.predicate = predicate!
        }
        
        if let _ = sortDescriptor
        {
            fetchRequest.sortDescriptors = [sortDescriptor!]
        }
        
        if let _ = limit
        {
            fetchRequest.fetchLimit = limit!
        }
        
        var items = []
        do
        {
            try items = managedObjectContext.executeFetchRequest(fetchRequest)
        }
        catch
        {
            throw CoreDataError.FetchingError
        }
        
        return items
    }
    
    class func deleteObjectsInArray(array: [NSManagedObject], fromContext context: NSManagedObjectContext)
    {
        for object in array
        {
            context.deleteObject(object)
        }
    }
}