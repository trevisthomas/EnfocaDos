//
//  AppDelegate.swift
//  Enfoca
//
//  Created by Trevis Thomas on 5/14/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import UIKit
import CloudKit
import UserNotifications

struct WeakReference<T>
{
    weak var _reference:AnyObject?
    init(_ object:T) {_reference = object as AnyObject}
    var reference:T? { return _reference as? T }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var webService : WebService!
    var applicationDefaults : ApplicationDefaults!
    
    fileprivate var eventListeners: [WeakReference<EventListener>] = []
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        UIApplication.shared.statusBarStyle = .lightContent
        
//        UNUserNotificationCenter.current().requestAuthorization(options:
//            [[.alert, .sound, .badge]], completionHandler: { (granted, error) in
//                // Handle Error
//                
////                fatalError() //For the moment.
//        })
        
        application.registerForRemoteNotifications()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        saveDefaults()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
        saveDefaults()
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        
//        let notification = CKNotification(fromRemoteNotificationDictionary: userInfo)
        let notification = CKQueryNotification(fromRemoteNotificationDictionary: userInfo)
        
        let recordType = notification.subscriptionID
        
        let alertBody = notification.alertBody ?? ""
        let reason = notification.queryNotificationReason
        
        
        
        if notification.notificationType == .query {
            guard let recordId = notification.recordID else { return }
//            print()
            let msg = "\(recordType!) and the alert body \(alertBody) recordId: \(recordId)"
            print(msg)
            
            
//            presentAlert(title: "Notificaiton Test", message: msg, completion: { 
//                //
//                completionHandler(.newData) //WTF is this for?
//            })
            
        
            if recordType == "WordPair" && reason == .recordUpdated {
                
                
                webService.remoteWordPairUpdate(pairId: recordId.recordName, callback: { (wordPair: WordPair) in
                    let event = Event(type: .wordPairUpdated, data: wordPair)
                    self.fireEvent(source: self, event: event)
                    
                    completionHandler(.newData)
                })
            }
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        //Not really needed for CK notifications, because i dont care about the token.
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        presentAlert(title: "Notification error", message: error.localizedDescription) { 
            //
        }
    }

    func saveDefaults(){
        applicationDefaults.save(dictionary: webService.getCurrentDictionary(),includingDataStore: webService.toData())
    }
    
}

extension AppDelegate {
    
    func addListener(listener: EventListener) {
        
        for ref in eventListeners {
            guard let l = ref.reference else { continue }
            if listener as AnyObject === l as AnyObject {
                return
            }
        }
        
        let ref = WeakReference<EventListener>(listener)
        eventListeners.append(ref)
    }
    
    func fireEvent(source: AnyObject, event: Event) {
        //Hm, should probably remove dereferenced ones.
        
        for ref in eventListeners {
            guard let listener = ref.reference else {
                //TODO, cleanup?
                return
            }
            
            if source === listener as AnyObject{
                
                return
            }
            //todo, if you end up using this for real, invoke later.
            ref.reference?.onEvent(event: event)
            
        }
    }
    
    func presentAlert(title : String, message : String?, completion: @escaping ()->()){
        invokeLater {
            
            let topWindow = UIWindow(frame: UIScreen.main.bounds)
            topWindow.rootViewController = UIViewController()
            topWindow.windowLevel = UIWindowLevelAlert + 1
            
            topWindow.makeKeyAndVisible()
            topWindow.rootViewController?.presentAlert(title: title, message: message, completion: completion)
            
//            self.window?.rootViewController?.presentAlert(title: title, message: message, completion: completion)
        }
    }
}


func getAppDelegate() -> AppDelegate{
    return UIApplication.shared.delegate as! AppDelegate
}

func isTestMode() -> Bool{
    if ProcessInfo.processInfo.arguments.contains("UITest") {
        return true;
    } else {
        return false;
    }
//    return true
}



