//
//  AppDelegate.swift
//  Flow
//
//  Created by Florian Pfisterer on 03/01/16.
//  Copyright © 2016 Florian Pfisterer. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate
{
    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool
    {
        self.performOpticalAdjustments()
        self.seedDatabaseIfNecessary()
        self.reactToPossibleNotificationsForApplication(application, withLaunchOptions: launchOptions)
        
        //DBSeedHelper.seedLogs(38) // DEBUG
        
        return true
    }
    
    // MARK: - Core Data stack
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.florianpfisterer.Flow" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("Flow", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do
        {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        }
        catch
        {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort() // TODO
        }
        
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    // MARK: - Core Data Saving support
    func saveContext ()
    {
        if managedObjectContext.hasChanges
        {
            do
            {
                try managedObjectContext.save()
            }
            catch
            {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort() // TODO!
            }
        }
    }
}

extension AppDelegate       // MARK: - Notifications
{
    private func notification(notification: UILocalNotification, receivedAtStartup startup: Bool)
    {
        if startup
        {
            self.setStoryboardTo("Log")
        }
        else
        {
            if let naviVC = UIApplication.sharedApplication().keyWindow?.rootViewController as? UINavigationController
            {
                naviVC.visibleViewController!.startLog()
            }
            else if let currentVC = UIApplication.sharedApplication().keyWindow?.rootViewController as? LogStarterDelegate
            {
                currentVC.startLog()
            }
        }
    }
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification)
    {
        switch application.applicationState
        {
        case .Active:
            self.notification(notification, receivedAtStartup: false)
            
        default:
            self.notification(notification, receivedAtStartup: true)
        }
    }
}

extension AppDelegate       // MARK: - Helper Functions
{
    private func performOpticalAdjustments()
    {
        UITabBar.appearance().tintColor = TINT_COLOR
        UITabBar.appearance().barTintColor = BAR_TINT_COLOR
        
        UIToolbar.appearance().tintColor = TINT_COLOR
        UIToolbar.appearance().barTintColor = BAR_TINT_COLOR
        
        UINavigationBar.appearance().tintColor = TINT_COLOR
        UINavigationBar.appearance().barTintColor = BAR_TINT_COLOR
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : TINT_COLOR, NSFontAttributeName : UIFont.systemFontOfSize(23)]
    }
    
    private func seedDatabaseIfNecessary()
    {
        if !NSUserDefaults.standardUserDefaults().boolForKey(DATABASE_ACTIVITIES_SEED_DONE_BOOL_KEY)
        {
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: DATABASE_ACTIVITIES_SEED_DONE_BOOL_KEY)
            DBSeedHelper.seedActivities()
        }
    }
    
    private func reactToPossibleNotificationsForApplication(application: UIApplication, withLaunchOptions launchOptions: [NSObject : AnyObject]?)
    {
        // react to possible notifications
        if let options = launchOptions
        {
            if let notification = options[UIApplicationLaunchOptionsLocalNotificationKey] as? UILocalNotification
            {
                self.notification(notification, receivedAtStartup: true)
            }
            else
            {
                self.setStoryboardTo("Main")
            }
        }
        else
        {
            if NSUserDefaults.standardUserDefaults().boolForKey(INTRO_DONE_BOOL_KEY)
            {
                self.setStoryboardTo("Main")
            }
            else
            {
                self.setStoryboardTo("Intro")
            }
            
            if !NotificationHelper.maySendNotifications
            {
                let settings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
                application.registerUserNotificationSettings(settings)
            }
        }
    }
    
    // MARK: - Storyboard Helper Function (also for Debug)
    private func setStoryboardTo(name: String)
    {
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        let storyboard = UIStoryboard(name: name, bundle: NSBundle.mainBundle())  //
        
        self.window?.rootViewController = storyboard.instantiateInitialViewController()
        self.window?.makeKeyAndVisible()
    }
}

extension AppDelegate       // MARK: - App Lifecycle
{
    func applicationWillResignActive(application: UIApplication)
    {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication)
    {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication)
    {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication)
    {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication)
    {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
}

