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
    
    fileprivate var synchRequestDenied: Bool  = false
    
    
    fileprivate var eventListeners: [WeakReference<EventListener>] = []
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        UIApplication.shared.statusBarStyle = .lightContent
        
//        UNUserNotificationCenter.current().requestAuthorization(options:
//            [[.alert, .sound, .badge]], completionHandler: { (granted, error) in
//                // Handle Error
//                
////                fatalError() //For the moment.
//        })
        
        if isTestMode() {
            return true
        }
        
        do {
            Network.reachability = try Reachability(hostname: "www.google.com")
            do {
                try Network.reachability?.start()
            } catch let error as Network.Error {
                print(error)
            } catch {
                print(error)
            }
        } catch {
            print(error)
        }
        
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
        
        synchRequestDenied = false
        
        saveDefaults()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        print("Did become active")
        performCloudSyncCheck()
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
        guard let _ = webService else { return }
        guard let data = webService.toData() else { return }
        
        applicationDefaults.save(dictionary: webService.getCurrentDictionary(),includingDataStore: data)
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
    
    func presentAlert(title : String, message : String?, completion: @escaping ()->() = {}){
        invokeLater {
            
            let topWindow = UIWindow(frame: UIScreen.main.bounds)
            topWindow.rootViewController = UIViewController()
            topWindow.windowLevel = UIWindowLevelAlert + 1
            
            topWindow.makeKeyAndVisible()
            topWindow.rootViewController?.presentAlert(title: title, message: message, completion: completion)
            
//            self.window?.rootViewController?.presentAlert(title: title, message: message, completion: completion)
        }
    }
    
    private func presentViewController(_ vc: UIViewController, animated: Bool, completion: @escaping ()->() = {}){
        invokeLater {
            let topWindow = UIWindow(frame: UIScreen.main.bounds)
            topWindow.rootViewController = UIViewController()
            topWindow.windowLevel = UIWindowLevelAlert + 1
            
            topWindow.makeKeyAndVisible()
            topWindow.rootViewController?.present(vc, animated: animated, completion: completion)
        }
    }
    
    func performCloudSyncCheck() {
        if synchRequestDenied == true {
            return
        }
        
        isDataStoreSynchronized { (inSync: Bool) in
            if !inSync {
                getAppDelegate().applicationDefaults.removeDictionary(self.webService.getCurrentDictionary())
                self.presentDataOutOfSynchAlert()
            }
        }
    }
    
    func isDataStoreSynchronized(callback: @escaping (Bool)->()) {
        if webService == nil {
            return
        }
        webService.isDataStoreSynchronized { (inSynch: Bool?, error: String?) in
            guard let inSynch = inSynch else {
                fatalError("Synch check crashed with fatal error")
            }
            callback(inSynch)
            
        }
        
    }
    
    private func presentDataOutOfSynchAlert(){
        let dialog = UIAlertController(title: "Refresh Needed", message: "Data is out of synch, would you like to reload now?", preferredStyle: UIAlertControllerStyle.alert)
        
        dialog.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            
            self.presentDictonaryLoadViewController()
        }))
        
        dialog.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            self.synchRequestDenied = true
        }))
        
        presentViewController(dialog, animated: true)
    }
    
    private func presentDictonaryLoadViewController() {
        // Access the storyboard and fetch an instance of the view controller
        let storyboard = UIStoryboard(name: "DictionarySelection", bundle: nil);
        let viewController: DictionaryLoadingViewController = storyboard.instantiateViewController(withIdentifier: "DictionaryLoadingViewController") as! DictionaryLoadingViewController;
        
        viewController.initialize(dictionary: webService.getCurrentDictionary())
        presentViewController(viewController, animated: true)
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



