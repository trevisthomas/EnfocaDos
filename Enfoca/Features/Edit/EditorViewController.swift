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
    
    var dateAdded: String{get}
    var dateUpdated: String{get}
    var score: String{get}
    var count: String{get}
    
    func performSave()
    func performDelete()
    func performTagEdit()
    
    func isCreateMode() ->Bool 
}

class EditorViewController: UIViewController {

    
    @IBOutlet weak var lookupWordButton: EnfocaButton!
    @IBOutlet weak var lookupDefinitionButton: EnfocaButton!
    
    @IBOutlet weak var selectedTagsLabel: UILabel!
    
    @IBOutlet weak var wordTextField: AnimatedTextField!
    @IBOutlet weak var definitionTextField: AnimatedTextField!
    @IBOutlet weak var saveButton: EnfocaButton!
    @IBOutlet weak var deleteButton: EnfocaButton!
    @IBOutlet weak var showQuizStatsButton: UIButton!
    
    @IBOutlet weak var accuracyLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var dateAddedLabel: UILabel!
    @IBOutlet weak var dateUpdated: UILabel!
    
    @IBOutlet weak var statisticsWrapperView: UIView!
    
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

    @IBAction func toggleQuizStatistics(_ sender: UIButton) {
        statisticsWrapperView.isHidden = !statisticsWrapperView.isHidden
        
        if statisticsWrapperView.isHidden {
            sender.setTitle("Show Quiz Statistics", for: .normal)
        } else {
            sender.setTitle("Hide Quiz Statistics", for: .normal)
        }
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
    
    @IBAction func lookupWordAction(_ sender: Any) {
        performSegue(withIdentifier: "LookupWordSegue", sender: CardSide.term)
    }
    
    @IBAction func lookupDefinitionAction(_ sender: Any) {
        performSegue(withIdentifier: "LookupDefinitionSegue", sender: CardSide.definition)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let to = segue.destination as? LookupTextViewController {
            guard let cardSide = sender as? CardSide else { fatalError() }
            
            to.modalPresentationStyle = UIModalPresentationStyle.popover
            to.popoverPresentationController!.delegate = self
            
            let arguement: String
            switch cardSide {
            case .term:
                arguement = wordTextField.text!
            case .definition:
                arguement = definitionTextField.text!
            default:
                fatalError()
            }
            
            to.initialize(cardSide: cardSide, arguement: arguement)
            
        } else {
            fatalError("Segue doesn't exist")
        }
    }
    
    func refresh(){
        guard let _ = delegate else { return }
        wordTextField.text = delegate.wordText
        definitionTextField.text = delegate.definitionText
        selectedTagsLabel.text = delegate.selectedTagText
        
        accuracyLabel.text = delegate.score
        countLabel.text = delegate.count
        dateAddedLabel.text = delegate.dateAdded
        dateUpdated.text = delegate.dateUpdated
        
        //TODO! Learn how to make the custom text field realize that the text was set without breaking the text attribute.
        wordTextField.initialize()
        definitionTextField.initialize()
        
//        statisticsWrapperView.isHidden = delegate.isCreateMode()
        showQuizStatsButton.isHidden = delegate.isCreateMode()
    }
    
    
    
}

extension EditorViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}
