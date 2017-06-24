//
//  EditorViewController.swift
//  Enfoca
//
//  Created by Trevis Thomas on 6/21/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import UIKit

protocol EditorViewControllerDelegate {
    var wordText: String {get set}
    var definitionText: String {get set}
    var selectedTagText : String {get}
    
    func performSave()
    func performDelete()
    func performTagEdit()
}

class EditorViewController: UIViewController {

    
    @IBOutlet weak var selectedTagsLabel: UILabel!
    
    @IBOutlet weak var wordTextField: AnimatedTextField!
    @IBOutlet weak var definitionTextField: AnimatedTextField!
    @IBOutlet weak var saveButton: EnfocaButton!
    @IBOutlet weak var deleteButton: EnfocaButton!
    private var delegate : EditorViewControllerDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeLookAndFeel()
    }
    
    func initialize(delegate: EditorViewControllerDelegate) {
        self.delegate = delegate
        refresh()
    }
    
    private func initializeLookAndFeel() {
        wordTextField.addTarget(self, action: #selector(wordTextDidChange(_:)), for: [.editingChanged])
        
        definitionTextField.addTarget(self, action: #selector(definitionTextDidChange(_:)), for: [.editingChanged])
    }
    
    func definitionTextDidChange(_ textField: UITextField) {
        delegate.definitionText = textField.text!
    }
    
    func wordTextDidChange(_ textField: UITextField) {
        delegate.wordText = textField.text!
    }

    
    @IBAction func saveButtonAction(_ sender: Any) {
        delegate.performSave()
    }

    @IBAction func deleteButtonAction(_ sender: Any) {
        delegate.performDelete()
    }
   
    @IBAction func selectedTagsTappedAction(_ sender: Any) {
        print("Tags!")
        delegate.performTagEdit()
    }
    
    func refresh(){
        guard let _ = delegate else { return }
        wordTextField.text = delegate.wordText
        definitionTextField.text = delegate.definitionText
        selectedTagsLabel.text = delegate.selectedTagText
        
        //TODO! Learn how to make the custom text field realize that the text was set without breaking the text attribute.
        wordTextField.initialize()
        definitionTextField.initialize()
    }
    
}
