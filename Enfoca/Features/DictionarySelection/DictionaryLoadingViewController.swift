//
//  DictionaryLoadingViewController.swift
//  Enfoca
//
//  Created by Trevis Thomas on 6/27/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import UIKit

class DictionaryLoadingViewController: UIViewController {

    
    //TODO: Delete the old HomeAnimator.  Rename this HomeFromQuiz to something else.
    
    
//    @IBOutlet weak var titleLabel: UILabel!
//    @IBOutlet weak var messageStackView: UIStackView!
    @IBOutlet weak var headerView: UIView!
    fileprivate var dictionary: UserDictionary!
    
    fileprivate var progressLabels : [String: UILabel] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        launch()
    }
    
    func initialize(dictionary: UserDictionary) {
        self.dictionary = dictionary
    }
    
    private func launch(){
        
        startProgress(ofType: "Initializing", message: "Loading app defaults")
        
//        getAppDelegate().applicationDefaults = LocalApplicationDefaults()
//        
//        let service: WebService
//        
//        //TODO: Use this to decide which services implementation to use
//        if isTestMode() {
//            print("We're in test mode")
//            service = UiTestWebService()
//        } else {
//            print("Production")
//            service = LocalCloudKitWebService()
//            //        let service = CloudKitWebService()
//            //        let service = DemoWebService()
//        }
        
        let dataStoreJson = getAppDelegate().applicationDefaults.load()
        
        //TODO: The dictionary needs to be saved in AppDefaults!!!
//
        getAppDelegate().webService.initialize(dictionary: dictionary, json: dataStoreJson, progressObserver: self) { (success :Bool, error : EnfocaError?) in
            
            if let error = error {
                self.presentFatalAlert(title: "Initialization error", message: error)
            } else {
                self.performSegue(withIdentifier: "HomeSegue", sender: self)
            }
            
            self.endProgress(ofType: "Initializing", message: "Initialization complete.")

        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        segue.destination.transitioningDelegate = self
    }
}

extension DictionaryLoadingViewController : ProgressObserver {
    func startProgress(ofType key : String, message: String){
        print("Starting: \(key) : \(message)")
        
//        invokeLater {
//            let label = UILabel()
//            
//            label.text = message
//            self.progressLabels[key] = label
//            self.messageStackView.addArrangedSubview(label)
//            self.messageStackView.translatesAutoresizingMaskIntoConstraints = false;
//        }
    }
    func updateProgress(ofType key : String, message: String){
//        invokeLater {
//            guard let label = self.progressLabels[key] else { return }
//            label.text = message
//        }
    }
    func endProgress(ofType key : String, message: String) {
//        print("Ending: \(key) : \(message)")
//        invokeLater {
//            guard let label = self.progressLabels[key] else { return }
//            label.text = nil
//            self.messageStackView.removeArrangedSubview(label)
//            self.progressLabels[key] = nil
//            
//        }
    }
}

extension DictionaryLoadingViewController: UIViewControllerTransitioningDelegate {
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        guard let _ = presented as? HomeViewController, let _ = source as? DictionaryLoadingViewController else {
            fatalError()
        }
        
        return HomeFromQuizResultAnimator()
    }
}

extension DictionaryLoadingViewController: HomeFromQuizAnimatorTarget {
    func getHeaderHeight() -> CGFloat {
        return headerView.frame.height
    }
}

