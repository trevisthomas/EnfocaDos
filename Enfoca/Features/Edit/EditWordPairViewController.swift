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

    @IBAction func cancelButtonAction(_ sender: Any) {
        dismiss(animated: true) {
            //done
        }
    }
    
    private func initializeLookAndFeel() {
        hideKeyboardWhenTappedAround()
        
        updateFields()
        
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
            tagFilterViewController.initialize(delegate: self)
        }
    }
    
    fileprivate func updateFields(){
        title = controller.title()
        
        if controller.isEditMode {
            editorViewController.saveButton.setTitle("Save", for: .normal)
            editorViewController.saveButton.isEnabledEnfoca = controller.isValidForSaveOrCreate()
            editorViewController.deleteButton.isEnabledEnfoca = true
        } else {
            editorViewController.saveButton.setTitle("Create", for: .normal)
            editorViewController.deleteButton.isEnabledEnfoca = false
        }
        
        
        editorViewController.refresh()
    }

    fileprivate func refreshButtonState() {
        editorViewController.saveButton.isEnabledEnfoca = controller.isValidForSaveOrCreate()
    }
    
}

extension EditWordPairViewController: EditWordPairControllerDelegate {
    func onError(title: String, message: EnfocaError) {
        self.presentAlert(title: title, message: message)
    }

    func onTagsLoaded() {
        editorViewController.refresh()
        refreshButtonState()
        updateFields()
        
    }
    //Deprecate?
    func onUpdate() {
        updateFields()
        refreshButtonState()
        editorViewController.refresh()
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
            //Apply the new selecterd tags
            controller.selectedTags = newValue
            
            editorViewController.refresh()
            
            refreshButtonState()
            updateFields()
        }
    }
}


//This is maddness.  Why is this delegate here? TODO, get rid of this.  These things should just come straignt from the VM/Controller
extension EditWordPairViewController: EditorViewControllerDelegate {
    

    var mostRecentlyUsedTags: [Tag] {
        get{
            return controller.mostRecentlyUsedTags
        }
    }

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
        let alert = presentActivityAlert(title: "Please wait...", message: nil)
        controller.performSaveOrCreate(handleFailedValidation: { (existingWordPair: WordPair) in
            alert.dismiss(animated: true, completion: {
                self.editorViewController.failedValidation()
                self.presentOkCancelAlert(title: "Already Exists", message: "'\(self.controller.word)' already exists. Would you like to view the existing item?", callback: { (affirmative: Bool) in
                    if affirmative {
                        self.switchToWordPair(wordPair: existingWordPair)
                    }
                })
            })
        }) { 
            alert.dismiss(animated: false, completion: {
                self.dismissViewController()
            })
        }
    }
    
    private func switchToWordPair(wordPair: WordPair) {
        let alert = presentActivityAlert(title: "Please wait...", message: nil)
        
        self.controller.switchToWordPair(wordPair: wordPair) {
            alert.dismiss(animated: true, completion: { 
                //
            })
        }
    }
    func performDelete() {
        presentOkCancelAlert(title: "Warning", message: "Are you sure that you want to delete '\(controller.word)'? This operation can not be undone.") { (affirmative: Bool) in
            if affirmative {
                self.performDeleteWithoutWarning()
            }
        }
        
    }
    
    private func performDeleteWithoutWarning() {
        let alert = presentActivityAlert(title: "Please wait...", message: nil)
        controller.performDelete {
            alert.dismiss(animated: false, completion: {
                self.dismissViewController()
            })
        }
    }
    
    func performTagEdit(atRect: CGRect, cell: UICollectionViewCell) {
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
    var averageTime: String {
        get{
            return controller.getAverageTime()
        }
    }

    func isCreateMode() -> Bool {
        return delegate.isCreateMode()
    }
    
    func applyTag(_ tag: Tag) {
        controller.applyTag(tag)
    }
    
    func removeTag(_ tag: Tag) {
        controller.removeTag(tag: tag)
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


