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
    var dataStore: DataStore! {get}
    func save()
    func load()
}

class LocalApplicationDefaults : ApplicationDefaults {
    
    let dataStoreKey : String = "DataStoreKey"
    var selectedTags : [Tag] = []
    var reverseWordPair : Bool = false
    var dataStore: DataStore!
    
    var fetchWordPairPageSize: Int {
        get {
            return 100
        }
    }
    
    func save(){
        print("Saving user data")
        saveDataStore(dataStore)
    }
    
    func load(){
        dataStore = loadOrCreateDataStore()
        //        dataStore = DataStore()
    }
    
    private func saveDataStore(_ dataStore: DataStore){
        let defaults = UserDefaults.standard
        
        defaults.setValue(dataStore.toJson(), forKey: dataStoreKey)
    }
    
    private func loadOrCreateDataStore() -> DataStore {
        let defaults = UserDefaults.standard
        guard let json = defaults.value(forKey: dataStoreKey) as? String else { return DataStore() }
        
        //In case of a dirty shut down, i dont want the old data lying around
        defaults.removeObject(forKey: dataStoreKey)
        
        let ds = DataStore()
        ds.initialize(json: json)
        return ds
    }
}
