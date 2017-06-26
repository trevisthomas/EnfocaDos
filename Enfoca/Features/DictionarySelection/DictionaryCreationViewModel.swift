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
    
    private(set) var dictionaryList: [Dictionary] = []
    
    init(delegate: DictionaryCreationViewModelDelegate) {
        self.delegate = delegate
        
        dictionaryList.removeAll()
        
        dictionaryList.append(Dictionary(termTitle: "Spanish", definitionTitle: "English", subject: "Spanish Vocabulary", language: "es"))
        
        dictionaryList.append(Dictionary(termTitle: "French", definitionTitle: "English", subject: "French Vocabulary", language: "fr"))
        
        dictionaryList.append(Dictionary(termTitle: "English", definitionTitle: "English", subject: "English Vocabulary", language: "en"))
        
        dictionaryList.append(Dictionary(termTitle: "Foreign", definitionTitle: "Native", subject: "Another Language"))
        
        dictionaryList.append(Dictionary(termTitle: "Front", definitionTitle: "Back", subject: "Other"))
    }
    
    
    func onEvent(event: Event) {
        
    }
}
