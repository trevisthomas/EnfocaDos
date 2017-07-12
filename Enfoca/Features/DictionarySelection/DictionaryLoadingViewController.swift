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
    fileprivate var dictionary: UserDictionary?
    fileprivate var dataStoreData: DataStore?
    
    fileprivate var progressLabels : [String: UILabel] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        
        if let dictionary = dictionary {
            if let data = getAppDelegate().applicationDefaults.loadDataStore(forDictionaryId: dictionary.dictionaryId) {
                
                getAppDelegate().applicationDefaults.removeDictionary(dictionary) //Since i have the dictId i'm removing the thing as soon as i can.  Before extract even touches it.
                let dataStore = extractDataStore(from: data)
                conchPreCheckPrepareDataStore(dataStore: dataStore)
            } else {
                // user selected a dictionary that wasnt in their local disk cache
                
                //fetchCurrentConch and apply it to the dictionary
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
            // no dictionary was selected by the user, we're doing a json auto init
            guard let dataStore = dataStoreData else { fatalError() }
            conchPreCheckPrepareDataStore(dataStore: dataStore)
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
            let d = dataStore.getUserDictionary()
        }
        
        getAppDelegate().webService.prepareDataStore(dictionary: dictionary, dataStore: dataStoreData, progressObserver: self) { (success :Bool, error : EnfocaError?) in
            
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

