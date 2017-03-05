//
//  AppDelegate.swift
//  PRBuddy
//
//  Created by Thang on 20.12.2016.
//  Copyright © 2016 Thangphan. All rights reserved.
//

import UIKit
import CoreData
import Firebase
import DropDown
import OneSignal
import UserNotifications
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var badgeCount = 0


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        Fabric.with([Crashlytics.self])
        FIRApp.configure()
        window = UIWindow(frame: UIScreen.main.bounds)
        
        let sb = UIStoryboard(name: "Main", bundle: nil)
        var initionViewController = sb.instantiateViewController(withIdentifier: "Onboarding")
        
        let userDefaults = UserDefaults.standard
        
        if userDefaults.bool(forKey: "introComplete") {
            initionViewController = sb.instantiateViewController(withIdentifier: "loginView")
        }

        
        
        OneSignal.setLogLevel(.LL_VERBOSE, visualLevel: .LL_NONE)
        
        OneSignal.initWithLaunchOptions(launchOptions, appId: "804e15af-8ba1-4e20-ba8f-9c908b6eadad", handleNotificationReceived: { (notification) in
            print("Received Notification - \(notification?.payload.notificationID)")
            UIApplication.shared.applicationIconBadgeNumber = 1
            
        }, handleNotificationAction: { (result) in
            
            // This block gets called when the user reacts to a notification received
            let payload = result?.notification.payload
            var fullMessage = payload?.title
            
            //Try to fetch the action selected
            if let actionSelected = result?.action.actionID {
                fullMessage =  fullMessage! + "\nPressed ButtonId:\(actionSelected)"
            }
            
            print(fullMessage ?? "Hi")
            
            
            application.applicationIconBadgeNumber = 1
            
        }, settings: [kOSSettingsKeyAutoPrompt : false, kOSSettingsKeyInAppAlerts : false])
       
        // iOS 10 ONLY - Add category for the OSContentExtension
        // Make sure to add UserNotifications framework in the Linked Frameworks & Libraries.
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().getNotificationCategories { (categories) in
                let myAction = UNNotificationAction(identifier: "action0", title: "Hit Me!", options: .foreground)
                let myCategory = UNNotificationCategory(identifier: "myOSContentCategory", actions: [myAction], intentIdentifiers: [], options: .customDismissAction)
                let mySet = NSSet(array: [myCategory]).addingObjects(from: categories) as! Set<UNNotificationCategory>
                UNUserNotificationCenter.current().setNotificationCategories(mySet)
            }
        }
        
        DropDown.startListeningToKeyboard()
        
        let notificationTypes: UIUserNotificationType = [UIUserNotificationType.alert, UIUserNotificationType.badge, UIUserNotificationType.sound]
        let notificationSettings = UIUserNotificationSettings(types: notificationTypes, categories: nil)
        
        application.registerForRemoteNotifications()
        application.registerUserNotificationSettings(notificationSettings)
        
        //PersonalTrainerLogin
        window?.rootViewController = initionViewController
        window?.makeKeyAndVisible()
        
        return true
    }

    
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if ( application.applicationState == UIApplicationState.inactive
            || application.applicationState == UIApplicationState.background  ) {
            NSLog( "INACTIVE" );
            application.applicationIconBadgeNumber = 1
            completionHandler(UIBackgroundFetchResult.newData);
        } else {
            NSLog( "ACTIVE" );
            UIApplication.shared.applicationIconBadgeNumber = 1

            completionHandler(UIBackgroundFetchResult.newData);
        }
        UIApplication.shared.applicationIconBadgeNumber = 1
        completionHandler(UIBackgroundFetchResult.newData);

    }
 
    /*
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return
    }
    */
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    /*
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        AWSMobileClient.sharedInstance.applicationDidBecomeActive(application: application)
    }
    */
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "PRBuddy")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store
        // coordinator for the application.) This property is optional since there are legitimate error
        // conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentContainer.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
}

