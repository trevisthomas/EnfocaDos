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
    func isCreateMode() -> Bool
    func getCreateText() -> String
    func getWordPairOrder() -> WordPairOrder
}

class EditWordPairViewController: UIViewController {
    
    fileprivate var controller: EditWordPairController!
    
    @IBOutlet weak var headerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bodyView: UIView!
    
    var delegate: EditWordPairViewControllerDelegate!
    fileprivate let tagEditorAnimator = EnfocaDefaultAnimator()
    
    fileprivate var editorViewController: EditorViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if delegate.isCreateMode() {
            controller = EditWordPairController(delegate: self, wordPairOrder: delegate.getWordPairOrder(), text: delegate.getCreateText())
        } else {
            controller = EditWordPairController(delegate: self, wordPair: delegate.sourceWordPair)
        }
        
        initializeSubViews()
        
        initializeLookAndFeel()
        
        controller.initialize()
        
        editorViewController.initialize(delegate: self)
        
        getAppDelegate().addListener(listener: controller)
        refreshButtonState()
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
        hideKeyboardWhenTappedAround()
        
        updateFields()
        
        
        if controller.isEditMode {
            editorViewController.saveButton.setTitle("Save", for: .normal)
            editorViewController.saveButton.isEnabledEnfoca = false
            editorViewController.deleteButton.isEnabledEnfoca = true
        } else {
            editorViewController.saveButton.setTitle("Create", for: .normal)
            editorViewController.deleteButton.isEnabledEnfoca = false
        }
        
    }
    
    private func initializeSubViews(){
        
        editorViewController = createEditorViewController(inContainerView: bodyView)
        
    }
    
    func definitionTextDidChange(_ textField: UITextField) {
        controller.definition = textField.text!
        
        refreshButtonState()
    }
    
    func wordTextDidChange(_ textField: UITextField) {
        controller.word = textField.text!
        
        refreshButtonState()
    }
    
    
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let tagFilterViewController = segue.destination as? TagFilterViewController {
            
            tagFilterViewController.transitioningDelegate = self
            tagFilterViewController.tagFilterDelegate = self
        }
    }
    
    fileprivate func updateFields(){
        title = controller.title()
        
//        tagSummaryLabel.text = controller.tagsAsString()
//        definitionTextField.text = controller.definition
//        wordTextField.text = controller.word
        
        editorViewController.refresh()
    }

//    @IBAction func deleteButtonAction(_ sender: UIButton) {
//        controller.performDelete()
//    }
//    
//    @IBAction func saveOrCreateButtonAction(_ sender: UIButton) {
//        controller.performSaveOrCreate()
//    }
    
    @IBAction func lookupButtonAction(_ sender: UIButton) {
    }
    
    fileprivate func refreshButtonState() {
        editorViewController.saveButton.isEnabledEnfoca = controller.isValidForSaveOrCreate()
    }
    
}

extension EditWordPairViewController: EditWordPairControllerDelegate {
    func onError(title: String, message: EnfocaError) {
        self.presentAlert(title: title, message: message)
    }

    func onTagsLoaded(tags: [Tag], selectedTags: [Tag]) {
//        tagViewController.initialize(tags: tags, selectedTags: selectedTags, delegate: self)
        
        
        editorViewController.refresh()
        refreshButtonState()
        updateFields()
        
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
//            controller.initialize()
            
//            tagViewController.selectedTags(tags: newValue)
            
            editorViewController.refresh()
            
            refreshButtonState()
            updateFields()
        }
    }
}

extension EditWordPairViewController: EditorViewControllerDelegate {
    var wordText: String {
        get {
            return controller.word
        }
        set {
            controller.word = newValue
            refreshButtonState()
        }
    }
    var definitionText: String {
        get{
            return controller.definition
        }
        set {
            controller.definition = newValue
            refreshButtonState()
        }
    }
    var selectedTagText : String {
        get {
            return controller.tagsAsString()
        }
    }
    
    func performSave() {
        controller.performSaveOrCreate()
    }
    func performDelete() {
        controller.performDelete()
    }
    func performTagEdit() {
        performSegue(withIdentifier: "editTags", sender: nil)
    }
    
    var dateAdded: String {
        get {
            return controller.getDateAdded()
        }
    }
    var dateUpdated: String{
        get {
           return controller.getDateUpdated()
        }
    }
    var score: String{
        get {
            return controller.getScore()
        }
    }
    var count: String{
        get {
            return controller.getCount()
        }
    }

    func isCreateMode() -> Bool {
        return delegate.isCreateMode()
    }
}

//For animated transitions
extension EditWordPairViewController: UIViewControllerTransitioningDelegate {
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        if let _ = presented as? TagFilterViewController, let _ = source as? EditWordPairViewController {
            return tagEditorAnimator
        }
        
        return nil
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        if let _ = dismissed as? TagFilterViewController {
            return tagEditorAnimator
        }
        
        return nil
    }
}

extension EditWordPairViewController: EnfocaDefaultAnimatorTarget {
    func getRightNavView() -> UIView? {
        return cancelButton
    }
    func getTitleView() -> UIView {
        return titleLabel
    }
    func getHeaderHeightConstraint() -> NSLayoutConstraint {
        return headerHeightConstraint
    }
    func additionalComponentsToHide() -> [UIView] {
        return []
    }
    func getBodyContentView() -> UIView {
        return bodyView
    }
}


