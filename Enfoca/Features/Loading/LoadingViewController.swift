//
//  LoadingViewController.swift
//  Enfoca
//
//  Created by Trevis Thomas on 5/14/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import UIKit

class LoadingViewController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    fileprivate var progressLabels : [String: UILabel] = [:]
    @IBOutlet weak var messageStackView: UIStackView!
    @IBOutlet weak var darkGrayHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let originalHeight = darkGrayHeightConstraint.constant
        darkGrayHeightConstraint.constant = view.frame.height
        self.view.layoutIfNeeded()
        
        //lol, i had to get off of the thread to allow the initial conditions to be applied and then start the animation.  Mainly this was so that IB could show the final state.
        invokeLater {
            self.darkGrayHeightConstraint.constant = originalHeight
            
            UIView.animate(withDuration: 0.66, delay: 0.2, options: [.curveEaseOut], animations: {
                self.view.layoutIfNeeded()
            }) { (_) in
                //Done
            }
        }
        
        initialize()
    }
    
    private func initialize(){
        
        startProgress(ofType: "Initializing", message: "Loading app defaults")
        
        getAppDelegate().applicationDefaults = LocalApplicationDefaults()
        let dataStoreJson = getAppDelegate().applicationDefaults.load()
        
        //TODO: Use this to decide which services implementation to use
        if isTestMode() {
            print("We're in test mode")
        } else {
            print("Production")
        }
        
        let service = LocalCloudKitWebService()
        //        let service = CloudKitWebService()
        //        let service = DemoWebService()
        service.initialize(json: dataStoreJson, progressObserver: self) { (success :Bool, error : EnfocaError?) in
            
            if let error = error {
                self.presentFatalAlert(title: "Initialization error", message: error)
            } else {
                getAppDelegate().webService = service
                self.performSegue(withIdentifier: "Home", sender: self)
                
                
            }
            
            self.endProgress(ofType: "Initializing", message: "Initialization complete.")
            
            //            //DELETE ALL
            //            Perform.deleteAllRecords(dataStore: getAppDelegate().applicationDefaults.dataStore, enfocaId: service.enfocaId, db: service.db)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        segue.destination.transitioningDelegate = self
    }
    
    private func isTestMode() -> Bool{
        if ProcessInfo.processInfo.arguments.contains("UITest") {
            return true;
        } else {
            return false;
        }
    }
}

extension LoadingViewController : ProgressObserver {
    func startProgress(ofType key : String, message: String){
        print("Starting: \(key) : \(message)")
        
        invokeLater {
            let label = UILabel()
            
            label.text = message
            self.progressLabels[key] = label
            self.messageStackView.addArrangedSubview(label)
            self.messageStackView.translatesAutoresizingMaskIntoConstraints = false;
        }
    }
    func updateProgress(ofType key : String, message: String){
        invokeLater {
            guard let label = self.progressLabels[key] else { return }
            label.text = message
        }
    }
    func endProgress(ofType key : String, message: String) {
        print("Ending: \(key) : \(message)")
        invokeLater {
            guard let label = self.progressLabels[key] else { return }
            label.text = nil
            self.messageStackView.removeArrangedSubview(label)
            self.progressLabels[key] = nil
            
        }
    }
}

extension LoadingViewController: UIViewControllerTransitioningDelegate {
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        guard let _ = presented as? HomeViewController, let _ = source as? LoadingViewController else {
            fatalError()
        }
        
        return HomeFromLoadingAnimator()
    }
}


