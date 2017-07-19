//
//  DictionaryEditorViewController.swift
//  Enfoca
//
//  Created by Trevis Thomas on 6/27/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import UIKit

class DictionaryEditorViewController: UIViewController {
    fileprivate var dictionary: UserDictionary!
    
    @IBOutlet weak var termTextField: AnimatedTextField!
    @IBOutlet weak var definitionTextField: AnimatedTextField!
    @IBOutlet weak var subjectTextField: AnimatedTextField!
    @IBOutlet weak var createButton: EnfocaButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var languageButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bodyView: UIView!
    
    fileprivate var language : Language? = nil
    fileprivate var languageButtonText: String!
    fileprivate var isLanguageSelectionAvailable: Bool!
    fileprivate var animator: EnfocaDefaultAnimator = EnfocaDefaultAnimator()

    override func viewDidLoad() {
        super.viewDidLoad()

        hideKeyboardWhenTappedAround()
        
        languageButtonText = languageButton.title(for: .normal)
        
        languageButton.isHidden = !isLanguageSelectionAvailable
        reload()
    }
    
    private func reload() {
        termTextField.text = dictionary.termTitle
        definitionTextField.text = dictionary.definitionTitle
        subjectTextField.text = dictionary.subject
        
        if dictionary.isTemporary {
            createButton.setTitle("Create", for: .normal)
        } else {
            createButton.setTitle("Update", for: .normal)
        }
        
        let index = Language.languages.index { (language: Language) -> Bool in
            language.code == dictionary.language
        }
        
        if let index = index {
            let language: Language? = Language.languages[index]
            languageSelected(language: language)
        } else {
            languageSelected(language: nil)
        }
        
        
    }

    func initialize(dictionary: UserDictionary, isLanguageSelectionAvailable: Bool) {
        self.isLanguageSelectionAvailable = isLanguageSelectionAvailable
        self.dictionary = dictionary
    }
    
    @IBAction func backButtonAction(_ source: Any) {
        dismiss(animated: true) { 
            //Whatever
        }
    }
    
    @IBAction func createOrUpdateButtonAction(_ source: UIButton) {
        let title = source.title(for: .normal)
        
        if "Create" == title {
            createDictionary()
        } else if "Update" == title {
            updateDictionary()
        }
        
    }
    
    @IBAction func languageAction(_ source: UIButton) {
        performSegue(withIdentifier: "LanguageSegue", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let to = segue.destination as? DictionaryLoadingViewController {
            to.transitioningDelegate = self
            guard let dictionary = sender as? UserDictionary else { fatalError() }
            to.initialize(dictionary: dictionary)
        }
        if let to = segue.destination as? LanguageSelectionViewController {
            to.transitioningDelegate = self
            to.modalPresentationStyle = UIModalPresentationStyle.popover
            to.popoverPresentationController!.delegate = self
            
            to.initialize(delegate: self)
        }
        
    }

}

extension DictionaryEditorViewController: LanguageSelectionViewControllerDelegate {
    func languageSelected(language: Language?) {
        self.language = language
        
        if let name : String = language?.name {
            languageButton.setTitle("Language: \(name)", for: .normal)
        } else {
            languageButton.setTitle(languageButtonText, for: .normal)
        }
    }
}

//For popover on iphone
extension DictionaryEditorViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}


extension DictionaryEditorViewController {
    fileprivate func updateDictionary() {
        
        validateForm {
            
            
            services().updateDictionary(oldDictionary: dictionary, termTitle: termTextField!.text!, definitionTitle: definitionTextField!.text!, subject: subjectTextField!.text!, language: language?.code, callback: { (dictionary: UserDictionary?, error: EnfocaError?) in
                if let error = error {
                    self.presentAlert(title: "Failed to update", message: error)
                    return
                }
                guard let _ = dictionary else { fatalError() }

                self.dismiss(animated: true, completion: {
                    //Nothing
                })
            })
        }
    }
    
    fileprivate func createDictionary() {
        
        validateForm {
            let alert = presentActivityAlert(title: "Please wait...", message: nil)
            services().createDictionary(termTitle: termTextField!.text!, definitionTitle: definitionTextField!.text!, subject: subjectTextField!.text!, language: language?.code) { (dictionary: UserDictionary?, error: EnfocaError?) in
                alert.dismiss(animated: false, completion: {
                    if let error = error {
                        self.presentAlert(title: "Failed to create", message: error)
                        return
                    }
                    
                    guard let dictionary = dictionary else { fatalError() }
                    
                    self.performSegue(withIdentifier: "LoadDictionarySegue", sender: dictionary)
                })
            }
        }
    }
    
    func validateForm(callback: ()->()) {
        guard let _ = termTextField.getValidNonEmptyString() else {
            self.presentAlert(title: "Failed to create", message: "Term label can not be empty.")
            return
        }
        
        guard let _ = termTextField.getValidNonEmptyString() else {
            self.presentAlert(title: "Failed to create", message: "Definition label can not be empty.")
            return
        }
        
        guard let _ = subjectTextField.getValidNonEmptyString() else {
            self.presentAlert(title: "Failed to create", message: "Subject can not be empty.")
            return
        }
        
        callback()
    }
    
    private func getValidNonEmptyString(textField: UITextField) -> String? {
        guard let value = textField.text else { return nil }
        let trimmed = value.trim()
        return trimmed.characters.count > 0 ? trimmed : nil
    }
}

extension UITextField {
    func getValidNonEmptyString() -> String? {
        guard let value = self.text else { return nil }
        let trimmed = value.trim()
        return trimmed.characters.count > 0 ? trimmed : nil
    }
}

extension DictionaryEditorViewController: EnfocaDefaultAnimatorTarget {
    func getRightNavView() -> UIView? {
        return backButton
    }
    func getTitleView() -> UIView {
        return titleLabel
    }
    
    func additionalComponentsToHide() -> [UIView] {
        return []
    }
    func getBodyContentView() -> UIView {
        return bodyView
    }
}
extension DictionaryEditorViewController: UIViewControllerTransitioningDelegate {
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        animator.presenting = true
        return animator
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        animator.presenting = false
        return animator
    }
}


