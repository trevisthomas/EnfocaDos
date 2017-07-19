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
    
    fileprivate var animator = EnfocaDefaultAnimator()
    
    private(set) var dictionaryList: [UserDictionary]?
    private var autoload: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        launch()
    }

    func initialize(autoload: Bool = true) {
        self.autoload = autoload
    }
    
    private func launch(){
        
        getAppDelegate().applicationDefaults = LocalApplicationDefaults()
        
        let service: WebService
        
        //TODO: Use this to decide which services implementation to use
        if isTestMode() {
            print("We're in test mode")
            service = UiTestWebService()
        } else {
            print("Production")
            service = LocalCloudKitWebService()
            //        let service = CloudKitWebService()
            //        let service = DemoWebService()
        }
        
        
        service.initialize { (dictionaryList: [UserDictionary]?, error: EnfocaError?) in
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
        return []
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
