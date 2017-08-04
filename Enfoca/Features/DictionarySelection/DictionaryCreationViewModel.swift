//
//  DictionaryCreationViewModel.swift
//  Enfoca
//
//  Created by Trevis Thomas on 6/26/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import Foundation


protocol DictionaryCreationViewModelDelegate {
    func refresh()
    func onError(title: String, message: EnfocaError)
}

class DictionaryCreationViewModel: Controller {
    private let delegate: DictionaryCreationViewModelDelegate!
    
    private(set) var dictionaryList: [String] = []
    
    let dictionaryOtherTitle = "Other"
    let dictionaryOther = UserDictionary(termTitle: "Term", definitionTitle: "Definition", subject: "My Flash Cards")
    
    init(delegate: DictionaryCreationViewModelDelegate) {
        self.delegate = delegate
        
        dictionaryList.removeAll()
        
        dictionaryList.append("Study a Foreign Language")
        dictionaryList.append(dictionaryOtherTitle)
        
        
    }
    
    func onEvent(event: Event) {
        
    }
    
    func isLanguageChoiceNeeded(forDictionary: UserDictionary) -> Bool {
        return forDictionary !== dictionaryOther
    }
}
