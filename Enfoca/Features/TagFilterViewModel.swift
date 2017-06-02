//
//  TagFilterViewModel.swift
//  Enfoca
//
//  Created by Trevis Thomas on 12/29/16.
//  Copyright © 2016 Trevis Thomas. All rights reserved.
//

import UIKit

class TagFilterViewModel : NSObject, UITableViewDataSource, UITableViewDelegate {
    var localTempTagFilters : [Tag] = []
    var localTagDictionary : [Tag: Bool] = [:]
//    private(set) var tagFilterDelegate : TagFilterViewControllerDelegate!
    var tagFilterViewModelDelegate : TagFilterViewModelDelegate?
    var allTags : [Tag] = []
    private var selectedTags: [Tag]
    
    init(selectedTags tags: [Tag]) {
        self.selectedTags = tags
    }
    
    func initialize(delegate: TagFilterViewModelDelegate, callback : @escaping()->()){
        tagFilterViewModelDelegate = delegate
        
        getAppDelegate().webService.fetchUserTags { (tags:[Tag]?, error : EnfocaError?) in
            
            
            guard let tags = tags else {
                self.tagFilterViewModelDelegate?.alert(title: "Error", message: error!)
                return
            }
            
            self.allTags = tags
            self.localTempTagFilters = tags
            
            for tag in self.localTempTagFilters {
                self.localTagDictionary[tag] = self.selectedTags.contains(tag)
            }
            
            callback()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return localTempTagFilters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TagFilterCell")! as! TagCell

        let tag = localTempTagFilters[indexPath.row]
        cell.sourceTag = tag        
        
        if let selected : Bool = localTagDictionary[tag] {
            cell.createTagCallback = nil
            if selected {
                tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            } else {
                tableView.deselectRow(at: indexPath, animated: false)
            }
        } else {
            cell.createTagCallback = createCallback
        }
        
        cell.tagUpdateDelegate = self //Should createCallBack just be merged into this?

        return cell
    }
    
    func createCallback(tagCell : TagCell, tagValue : String){
        tagCell.activityIndicator.startAnimating()
        getAppDelegate().webService.createTag(tagValue: tagValue) { (newTag: Tag?, error :EnfocaError?) in
            
            if let error = error {
                //Should probably refactor and put this logic in the  cell
                tagCell.activityIndicator.stopAnimating()
                tagCell.createButton.isHidden = false
                self.tagFilterViewModelDelegate?.alert(title: "Error", message: error)
            }
            
            guard let newTag = newTag else {return}
            
            self.localTagDictionary[newTag] = false
            
            self.allTags.insert(newTag, at: 0)
            self.localTempTagFilters = self.allTags
            
            self.tagFilterViewModelDelegate?.reloadTable()
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            //TODO test!
            let tag = localTempTagFilters.remove(at: indexPath.row)
            localTagDictionary.removeValue(forKey: tag)
            allTags = allTags.filter({ (t) -> Bool in
                return t != tag
            })
            //tagFilterViewModelDelegate?.reloadTable()
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
            getAppDelegate().webService.deleteTag(tag: tag, callback: { (tag:Tag?, error:EnfocaError?) in
                if let error = error {
                    self.tagFilterViewModelDelegate?.alert(title: "Error", message: error)
                }
            })
        }
    }
    
    
    
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let tag = localTempTagFilters[indexPath.row]
        guard let _ = localTagDictionary[tag] else {
            return nil
        }
        return indexPath
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tag = localTempTagFilters[indexPath.row]
        tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
        localTagDictionary[tag] = true
        tagFilterViewModelDelegate?.selectedTagsChanged()
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let tag = localTempTagFilters[indexPath.row]
        localTagDictionary[tag] = false
        tagFilterViewModelDelegate?.selectedTagsChanged()
    }
    
    
    
//    func applySelectedTagsToDelegate(){
//        var tags : [Tag] = []
//        for (tag, selected) in localTagDictionary {
//            if selected {
//                tags.append(tag)
//            }
//        }
//        
////        tagFilterDelegate.selectedTags = tags
//        tagFilterDelegate.onSelectedTagsChanged(tags: tags)
//        
//    }
    
    func searchTagsFor(prefix: String){
        localTempTagFilters = []
        
        for tag in allTags {
            if tag.name.lowercased().hasPrefix(prefix.lowercased()) {
                localTempTagFilters.append(tag)
            }
        }
        
        if prefix.characters.count > 0 {
            let createTag = Tag(name: prefix)
            localTempTagFilters.append(createTag)
        }
    }
    
    func getSelectedTags() -> [Tag] {
        var tags : [Tag] = []
        for (tag, selected) in localTagDictionary {
            if (selected) {
                tags.append(tag)
            }
        }
        return tags
    }
    
    func deselectAll(){
        for (tag, _) in localTagDictionary {
            localTagDictionary[tag] = false
        }
        tagFilterViewModelDelegate?.selectedTagsChanged()
    }
}

extension TagFilterViewModel : TagCellDelegate {
    func update(tagCell: TagCell, tag: Tag, newTagName: String) {
//        tagCell.activityIndicator.startAnimating()
        getAppDelegate().webService.updateTag(oldTag: tag, newTagName: newTagName) { (tag:Tag?, error:EnfocaError?) in
//            tagCell.activityIndicator.stopAnimating()
            if let error = error {
                //Should probably refactor and put this logic in the  cell
//                tagCell.createButton.isHidden = false
                self.tagFilterViewModelDelegate?.alert(title: "Error", message: error)
            }
            
            guard let newTag = tag else { return }
            
            self.localTagDictionary[newTag] = false
            
            //Tag update has the same tagId and should match.  Replacing the imutable tag is how i'm getting the update value into the collection
            if let index = self.allTags.index(of: newTag) {
                self.allTags[index] = newTag
            }
            
            self.localTempTagFilters = self.allTags
            
            self.tagFilterViewModelDelegate?.reloadTable()
            
        }
    }
    func validate(tag: Tag, newTagName: String?) -> Bool {
        guard let newTagName = newTagName else { return false }
        if allTags.contains(where: { (tag:Tag) -> Bool in
            tag.name == newTagName
        }) {
            return false
        }
        return true
    }
}
