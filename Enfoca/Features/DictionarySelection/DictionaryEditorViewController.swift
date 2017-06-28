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

}
