//
//  WordPairEditorController.swift
//  Enfoca
//
//  Created by Trevis Thomas on 5/29/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import UIKit

protocol EditWordPairControllerDelegate {
    func onTagsLoaded()
    func onError(title: String, message: EnfocaError)
    func onUpdate()
    func dismissViewController()
}

class EditWordPairController: Controller {
    //TODO: Shouln't these be weak?
    private let delegate: EditWordPairControllerDelegate
    
    var selectedTags: [Tag] = []
//    {
//        didSet{
//            delegate.onUpdate()
//        }
//    }
    var word: String = ""
    var definition: String = ""
    private(set) var isEditMode: Bool
    
    private var originalWordPair: WordPair?
    private var originalMetaData: MetaData?
    
    var mostRecentlyUsedTags: [Tag] {
        get {
            return appDefaults.getMostRecentlyUsedTags()
        }
    }
    
    init(delegate: EditWordPairControllerDelegate, wordPairOrder order: WordPairOrder, text: String) {
        
        self.delegate = delegate
        isEditMode = false
        originalWordPair =  nil
        
        switch(order) {
        case .definitionAsc, .definitionDesc:
            self.definition = text
        case .wordAsc, .wordDesc:
            self.word = text
        }
        
//        setupMruTags()
        
    }
    
//    private func setupMruTags(){
//        mostRecentlyUsedTags = []
//        mostRecentlyUsedTags.append(contentsOf: appDefaults.getMostRecentlyUsedTags())
//    }
    
    init(delegate: EditWordPairControllerDelegate, wordPair: WordPair) {
        self.delegate = delegate
        isEditMode = true
        loadOriginalWordPair(sourceWordPair: wordPair)
        
//        setupMruTags()
    }
    
    private func loadOriginalWordPair(sourceWordPair: WordPair) {
        self.originalWordPair = sourceWordPair
        selectedTags.removeAll()
        selectedTags.append(contentsOf: sourceWordPair.tags)
        word = sourceWordPair.word
        definition = sourceWordPair.definition

    }
    
    func initialize(callback: @escaping()->() = {}){
        
        services.isDataStoreSynchronized { (isSynched: Bool?, error: String?) in
            guard let isSynched = isSynched else { fatalError("Fatal error while attempting to check conch state.") }
            
            if isSynched {
                self.performInitialize(callback: callback)
            } else {
                self.performRefreshInitialize(callback: callback)
            }
        }
    }
    
    func performInitialize(callback: @escaping()->()) {
        services.fetchUserTags { (tags: [Tag]?, error: EnfocaError?) in
            callback()
            if let error = error {
                self.delegate.onError(title: "Error fetching tags", message: error)
            }
            guard let _ = tags else { return }
            self.delegate.onTagsLoaded()
        }
        
        if let wp = originalWordPair {
            services.fetchMetaData(forWordPair: wp, callback: { (metaData: MetaData?, error:EnfocaError?) in
                callback()
                if let error = error {
                    self.delegate.onError(title: "Failed to load meta data", message: error)
                }
                self.originalMetaData = metaData
                self.delegate.onUpdate()
//                self.delegate.onTagsLoaded()
            })
        }

    }
    
    func performRefreshInitialize(callback: @escaping()->()) {
        
        services.reloadTags { (tags:[Tag]?, error:EnfocaError?) in
            if let error = error {
                callback()
                self.delegate.onError(title: "Error fetching tags", message: error)
            }
            guard let _ = tags else {
                callback()
                return
            }
            
            self.delegate.onTagsLoaded()
            
            if let wp = self.originalWordPair {
                self.services.reloadWordPair(sourceWordPair: wp, callback: { (tuple: (WordPair, MetaData?)?, error: EnfocaError?) in
                    callback()
                    if let error = error {
                        self.delegate.onError(title: "Failed to reload word pair", message: error)
                        
                    }
                    
                    guard let tuple = tuple else { fatalError() }
                    let reloadedWp = tuple.0
                    self.originalMetaData = tuple.1
                    
                    self.loadOriginalWordPair(sourceWordPair: reloadedWp)
                    
                    self.delegate.onUpdate()
                })
            }
        }
    }
    
    func title()->String{
        if isEditMode {
            return "Edit"
        } else {
            return "Create"
        }
    }
    
    func addTag(tag: Tag) {
        selectedTags.append(tag)
        selectedTags.sort { (t1:Tag, t2:Tag) -> Bool in
            return t1.name.lowercased() < t2.name.lowercased()
        }
        delegate.onUpdate()
    }
    
    
    
    func removeTag(tag: Tag) {
        if let index = selectedTags.index(of: tag) {
            selectedTags.remove(at: index)
        }
        delegate.onUpdate()
    }
    
    func tagsAsString() -> String {
        
        if selectedTags.count == 0 {
            return "tap here to choose tags"
        } else {
            return selectedTags.tagsToText()
        }
    }
    
    func onEvent(event: Event) {
        
        
        switch (event.type) {
        case .tagCreated, .tagUpdate, .tagDeleted:
                initialize()
        default: break
        }
    }
    
    func isValidForSaveOrCreate() -> Bool {
        
        if isEditMode {
            guard let originalWordPair = originalWordPair else { return false }
            if originalWordPair.word != word || originalWordPair.definition != definition || originalWordPair.tags != selectedTags {
                return true
            }
        } else {
            return !isTextFieldInvalid()
        }
        
        return false
        
    }
    
