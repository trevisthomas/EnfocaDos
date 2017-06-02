//
//  WordPairEditorViewController.swift
//  Enfoca
//
//  Created by Trevis Thomas on 5/29/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import UIKit

protocol EditWordPairViewControllerDelegate {
    var sourceWordPair: WordPair {get}
}

class EditWordPairViewController: UIViewController {
    
    fileprivate var controller: EditWordPairController!
    fileprivate var tagViewController: TagSelectionViewController!

    @IBOutlet weak var tagSummaryLabel: UILabel!
    @IBOutlet weak var englishTextField: UITextField!
    @IBOutlet weak var spanishTextField: UITextField!
    
    var delegate: EditWordPairViewControllerDelegate!
    
    @IBOutlet weak var tagContainerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        controller = EditWordPairController(delegate: self, wordPair: delegate.sourceWordPair)
        
        initializeLookAndFeel()
        initializeSubViews()
        
        controller.initialize()
        
        getAppDelegate().activeController = controller
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func cancelButtonAction(_ sender: Any) {
        dismiss(animated: true) {
            //done
        }
    }
    
    private func initializeLookAndFeel() {
        updateFields()
    }
    
    private func initializeSubViews(){
        tagViewController = createTagSelectionViewController(inContainerView: tagContainerView)
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let tagFilterViewController = segue.destination as? TagFilterViewController {
            
//            let viewModel = TagFilterViewModel(selectedTags: self.controller.selectedTags, delegate: self)
//            tagFilterViewController.viewModel = viewModel
            
            tagFilterViewController.tagFilterDelegate = self
            
        }
    }
    
    fileprivate func updateFields(){
        title = controller.title()
        tagSummaryLabel.text = controller.tagsAsString()
        
    }

}

extension EditWordPairViewController: EditWordPairControllerDelegate {
    func onError(title: String, message: EnfocaError) {
        self.presentAlert(title: title, message: message)
    }

    func onTagsLoaded(tags: [Tag], selectedTags: [Tag]) {
        tagViewController.initialize(tags: tags, selectedTags: selectedTags, delegate: self)
    }
    
    func onUpdate() {
        updateFields()
    }
}

extension EditWordPairViewController: TagFilterViewControllerDelegate {
    var selectedTags: [Tag] {
        get {
            return controller.selectedTags
        }
        set {
            print(newValue)
            //Apply the new selecterd tags
            controller.selectedTags = newValue
            
            tagViewController.selectedTags(tags: newValue)
        }
    }
    
//    func getSelectedTags() -> [Tag] {
//        <#code#>
//    }
//    
//    func onSelectedTagsChanged(tags: [Tag]) {
//        
//    }
}

extension EditWordPairViewController: WordTagSelectionDelegate {
    func onTagSelected(tag: Tag){
        controller.addTag(tag: tag)
    }
    
    func onTagDeselected(tag: Tag) {
        controller.removeTag(tag: tag)
    }
    
    func onShowTagEditor() {
        print("Show the tag editor")
        performSegue(withIdentifier: "editTags", sender: nil)
    }
}


