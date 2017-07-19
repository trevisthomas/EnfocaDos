//
//  DictionaryLoadingViewController.swift
//  Enfoca
//
//  Created by Trevis Thomas on 6/27/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import UIKit

class DictionaryLoadingViewController: UIViewController {

    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var associationProgressBar: ProgressBarView!
    @IBOutlet weak var tagProgressBar: ProgressBarView!
    @IBOutlet weak var wordPairProgressBar: ProgressBarView!
    @IBOutlet weak var metaProgressBar: ProgressBarView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIView!
    @IBOutlet weak var bodyView: UIView!
    
    fileprivate var dictionary: UserDictionary?
    fileprivate var dataStoreData: DataStore?
    fileprivate var progressBars:[String: ProgressBarView] = [:]
    fileprivate var progressLabels : [String: UILabel] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Note! The order here is the order that they are in the UI.  It matters for the animation
        
        progressBars[OperationFetchTags.key] = tagProgressBar
        progressBars[OperationFetchMetaData.key] = metaProgressBar
        progressBars[OperationFetchWordPairs.key] = wordPairProgressBar
        progressBars[OperationFetchTagAssociations.key] = associationProgressBar
        
        
        associationProgressBar.alpha = 0
        tagProgressBar.alpha = 0
        wordPairProgressBar.alpha = 0
        metaProgressBar.alpha = 0
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        launch()
        
    }
    
    //this one is used when a dict is selected by user
    func initialize(dictionary: UserDictionary) {
        self.dictionary = dictionary
    }
    
    //This is used when the json is loaded from the disk automatically
    func initialize(data: Data) {
        let dataStore = extractDataStore(from: data)
        
        let dict = dataStore.getUserDictionary()
        getAppDelegate().applicationDefaults.removeDictionary(dict)
        self.dataStoreData = dataStore
    }
    
    private func launch(){
        
//        startProgress(ofType: "Initializing", message: "Loading app defaults")
        
        messageLabel.text = "Initializing..."
        
        if let dictionary = dictionary {
            if let data = getAppDelegate().applicationDefaults.loadDataStore(forDictionaryId: dictionary.dictionaryId) {
                
                getAppDelegate().applicationDefaults.removeDictionary(dictionary) //Since i have the dictId i'm removing the thing as soon as i can.  Before extract even touches it.
                let dataStore = extractDataStore(from: data)
                messageLabel.text = "Loading local cache..."
                
                conchPreCheckPrepareDataStore(dataStore: dataStore)
            } else {
                // user selected a dictionary that wasnt in their local disk cache
                
                //fetchCurrentConch and apply it to the dictionary
                
                messageLabel.text = "Loading from iCloud..."
                progressBarVisibilities(true)
                getAppDelegate().webService.fetchCurrentConch(dictionary: dictionary, callback: { (conch: String?, error: String?) in
                    if let error = error {
                        self.presentFatalAlert(title: "Initialization error", message: error)
                    } else {
                        guard let conch = conch else { fatalError() }
                        dictionary.conch = conch
                        self.prepareDataStore()
                    }
                })
            }
        } else {
            messageLabel.text = "Loading local cache..."
            
            // no dictionary was selected by the user, we're doing a json auto init
            guard let dataStore = dataStoreData else { fatalError("dataStoreData is nil some how") }
            conchPreCheckPrepareDataStore(dataStore: dataStore)
        }
    }
    
    private func progressBarVisibilities(_ isVisible: Bool) {
        
        var count = 0
        for bar in progressBars.values {
            bar.alpha = 0.0
            
            if isVisible {
                CustomAnimations.animatePopIn(target: bar, delay: 0.1 * Double(count) , duration: 0.33)
            }
            count += 1
        }
        
        
    }
    
    private func conchPreCheckPrepareDataStore(dataStore: DataStore) {
        let oldDict = dataStore.getUserDictionary()
        
        getAppDelegate().webService.isDataStoreSynchronized(dictionary: oldDict, callback: { (isSynched:Bool?, error: String?) in
            
            if isSynched ?? false {
                self.dataStoreData = dataStore //Try to use the json
                self.prepareDataStore()
            } else {
                self.dataStoreData = nil  //json is out of synch, dump it
                
                //fetchCurrentConch and apply it to the dictionary
                getAppDelegate().webService.fetchCurrentConch(dictionary: oldDict, callback: { (conch: String?, error: String?) in
                    if let error = error {
                        self.presentFatalAlert(title: "Initialization error", message: error)
                        return
                    }
                    guard let conch = conch else { fatalError() }
                    oldDict.conch = conch
                    self.dictionary = oldDict
                    self.prepareDataStore()
                })
            }
        })
    }
    
    private func extractDataStore(from data: Data) -> DataStore {
        guard let oldDataStore = NSKeyedUnarchiver.unarchiveObject(with: data) as? DataStore else { fatalError("Corrupt local archive data for datastore.") }
        
        return oldDataStore
        
    }
    private func prepareDataStore(){
        
        //Delete the dictionary from cache prior to load
        if let d = dictionary {
            getAppDelegate().applicationDefaults.removeDictionary(d)
        } else if let dataStore = dataStoreData {
            let _ = dataStore.getUserDictionary()
        }
        
        getAppDelegate().webService.prepareDataStore(dictionary: dictionary, dataStore: dataStoreData, progressObserver: self) { (success :Bool, error : EnfocaError?) in
            
            if let error = error {
                self.presentFatalAlert(title: "Initialization error", message: error)
            } else {
//                self.endProgress(ofType: "Initializing", message: "Initialization complete.")
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
    func startProgress(ofType key : String, message: String, size: Int){
        invokeLater {
            if size == 0 {
                self.progressBars[key]?.initialize(max: 1)
                self.progressBars[key]?.updateProgress(current: 1)
            } else {
                self.progressBars[key]?.initialize(max: size)
            }
        }
    }
    func updateProgress(ofType key : String, message: String, count: Int){
        invokeLater {
            self.progressBars[key]?.updateProgress(current: count)
        }
    }
    func endProgress(ofType key : String, message: String, total: Int) {
        invokeLater {
            self.progressBars.removeValue(forKey: key)
            
            if self.progressBars.isEmpty {
                self.messageLabel.text = "Indexing data store..."
            }
        }
        
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

extension DictionaryLoadingViewController: EnfocaDefaultAnimatorTarget {
    func getRightNavView() -> UIView? {
        return activityIndicator
    }
    func getTitleView() -> UIView {
        return titleLabel
    }
    
    func additionalComponentsToHide() -> [UIView] {
        return [messageLabel]
    }
    func getBodyContentView() -> UIView {
        return bodyView
    }
}


