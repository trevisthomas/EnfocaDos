//
//  DictionaryEditorViewController.swift
//  Enfoca
//
//  Created by Trevis Thomas on 6/27/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import UIKit

class DictionaryEditorViewController: UIViewController {
    fileprivate var dictionary: Dictionary!
    
    @IBOutlet weak var termTextField: AnimatedTextField!
    @IBOutlet weak var definitionTextField: AnimatedTextField!
    @IBOutlet weak var subjectTextField: AnimatedTextField!
    @IBOutlet weak var createButton: EnfocaButton!
    @IBOutlet weak var backButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

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
    }

    func initialize(dictionary: Dictionary) {
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
            presentAlert(title: "TODO", message: "Update not implemented yet")
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let to = segue.destination as? DictionaryLoadingViewController {
            guard let dictionary = sender as? Dictionary else { fatalError() }
            to.initialize(dictionary: dictionary)
        }
    }

}

extension DictionaryEditorViewController {
    fileprivate func createDictionary() {
        guard let termLabel = termTextField.getValidNonEmptyString() else {
            self.presentAlert(title: "Failed to create", message: "Term label can not be empty.")
            return
        }
        
        guard let definitionLabel = termTextField.getValidNonEmptyString() else {
            self.presentAlert(title: "Failed to create", message: "Definition label can not be empty.")
            return
        }
        
        guard let subject = subjectTextField.getValidNonEmptyString() else {
            self.presentAlert(title: "Failed to create", message: "Subject can not be empty.")
            return
        }
        
        services().createDictionary(termTitle: termLabel, definitionTitle: definitionLabel, subject: subject, language: "es") { (dictionary: Dictionary?, error: EnfocaError?) in
            if let error = error {
                self.presentAlert(title: "Failed to create", message: error)
                return
            }
            
            guard let dictionary = dictionary else { fatalError() }
            
            self.performSegue(withIdentifier: "LoadDictionarySegue", sender: dictionary)
            
        }
        
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
