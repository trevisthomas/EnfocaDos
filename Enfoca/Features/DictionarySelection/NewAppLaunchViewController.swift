//
//  NewAppLaunchViewController.swift
//  Enfoca
//
//  Created by Trevis Thomas on 6/26/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import UIKit

class NewAppLaunchViewController: UIViewController {

    private(set) var dictionaryList: [Dictionary]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        launch()
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
        
        service.fetchDictionaryList { (dictionaryList: [Dictionary]?, error: EnfocaError?) in
            if let error = error {
                self.presentFatalAlert(title: "Failed to initialize app", message: error)
            }
            
            getAppDelegate().webService = service
            
            //decide where to go and segue
            
            if let dictionaryList = dictionaryList, dictionaryList.count > 0 {
                //Got some
                self.performSegue(withIdentifier: "DictionarySelectionSegue", sender: dictionaryList)
                //TODO!  Check app defaults, if they have them, segue to home!
            } else {
                //Got none
                self.performSegue(withIdentifier: "DictionaryCreationSegue", sender: nil)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let to = segue.destination as? DictionarySelectionViewController {
            
            guard let list = sender as? [Dictionary] else { fatalError() }
            to.initialize(dictionaryList: list)
        }
    }
}
