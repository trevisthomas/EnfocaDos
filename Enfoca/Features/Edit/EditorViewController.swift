//
//  EditorViewController.swift
//  Enfoca
//
//  Created by Trevis Thomas on 6/21/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import Speech
import UIKit

//TODO:  The use of delegates here is inconsistant.  With xcode 9, refactor this.
protocol EditorViewControllerDelegate {
    var wordText: String {get set}
    var definitionText: String {get set}
    var selectedTagText : String {get}
    var mostRecentlyUsedTags:[Tag] {get}
    var selectedTags: [Tag] {get}
    
    var dateAdded: String{get}
    var dateUpdated: String{get}
    var score: String{get}
    var count: String{get}
    var averageTime: String{get}
    
    func performSave()
    func performDelete()
    func performTagEdit(atRect: CGRect, cell: UICollectionViewCell)
    
    func isCreateMode() ->Bool
    func applyTag(_ tag: Tag)
    func removeTag(_ tag: Tag)
    
    func validateTermForExactMatches()
}

class EditorViewController: UIViewController {

    
    @IBOutlet weak var lookupWordButton: EnfocaButton!
    @IBOutlet weak var lookupDefinitionButton: EnfocaButton!
    
    @IBOutlet weak var wordTextField: AnimatedTextField!
    @IBOutlet weak var definitionTextField: AnimatedTextField!
    @IBOutlet weak var saveButton: EnfocaButton!
    @IBOutlet weak var deleteButton: EnfocaButton!
    @IBOutlet weak var showQuizStatsButton: UIButton!
    
    @IBOutlet weak var tagCollectionViewContainer: UIView!
    @IBOutlet weak var listenViewContainer: UIView!
    @IBOutlet weak var speakButton: UIButton!
    @IBOutlet weak var selectedTagsLabel: UILabel!
    
    fileprivate var delegate : EditorViewControllerDelegate!
    private var mruTagViewController: TagSelectionViewController!
    private var speechUtility: SpeechUtility?
    private var listenViewController: ListenViewController!
    
    private var animateTagSelector: Bool = true
    override func viewDidLoad() {
        super.viewDidLoad()
        
        animateTagSelector = true 
        
        initializeLookAndFeel()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        wordTextField.initialize()
        definitionTextField.initialize()
        
        if animateTagSelector {
            mruTagViewController.initialize(tags: delegate.mostRecentlyUsedTags, browseDelegate: self, animated: true, isSortEnabled: false)
            animateTagSelector = false
        }
        
        if delegate.isCreateMode() {
            wordTextField.becomeFirstResponder()
        }
    }
    
    func initialize(delegate: EditorViewControllerDelegate) {
        self.delegate = delegate
        
        initializeSubViews()
        
        refresh()
    }
    
    private func initializeLookAndFeel() {
        wordTextField.addTarget(self, action: #selector(wordTextDidChange(_:)), for: [.editingChanged])
        
        wordTextField.addTarget(self, action: #selector(wordTextDidEndEditing(_:)), for: [UIControlEvents.editingDidEnd])
        
        definitionTextField.addTarget(self, action: #selector(definitionTextDidChange(_:)), for: [.editingChanged])
        
        wordTextField.updatePlacelderText(placeholder: getTermTitle())
        
        definitionTextField.updatePlacelderText(placeholder: getDefinitionTitle())
        
        wordTextField.language = getAppDelegate().webService.getCurrentDictionary().language
        
        
    }
    
    private func initializeSubViews(){
        mruTagViewController = createTagSelectionViewController(inContainerView: tagCollectionViewContainer)
        mruTagViewController.animateCollectionViewCellCreation = true
        mruTagViewController.setScrollDirection(direction: .horizontal)
        
        if let language = getAppDelegate().webService.getCurrentDictionary().language {
            listenViewController = createListenViewController(inContainerView: listenViewContainer)
            listenViewController.initialize(language: language, phrase: delegate.wordText)
        }
        
    }
    
    func definitionTextDidChange(_ textField: UITextField) {
        delegate.definitionText = textField.text!
    }
    
    func wordTextDidChange(_ textField: UITextField) {
        delegate.wordText = textField.text!
    }
    
    func wordTextDidEndEditing(_ textField: UITextField) {
        delegate.validateTermForExactMatches()
    }

    @IBAction func toggleQuizStatistics(_ sender: UIButton) {
        performSegue(withIdentifier: "WordPairStatisticsSegue", sender: nil)
    }
    
    @IBAction func saveButtonAction(_ sender: Any) {
        delegate.performSave()
    }

    @IBAction func deleteButtonAction(_ sender: Any) {
        delegate.performDelete()
    }
   
    @IBAction func lookupWordAction(_ sender: Any) {
        performSegue(withIdentifier: "LookupWordSegue", sender: CardSide.term)
    }
    
    @IBAction func lookupDefinitionAction(_ sender: Any) {
        performSegue(withIdentifier: "LookupDefinitionSegue", sender: CardSide.definition)
    }
    
    @IBAction func speakAction(_ sender: Any) {
        let speechHelper = TextToSpeech()
        speechHelper.speak(phrase: delegate.wordText, language: getAppDelegate().webService.getCurrentDictionary().language)
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
            
        } else if let to = segue.destination as? WordPairStatisticsViewController {
            to.modalPresentationStyle = UIModalPresentationStyle.popover
            to.popoverPresentationController!.delegate = self
            to.initialize(delegate: delegate)
        }
        else {
            fatalError("Segue doesn't exist")
        }
    }
    
    func refresh(){
        guard let _ = delegate else { return }
        wordTextField.text = delegate.wordText
        definitionTextField.text = delegate.definitionText
        
        
        //TODO! Learn how to make the custom text field realize that the text was set without breaking the text attribute.
        wordTextField.initialize()
        definitionTextField.initialize()
        
        showQuizStatsButton.isHidden = delegate.isCreateMode()
        
        let text = delegate.selectedTags.tagsToText().isEmpty ? "<select tags below>" : delegate.selectedTags.tagsToText()
        
        selectedTagsLabel.text = text

        mruTagViewController.reloadTags(tags: delegate.mostRecentlyUsedTags)
    }
    
    func failedValidation(){
        CustomAnimations.shakeAnimation(view: wordTextField)
    }
    
}

extension EditorViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}


extension EditorViewController: BrowseTagSelectionDelegate {
    func browseWordsWithTag(withTag: Tag, atRect: CGRect, cell: UICollectionViewCell) {
        delegate.applyTag(withTag)
    }
    
    func showEditor(atRect: CGRect, cell: UICollectionViewCell) {
        delegate.performTagEdit(atRect: atRect, cell: cell)
    }
}

