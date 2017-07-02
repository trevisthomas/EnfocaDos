//
//  ConchLocalStorage.swift
//  Enfoca
//
//  Created by Trevis Thomas on 7/2/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import Foundation

class ConchLocalStorage {
    private static let key = "ConchKey"
    class func save(_ conch: String){
        let defaults = UserDefaults.standard
        
        defaults.setValue(conch, forKey: key)
    }
    
    class func load() -> String {
        let defaults = UserDefaults.standard
        guard let conch = defaults.value(forKey: key) as? String else { fatalError() }
        return conch
    }
}
