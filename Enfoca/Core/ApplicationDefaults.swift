//
//  ApplicationDefaults.swift
//  Enfoca
//
//  Created by Trevis Thomas on 12/31/16.
//  Copyright © 2016 Trevis Thomas. All rights reserved.
//

import Foundation

protocol ApplicationDefaults {
    var reverseWordPair : Bool {get set}
    var selectedTags : [Tag] {get set}
    var fetchWordPairPageSize : Int {get}
    func save(includingDataStore json: String?)
    func load() -> String?
}

class LocalApplicationDefaults : ApplicationDefaults {
    
    let dataStoreKey : String = "DataStoreKey"
    var selectedTags : [Tag] = []
    var reverseWordPair : Bool = false
    
    var fetchWordPairPageSize: Int {
        get {
            return 100
        }
    }
    
    func save(includingDataStore json: String?){
        if isTestMode() {
            print("Not saving user defaults.  We're in test mode")
            return
        }
        
        print("Saving user data")
        
        let defaults = UserDefaults.standard
        
        if let json = json {
            defaults.setValue(json, forKey: dataStoreKey)
        }
    }
    
    func load() -> String? {
        
        if isTestMode() {
            print("Not loading user defaults.  We're in test mode")
            return nil
        }
        
        let defaults = UserDefaults.standard
        let json = defaults.value(forKey: dataStoreKey) as? String
        
        
        //In case of a dirty shut down, i dont want the old data lying around
//        defaults.removeObject(forKey: dataStoreKey)

        
        //Load other default settings
        
        return json
    }
    
}
