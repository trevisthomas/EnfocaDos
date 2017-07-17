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
    
    private(set) var dictionaryList: [UserDictionary] = []
    
    private let dictionaryOther = UserDictionary(termTitle: "Front", definitionTitle: "Back", subject: "Other")
    
    init(delegate: DictionaryCreationViewModelDelegate) {
        self.delegate = delegate
        
        dictionaryList.removeAll()
        
        dictionaryList.append(UserDictionary(termTitle: "Spanish", definitionTitle: "English", subject: "Spanish Vocabulary", language: "es"))
        
        dictionaryList.append(UserDictionary(termTitle: "French", definitionTitle: "English", subject: "French Vocabulary", language: "fr"))
        
        dictionaryList.append(UserDictionary(termTitle: "English", definitionTitle: "English", subject: "English Vocabulary", language: "en"))
        
        dictionaryList.append(UserDictionary(termTitle: "Foreign", definitionTitle: "Native", subject: "Another Language"))
        
        dictionaryList.append(dictionaryOther)
    }
    
    func onEvent(event: Event) {
        
    }
    
    func isLanguageChoiceNeeded(forDictionary: UserDictionary) -> Bool {
        return forDictionary !== dictionaryOther
    }
}
