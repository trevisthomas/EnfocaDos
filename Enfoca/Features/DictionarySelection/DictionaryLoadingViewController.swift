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
    fileprivate var dictionary: UserDictionary?
    fileprivate var dataStoreJson: String?
    
    fileprivate var progressLabels : [String: UILabel] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        launch()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        launch()
    }
    
    //this one is used when a dict is selected by user
    func initialize(dictionary: UserDictionary) {
        self.dictionary = dictionary
    }
    
    //This is used when the json is loaded from the disk automatically
    func initialize(json: String) {
        self.dataStoreJson = json
    }
    
    private func launch(){
        
//        startProgress(ofType: "Initializing", message: "Loading app defaults")
        
        if let dictionary = dictionary {
            if let json = getAppDelegate().applicationDefaults.loadDataStore(forDictionaryId: dictionary.dictionaryId) {
                
                conchPreCheckPrepareDataStore(json: json)
//                //conch check
//                let oldDict = DataStore.extractDictionary(fromJson: json)
//                
//                getAppDelegate().webService.isDataStoreSynchronized(dictionary: oldDict, callback: { (isSynched:Bool?, error: String?) in
//                    
//                    if isSynched ?? false {
//                        self.dataStoreJson = json
//                    } else {
//                        self.dataStoreJson = nil
//                    }
//                    self.prepareDataStore()
//                })
            } else {
                // user selected a dictionary that wasnt in their local disk cache
                self.prepareDataStore()
            }
        } else {
            // no dictionary was selected by the user, we're doing a json auto init
            guard let json = dataStoreJson else { fatalError() }
            conchPreCheckPrepareDataStore(json: json)
        }
    }
    
    private func conchPreCheckPrepareDataStore(json: String) {
        let oldDict = DataStore.extractDictionary(fromJson: json)
        
        getAppDelegate().webService.isDataStoreSynchronized(dictionary: oldDict, callback: { (isSynched:Bool?, error: String?) in
            
            if isSynched ?? false {
                self.dataStoreJson = json
            } else {
                self.dataStoreJson = nil
                self.dictionary = oldDict
            }
            self.prepareDataStore()
        })

    }
    
    private func prepareDataStore(){
        getAppDelegate().webService.prepareDataStore(dictionary: dictionary, json: dataStoreJson, progressObserver: self) { (success :Bool, error : EnfocaError?) in
            
            if let error = error {
                self.presentFatalAlert(title: "Initialization error", message: error)
            } else {
                self.endProgress(ofType: "Initializing", message: "Initialization complete.")
                //Save after successful load.
                getAppDelegate().saveDefaults()
                invokeLater {
                    self.performSegue(withIdentifier: "HomeSegue", sender: self)
                }
            }
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
        
        guard let _ = presented as? ModularHomeViewController, let _ = source as? DictionaryLoadingViewController else {
//            fatalError()
            return nil
        }
        
        return HomeFromQuizResultAnimator()
        
    }
}

extension DictionaryLoadingViewController: HomeFromQuizAnimatorTarget {
    func getHeaderHeight() -> CGFloat {
        return headerView.frame.height
    }
}

