//
//  Language.swift
//  Enfoca
//
//  Created by Trevis Thomas on 7/10/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import Foundation

class Language {
    
    static let languages = [
        Language("English", "en"),
        Language("French", "fr"),
        Language("Spanish", "es"),
        Language("Chinese (Simplified)", "zh-Hans"),
        Language("Chinese (Traditional)", "zh-Hant")
    ]
    
    let name: String!
    let code: String!
    
    init(_ name: String, _ code: String) {
        self.name = name
        self.code = code 
    }
}
