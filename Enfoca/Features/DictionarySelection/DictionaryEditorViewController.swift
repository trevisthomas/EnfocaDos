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
    @IBOutlet weak var deleteButton: EnfocaButton!
    @IBOutlet weak var backButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        hideKeyboardWhenTappedAround()
        
        reload()
    }
    
    private func reload() {
        termTextField.text = dictionary.termTitle
        definitionTextField.text = dictionary.definitionTitle
        subjectTextField.text = dictionary.subject
        
        if dictionary.isTemporary {
            deleteButton.removeFromSuperview() 
            createButton.setTitle("Create", for: .normal)
        } else {
            createButton.setTitle("Update", for: .normal)
        }
    }

    func initialize(dictionary: UserDictionary) {
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
    
    @IBAction func deleteButtonAction(_ source: UIButton) {
        services().deleteDictionary(dictionary: dictionary) { (dictionary:UserDictionary?, error:EnfocaError?) in
            
            if let error = error {
                self.presentAlert(title: "Failed to update", message: error)
                return
            }
            
            guard let _ = dictionary else { fatalError() }
            //This was the easiest way to reload the list.  
            self.performSegue(withIdentifier: "LaunchAppSegue", sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let to = segue.destination as? DictionaryLoadingViewController {
            guard let dictionary = sender as? UserDictionary else { fatalError() }
            to.initialize(dictionary: dictionary)
        }
        
    }

}

extension DictionaryEditorViewController {
    fileprivate func updateDictionary() {
        
        validateForm {
            services().updateDictionary(oldDictionary: dictionary, termTitle: termTextField!.text!, definitionTitle: definitionTextField!.text!, subject: subjectTextField!.text!, language: "es", callback: { (dictionary: UserDictionary?, error: EnfocaError?) in
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
            services().createDictionary(termTitle: termTextField!.text!, definitionTitle: definitionTextField!.text!, subject: subjectTextField!.text!, language: "es") { (dictionary: UserDictionary?, error: EnfocaError?) in
                if let error = error {
                    self.presentAlert(title: "Failed to create", message: error)
                    return
                }
                
                guard let dictionary = dictionary else { fatalError() }
                
                self.performSegue(withIdentifier: "LoadDictionarySegue", sender: dictionary)
                
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