    func isValidForDelete() -> Bool {
        guard let _ = originalWordPair else { return false }
        return true
    }
    
    func performDelete(callback: @escaping (EnfocaError?)->()) {
        guard let originalWordPair = originalWordPair else {
            callback("Failed to delete.  The editor is not configured for delete.")
            return
        }
        
        services.deleteWordPair(wordPair: originalWordPair) { (wordPair: WordPair?, error: EnfocaError?) in
            
            
            if let error = error {
                callback(error)
                self.delegate.onError(title: "Update failed", message: error)
                return
            }
            
            guard let wordPair = wordPair else { return }
            
            self.fireEvent(source: self, event: Event(type: .wordPairDeleted, data: wordPair))
            callback(nil)
            
        }
    }
    
    func performSaveOrCreate(handleFailedValidation: @escaping (WordPair)->(), callback: @escaping (EnfocaError?)->()) {
        
        //Dont perform this validation on update.  The terms can match then!
        if isEditMode {
            self.performWordPairAction(callback: callback)
            return
        }
        
        fetchExatctMatchesForTerm(callback: { (matchingTerms: [WordPair]) in
            if matchingTerms.count > 0 {
                handleFailedValidation(matchingTerms[0])
                return
            } else {
                //Perform WP action
                self.performWordPairAction(callback: callback)
            }
        })

    }
    
    //This method was added to allow the VC to choose to switch to edit mode when the user has an exact match during edit.
    func switchToWordPair(wordPair: WordPair, callback: @escaping()->()) {
        isEditMode = true
        loadOriginalWordPair(sourceWordPair: wordPair)
        initialize(callback: callback)
    }
    
    private func performWordPairAction(callback: @escaping (EnfocaError?)->()) {
        if isEditMode {
            if isTextFieldInvalid() {
                //                self.delegate.onError(title: "Update failed", message: "Invalid content in word or definition")
                //                return
            }
            
            guard let originalWordPair = originalWordPair else { fatalError() }
            services.updateWordPair(oldWordPair: originalWordPair, word: word, definition: definition, gender: .notset, example: nil, tags: selectedTags) { (wordPair:WordPair?, error:EnfocaError?) in
                
                
                if let error = error {
                    callback(error)
                    self.delegate.onError(title: "Update failed", message: error)
                }
                
                guard let wordPair = wordPair else { return }
                
                originalWordPair.applyUpdate(source: wordPair)
                
                callback(nil)
                self.fireEvent(source: self, event: Event(type: .wordPairUpdated, data: wordPair))
                
            }
        } else {
            
            if isTextFieldInvalid() {
                self.delegate.onError(title: "Create failed", message: "Invalid content in word or definition")
                return
            }
            
            services.createWordPair(word: word, definition: definition, tags: selectedTags, gender: .notset, example: nil, callback: { (wordPair: WordPair?, error: EnfocaError?) in
                
                if let error = error {
                    callback(error)
                    self.delegate.onError(title: "Create failed", message: error)
                }
                
                guard let wordPair = wordPair else { return }
                
                self.fireEvent(source: self, event: Event(type: .wordPairCreated, data: wordPair))
                callback(nil)
                
            })
        }
    }
    
    //Duplicate terms are not allowed. 
    public func fetchExatctMatchesForTerm( callback:@escaping([WordPair])->() ) {
        let pattern = "^\(word.trim())$"
        services.fetchWordPairs(tagFilter: [], wordPairOrder: .wordDesc, pattern: pattern) { (wordPairs: [WordPair]?, error: EnfocaError?) in
            if let error = error {
                self.delegate.onError(title: "Create failed", message: error)
                return
            }
            
            guard let matches = wordPairs else { fatalError() }
            
            callback(matches)
        }
    }
    
    private func isTextFieldInvalid() -> Bool {
        return word.trim().isEmpty || definition.trim().isEmpty
    }
    
    func getDateAdded() -> String {
        guard let dateCreated = originalWordPair?.dateCreated else { return "new"}
        return toDateString(dateCreated)
    }
    func getDateUpdated() -> String{
        guard let dateUpdated = originalMetaData?.dateUpdated else { return "never"}
        return toDateString(dateUpdated)
    }
    func getScore() -> String{
        guard let score = originalMetaData?.scoreAsString else { return "--%"}
        return score
    }
    
    func getAverageTime()->String {
        guard let meta = originalMetaData else { return "..."}
        
        return String(format: "%.1f seconds.", (Double(meta.totalTime)/Double(meta.timedViewCount)) / 1000.0)
        
    }
    func getCount() -> String{
        guard let metaData = originalMetaData else { return "none"}
        
        return "\(metaData.timedViewCount)"
    }
    
    func applyTag(_ tag: Tag) {
        
        appDefaults.insertMostRecentTag(tag: tag)
        
        if !selectedTags.contains(tag) {
            selectedTags.append(tag)
            delegate.onUpdate()
        } else {
            guard let index = selectedTags.index(of: tag) else { return }
            selectedTags.remove(at: index)
            delegate.onUpdate()
        }
        
    }
    
    func toDateString(_ date: Date) -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter.string(from: date)
    }
    
}

