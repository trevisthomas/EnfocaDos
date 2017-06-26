//
//  DictionarySelectionViewModel.swift
//  Enfoca
//
//  Created by Trevis Thomas on 6/26/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import Foundation

protocol DictionarySelectionViewModelDelegate {
    func refresh()
    func onError(title: String, message: EnfocaError)
}


class DictionarySelectionViewModel: Controller {
    private(set) var dictionaryList: [Dictionary] = []
    private var delegate: DictionarySelectionViewModelDelegate
    
    init(delegate: DictionarySelectionViewModelDelegate) {
        self.delegate = delegate
    }
    
    func fetchDictionaries(callback: @escaping ()->() = {}){
        services.fetchDictionaryList { (dictionaryList: [Dictionary]?, error: EnfocaError?) in
            if let error = error {
                self.delegate.onError(title: "Failed to load dictionary list", message: error)
            }
            
            guard let dictionaryList = dictionaryList else { return }
            
            self.dictionaryList.removeAll()
            self.dictionaryList.append(contentsOf: dictionaryList)
            
            self.delegate.refresh()
            
            callback()
        }
    }
    
    func onEvent(event: Event) {
        //
    }
    
    
}
