//
//  AppDelegate.swift
//  Enfoca
//
//  Created by Trevis Thomas on 5/14/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import UIKit

struct WeakReference<T>
{
    weak var _reference:AnyObject?
    init(_ object:T) {_reference = object as? AnyObject}
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

    private func saveDefaults(){
        applicationDefaults.save(includingDataStore: webService.serialize())
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
            
            ref.reference?.onEvent(event: event)
            
        }
    }
}


func getAppDelegate() -> AppDelegate{
    return UIApplication.shared.delegate as! AppDelegate
}

func isTestMode() -> Bool{
    //        if ProcessInfo.processInfo.arguments.contains("UITest") {
    //            return true;
    //        } else {
    //            return false;
    //        }
    return true
}

