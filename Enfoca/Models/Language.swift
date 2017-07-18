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
        Language("Chinese (Traditional)", "zh-Hant"),
        Language("Portuguese", "pt"),
        
        Language("Italian", "it"),
        Language("German", "de"),
        
        Language("Dutch","nl"),
        Language("Japanese", "ja"),
        Language("Korean", "ko"),
        Language("Vietnamese", "vi"),
        Language("Russian", "ru"),
        Language("Swedish", "sv"),
        Language("Danish", "da"),
        Language("Finnish", "fi"),
        Language("Norwegian (Bokmal)", "nb"),
        Language("Turkish", "tr"),
        Language("Greek", "el"),
        Language("Indonesian", "id"),
        Language("Malay", "ms"),
        Language("Thai", "th"),
        
    ]
    
    let name: String!
    let code: String!
    
    init(_ name: String, _ code: String) {
        self.name = name
        self.code = code 
    }
}
