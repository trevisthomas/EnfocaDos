//
//  NewAppLaunchViewController.swift
//  Enfoca
//
//  Created by Trevis Thomas on 6/26/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import UIKit

class NewAppLaunchViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var footerLabel: UILabel!
    @IBOutlet weak var bodyView: UIView!
    @IBOutlet weak var activityIndicator: UIView!
    @IBOutlet weak var brainImageView: UIImageView!
    @IBOutlet weak var lighrraysImageView: UIImageView!
    
    fileprivate var animator = EnfocaDefaultAnimator()
    
    private(set) var dictionaryList: [UserDictionary]?
    private var autoload: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(statusManager), name: .flagsChanged, object: Network.reachability)
        
        updateUserInterface()
        
    }
    
    func updateUserInterface() {
        
        if isTestMode() {
            self.launch(isNetworkAvailable: true)
        }
        
        guard let status = Network.reachability?.status else { return }
        guard let isNetworkAvailable = Network.reachability?.isReachable else {
            //Network reachability class is not working properly
            fatalError("Network reacability returned a nil.")
            //TODO: Seriously consider if this should be fatal, or if you should just continue
        }
        
        invokeLater {
            if isNetworkAvailable {
                print("network connection verfied")
                self.launch(isNetworkAvailable: isNetworkAvailable)
            } else {
                self.presentOkCancelAlert(title: "Network offline", message: "No network connection detected. Would you like to continue offline?", callback: { (proceed: Bool) in
                    if proceed {
                        self.launch(isNetworkAvailable: isNetworkAvailable)
                    } else {
                        abort()
                    }
                })
            }
        }
        
        
        
        print("Reachability Summary")
        print("Status:", status)
        print("HostName:", Network.reachability?.hostname ?? "nil")
        print("Reachable:", Network.reachability?.isReachable ?? "nil")
        print("Wifi:", Network.reachability?.isReachableViaWiFi ?? "nil")
    }
    
    func statusManager(_ notification: NSNotification) {
        updateUserInterface()
    }

    func initialize(autoload: Bool = true) {
        self.autoload = autoload
    }
    
    fileprivate func postInitCallback(_ service: WebService) -> ([UserDictionary]?, EnfocaError?) -> () {
        return { (dictionaryList: [UserDictionary]?, error: EnfocaError?) in
            if let error = error {
                self.presentFatalAlert(title: "Failed to initialize app", message: error)
                return
            }
            
            getAppDelegate().webService = service
            
            guard let dictionaryList: [UserDictionary] = dictionaryList else { fatalError() }
            
            if self.autoload {
                if let data = getAppDelegate().applicationDefaults.load() {
                    self.performSegue(withIdentifier: "LoadDictionarySegue", sender: data)
                } else {
                    self.presentCreateOrLoadView(dictionaryList: dictionaryList)
                }
            } else {
                self.presentCreateOrLoadView(dictionaryList: dictionaryList)
            }
        }
    }
    
    private func launch(isNetworkAvailable: Bool){
        
        getAppDelegate().applicationDefaults = LocalApplicationDefaults()
        
        let service: WebService
        
        //TODO: Use this to decide which services implementation to use
        if isTestMode() {
            print("Mock iCloud mode - For UI Testing")
            if getAppDelegate().webService != nil {
                service = getAppDelegate().webService
            } else {
                service = UiTestWebService()
            }
        } else {
            print("iCloud mode")
            service = LocalCloudKitWebService(isNetworkAvailable: isNetworkAvailable)
            //        let service = CloudKitWebService()
            //        let service = DemoWebService()
        }
        
        service.initialize(callback: postInitCallback(service))
        
    }
    
    private func presentCreateOrLoadView(dictionaryList: [UserDictionary]) {
        //decide where to go and segue
        if dictionaryList.count > 0 {
            //Got some
            self.performSegue(withIdentifier: "DictionarySelectionSegue", sender: dictionaryList)
            //TODO!  Check app defaults, if they have them, segue to home!
            
        } else {
            //Got none
            self.performSegue(withIdentifier: "DictionaryCreationSegue", sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let to = segue.destination as? DictionarySelectionViewController {
            to.transitioningDelegate = self
            guard let list = sender as? [UserDictionary] else { fatalError() }
            to.initialize(dictionaryList: list)
        } else if let to = segue.destination as? DictionaryLoadingViewController {
            guard let data = sender as? Data else { fatalError() }
            to.transitioningDelegate = self
            to.initialize(data: data)
        }
    }
}

extension NewAppLaunchViewController: EnfocaDefaultAnimatorTarget {
    func getRightNavView() -> UIView? {
        return activityIndicator
    }
    func getTitleView() -> UIView {
        return titleLabel
    }
    
    func additionalComponentsToHide() -> [UIView] {
        return [lighrraysImageView]
    }
    func getBodyContentView() -> UIView {
        return bodyView
    }
}
extension NewAppLaunchViewController: UIViewControllerTransitioningDelegate {
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        animator.presenting = true
        return animator
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        animator.presenting = false
        return animator
    }
}
