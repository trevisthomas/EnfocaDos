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
    @IBOutlet weak var definitionTextField: UITextField!
    @IBOutlet weak var wordTextField: UITextField!
    @IBOutlet weak var saveOrCreateButton: EnfocaButton!
    @IBOutlet weak var lookupButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    var delegate: EditWordPairViewControllerDelegate!
    
    @IBOutlet weak var tagContainerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        controller = EditWordPairController(delegate: self, wordPair: delegate.sourceWordPair)
        
        initializeLookAndFeel()
        initializeSubViews()
        
        controller.initialize()
        
        getAppDelegate().addListener(listener: controller)
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
        
        if controller.isEditMode {
            saveOrCreateButton.setTitle("Save", for: .normal)
            saveOrCreateButton.isEnabledEnfoca = false
            deleteButton.isEnabled = true
        } else {
            saveOrCreateButton.setTitle("Create", for: .normal)
            deleteButton.isEnabled = false 
        }
        
        wordTextField.addTarget(self, action: #selector(wordTextDidChange(_:)), for: [.editingChanged])
        
        definitionTextField.addTarget(self, action: #selector(definitionTextDidChange(_:)), for: [.editingChanged])
        
    }
    
    func definitionTextDidChange(_ textField: UITextField) {
        controller.definition = textField.text!
        
        refreshButtonState()
    }
    
    func wordTextDidChange(_ textField: UITextField) {
        controller.word = textField.text!
        
        refreshButtonState()
    }
    
    
    private func initializeSubViews(){
        tagViewController = createTagSelectionViewController(inContainerView: tagContainerView)
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let tagFilterViewController = segue.destination as? TagFilterViewController {
            tagFilterViewController.tagFilterDelegate = self
        }
    }
    
    fileprivate func updateFields(){
        title = controller.title()
        tagSummaryLabel.text = controller.tagsAsString()
        definitionTextField.text = controller.definition
        wordTextField.text = controller.word
    }

    @IBAction func deleteButtonAction(_ sender: UIButton) {
    }
    
    @IBAction func saveOrCreateButtonAction(_ sender: UIButton) {
        controller.performSaveOrCreate()
    }
    
    @IBAction func lookupButtonAction(_ sender: UIButton) {
    }
    
    fileprivate func refreshButtonState() {
        saveOrCreateButton.isEnabledEnfoca = controller.isValidForSaveOrCreate()
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
    
    func dismissViewController() {
        dismiss(animated: true) {
            //done
        }
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
            
            refreshButtonState()
        }
    }
    
    
}

extension EditWordPairViewController: WordTagSelectionDelegate {
    func onTagSelected(tag: Tag){
        controller.addTag(tag: tag)
        refreshButtonState()
    }
    
    func onTagDeselected(tag: Tag) {
        controller.removeTag(tag: tag)
        refreshButtonState()
    }
    
    func onShowTagEditor() {
        print("Show the tag editor")
        performSegue(withIdentifier: "editTags", sender: nil)
    }
}


