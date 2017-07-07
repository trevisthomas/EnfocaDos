//
//  NewAppLaunchViewController.swift
//  Enfoca
//
//  Created by Trevis Thomas on 6/26/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import UIKit

class NewAppLaunchViewController: UIViewController {

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
                if let json = getAppDelegate().applicationDefaults.load() {
                    self.performSegue(withIdentifier: "LoadDictionarySegue", sender: json)
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
            
            guard let list = sender as? [UserDictionary] else { fatalError() }
            to.initialize(dictionaryList: list)
        } else if let to = segue.destination as? DictionaryLoadingViewController {
            guard let json = sender as? String else { fatalError() }
            to.initialize(json: json)
        }
    }
}
