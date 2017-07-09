//
//  ModularHomeViewController.swift
//  Enfoca
//
//  Created by Trevis Thomas on 7/5/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import UIKit

class ModularHomeViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var languageSegmentedControl: UISegmentedControl!
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var searchOrCreateTextField: UITextField!
    
    
    
    @IBOutlet weak var overlayHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var overlayBottomConstraint: NSLayoutConstraint!

    @IBOutlet weak var expandingTableViewHolder: UIView!
    @IBOutlet weak var searchResultsTableViewContainer: UIView!
    @IBOutlet weak var overlayViewContainer: UIView!
    
    @IBOutlet weak var searchResultsTableViewContainerLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var searchOrCreateLeftConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var magifierCloseView: MagnifierCloseView!
    
    @IBOutlet weak var headerHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak var searchUnderlineView: UIView!

    fileprivate var controller: HomeController!
    fileprivate var originalHeightConstraintConstant: CGFloat!
    fileprivate var retractedHeightConstraintConstant: CGFloat!
    
    fileprivate var originalBottomConstraintConstant: CGFloat!
    fileprivate var retractedBottomConstraintConstant: CGFloat!
    
    fileprivate var wordPairTableViewController: WordPairTableViewController!
    fileprivate var overlayViewController: HomeOverlayViewController!
    
    fileprivate var editWordPairAnimator = EnfocaDefaultAnimator()
    fileprivate let browseViewFromHomeAnimator = BrowseFromHomeAnimator()
    
    private var originalHeightConstraintOnGray: CGFloat!
    private var expandedHeightConstraintOnGray: CGFloat!
    private var originalOverlayFrame: CGRect!
    private var retractedOverlayFrame: CGRect!

    
    private static var synchRequestDenied = false

    //I'm proxying a constraint from my sub view
    var segmentedControlLeftConstraint: NSLayoutConstraint {
        get {
            return overlayViewController.segmentedControlLeftConstraint
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        controller = HomeController(delegate: self)
        
        initializeLookAndFeel()
        
        initializeSubViews()
        
        
        controller.initialize()
        getAppDelegate().addListener(listener: controller)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        controller.reloadTags()
        controller.search()
        
        //I found that when creating a new Dictionary that the conch record might not return.  I think that it was a threading thing, but I'm putting in an explicit delay.
        delay(delayInSeconds: 1) {
            if ModularHomeViewController.synchRequestDenied == false {
                self.controller.isDataStoreSynchronized { (isInSynch: Bool) in
                    if !isInSynch {
                        self.presentDataOutOfSynchAlert()
                    }
                }
            }
        }
    }
    
    //TREVIS, you dropped this here while the animator was disabled
    override func viewDidAppear(_ animated: Bool) {
        self.magifierCloseView.initialize()
        self.magifierCloseView.isSearchMode = isExpanded()
        
        self.searchOrCreateTextField.selectTextIfNotEmpty()
    }
    
    private func presentDataOutOfSynchAlert(){
        let dialog = UIAlertController(title: "Refresh Needed", message: "Data is out of synch, would you like to reload now?", preferredStyle: UIAlertControllerStyle.alert)
        
        dialog.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            let dictionary = self.controller.getCurrentDictionary()
            self.performSegue(withIdentifier: "DictionaryLoadingSeque", sender: dictionary)
        }))
        
        dialog.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            ModularHomeViewController.synchRequestDenied = true
        }))
        
        getAppDelegate().applicationDefaults.removeDictionary(services().getCurrentDictionary())
        present(dialog, animated: true, completion: nil)
    }
    
    private func initializeLookAndFeel(){
        
        originalHeightConstraintConstant = overlayHeightConstraint.constant
        retractedHeightConstraintConstant = view.frame.height + originalHeightConstraintConstant
        
        originalBottomConstraintConstant = overlayBottomConstraint.constant
        retractedBottomConstraintConstant =  -(view.frame.height + originalBottomConstraintConstant)
        
        
        searchOrCreateTextField.addTarget(self, action: #selector(searchOrCreateTextDidChange(_:)), for: [.editingChanged])
        
        searchOrCreateTextField.addTarget(self, action: #selector(searchOrCreateTextEditingDidEnd(_:)), for: [.editingDidEnd])
        
        
        searchOrCreateTextField.addTarget(self, action: #selector(searchOrCreateTextDidBegin(_:)), for: [.editingDidBegin])
        
        let font = Style.segmentedControlFont()
        languageSegmentedControl.setTitleTextAttributes([NSFontAttributeName: font],
                                                        for: .normal)
        
        languageSegmentedControl.setTitle(getDefinitionTitle(), forSegmentAt: 0)
        languageSegmentedControl.setTitle(getTermTitle(), forSegmentAt: 1)
        
        titleLabel.text = getSubject()
        
        searchOrCreateTextField.setPlaceholderTextColor(color: UIColor(hexString: "#ffffff", alpha: 0.19))
        
    }
    
    private func initializeSubViews() {
        wordPairTableViewController = createWordPairTableViewController(inContainerView: searchResultsTableViewContainer)
        
        wordPairTableViewController.initialize(delegate: self, order: controller.wordOrder)
        
        overlayViewController = createHomeOverlayViewController(inContainerView: overlayViewContainer)
        
        overlayViewController.initialize(delegate: self)
    }

    func searchOrCreateTextDidBegin(_ textField: UITextField) {
        showWordTable()
    }
    
    func searchOrCreateTextDidChange(_ textField: UITextField) {
        let text = textField.text ?? ""
        
        wordPairTableViewController.offerCreation(withText: text)
        //        if text.isEmpty {
        //            hideWordTable()
        //        } else {
        //            controller.phrase = text
        //            showWordTable()
        //        }
        
        controller.phrase = text
        showWordTable()
        
    }
    
    func searchOrCreateTextEditingDidEnd(_ textField: UITextField) {
        dismissKeyboard()
    }
    
    private func showWordTable(){
        
        if isRetracted() {
            return
        }
        
        controller.phrase = ""
        controller.search()
        magifierCloseView.toggle()
        
        CustomAnimations.animateExpandAndPullOut(target: self.backButton, delay: 0.0, duration: 0.3)
        
        toggle {
        }
        
    }
    
    private func hideWordTable(){
        wordPairTableViewController.offerCreation(withText: "")
        
        if isExpanded() {
            return
        }
        
        dismissKeyboard()
        
        magifierCloseView.toggle()
        
        toggle {
            self.wordPairTableViewController.clearWordPairs()
            CustomAnimations.animatePopIn(target: self.backButton, delay: 0.0, duration: 0.3)
        }
    }
    
    fileprivate func toggle(callback: @escaping ()->()) {
        if isExpanded() {
            overlayHeightConstraint.constant = retractedHeightConstraintConstant
            overlayBottomConstraint.constant = retractedBottomConstraintConstant
            UIView.animate(withDuration: 0.6, delay: 0.2, options: [.curveEaseInOut], animations: {
                self.view.layoutIfNeeded()
            }) { ( _ ) in
                callback()
            }
        } else {
            
            
            overlayHeightConstraint.constant = originalHeightConstraintConstant
            overlayBottomConstraint.constant = originalBottomConstraintConstant
            UIView.animate(withDuration: 1.2, delay: 0.2, options: [.curveEaseInOut], animations: {
                self.view.layoutIfNeeded()
            }) { ( _ ) in
                callback()
            }
        }
    }
    
    fileprivate func isExpanded()->Bool {
        return overlayHeightConstraint.constant == originalHeightConstraintConstant
    }
    
    fileprivate func isRetracted()->Bool {
        return overlayHeightConstraint.constant == retractedHeightConstraintConstant
    }
    

    
    @IBAction func tappedMagnifierCloseAction(_ sender: Any) {
        //The way this works is anoying.  TODO: Change the MagnifierCloseView so that you can just pass it a boolean. Toggle is anoying
        if !self.magifierCloseView.isSearchMode! {
            self.searchOrCreateTextField.text = "" //Causes it to close. No!
            hideWordTable()
        } else {
            showWordTable()
        }
    }
    
    @IBAction func languageSegmentedControlChanged(_ sender: UISegmentedControl) {
        wordPairTableViewController.clearWordPairs()
        
        switch (sender.selectedSegmentIndex) {
        case 0:
            controller.wordOrder = WordPairOrder.definitionAsc
        case 1:
            controller.wordOrder = WordPairOrder.wordAsc
        default:
            fatalError()
        }
        
        
        let text = searchOrCreateTextField.text ?? "".trimmingCharacters(in: .whitespacesAndNewlines)
        
        if text.isEmpty {
            wordPairTableViewController.clearWordPairs()
        } else {
            controller.phrase = text
        }
    }
    
    @IBAction func backButtonAction(_ sender: Any) {
        getAppDelegate().saveDefaults()
        performSegue(withIdentifier: "DictionarySelectionSeque", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let toBrowseViewController = segue.destination as? BrowseViewController {
            guard let tag = sender as? Tag else { fatalError() }
            //TODO: Didnt you decide not to do this? All delegates all the time right?
            
            
            toBrowseViewController.transitioningDelegate = self
//            toBrowseViewController.controller = browseController
            
            toBrowseViewController.initialize(tag: tag, wordOrder: controller.wordOrder)
        }
        
        if let editWordPairVC = segue.destination as? EditWordPairViewController  {
            
            editWordPairVC.transitioningDelegate = self
            
            editWordPairVC.delegate = self
            
        }
        
        if let quizViewController = segue.destination as? QuizOptionsViewController {
            quizViewController.transitioningDelegate = self
            quizViewController.initialize(delegate: self)
        }
        
        if let to = segue.destination as? NewAppLaunchViewController {
            to.initialize(autoload: false)
        }
        
        if let to = segue.destination as? DictionaryLoadingViewController {
            guard let dictionary = sender as? UserDictionary else { fatalError() }
            to.initialize(dictionary: dictionary)
        }
        
    }
}

//For animated transitions
extension ModularHomeViewController: UIViewControllerTransitioningDelegate {
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        print("Presenting \(presenting.description)")
        
        if let _ = presented as? BrowseViewController, let _ = source as? ModularHomeViewController {
            browseViewFromHomeAnimator.presenting = true
            return browseViewFromHomeAnimator
        }
        
        if let _ = presented as? EditWordPairViewController, let _ = source as? ModularHomeViewController {
            editWordPairAnimator.presenting = true
            return editWordPairAnimator
        }
        
        if let _ = presented as? QuizOptionsViewController, let _ = source as? ModularHomeViewController {
            browseViewFromHomeAnimator.presenting = true
            return browseViewFromHomeAnimator
        }
        
        return nil
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        print("Dismissing \(dismissed.description)")
        
        if let _ = dismissed as? BrowseViewController {
            browseViewFromHomeAnimator.presenting = false
            return browseViewFromHomeAnimator
        }
        
        if let _ = dismissed as? EditWordPairViewController {
            editWordPairAnimator.presenting = false
            return editWordPairAnimator
        }
        
        if let _ = dismissed as? QuizOptionsViewController {
            browseViewFromHomeAnimator.presenting = false
            return browseViewFromHomeAnimator
        }
        
        return nil
    }
}


extension ModularHomeViewController: HomeControllerDelegate {
    func onTagsLoaded(tags: [Tag]) {
        overlayViewController.onTagsLoaded(tags: tags)
    }
    
    func onSearchResults(words: [WordPair]) {
        wordPairTableViewController.updateWordPairs(order: controller.wordOrder, wordPairs: words)
    }
    
    func onError(title: String, message: EnfocaError) {
        self.presentAlert(title: title, message: message)
    }
    
    func onWordPairOrderChanged() {
        
        let order : WordPairOrder = controller.wordOrder
        switch (order) {
        case .definitionAsc, .definitionDesc:
            languageSegmentedControl.selectedSegmentIndex = 0
        case WordPairOrder.wordAsc, WordPairOrder.wordDesc:
            languageSegmentedControl.selectedSegmentIndex = 1
        }
    }
}


extension ModularHomeViewController: WordPairTableDelegate {
    func onCreate(atRect: CGRect, cell: UITableViewCell) {
        
        controller.selectedWordPair = nil
        performSegue(withIdentifier: "EditWordPairControllerSegue", sender: nil)
    }
    
    func onWordPairSelected(wordPair: WordPair, atRect: CGRect, cell: UITableViewCell) {
        controller.selectedWordPair = wordPair
        
        performSegue(withIdentifier: "EditWordPairControllerSegue", sender: wordPair)
    }
}

extension ModularHomeViewController: EditWordPairViewControllerDelegate {
    func getWordPairOrder() -> WordPairOrder {
        return controller.wordOrder
    }
    
    var sourceWordPair: WordPair {
        get {
            return controller.selectedWordPair!
        }
    }
    
    func isCreateMode() -> Bool {
        return controller.selectedWordPair == nil
    }
    
    func getCreateText() -> String {
        return searchOrCreateTextField.text!
    }
    
}

extension ModularHomeViewController: QuizViewControllerDelegate {
    func tagSelectedForQuiz() -> Tag {
        return controller.selectedQuizTag!
    }
}

extension ModularHomeViewController: EnfocaDefaultAnimatorTarget {
    func getRightNavView() -> UIView? {
        return nil
    }
    func getTitleView() -> UIView {
        return titleLabel
    }
    func getHeaderHeightConstraint() -> NSLayoutConstraint {
        return headerHeightConstraint
    }
    func additionalComponentsToHide() -> [UIView] {
        return [languageSegmentedControl, magifierCloseView, searchOrCreateTextField, searchUnderlineView]
    }
    func getBodyContentView() -> UIView {
        return searchResultsTableViewContainer
    }
}

extension ModularHomeViewController: HomeOverlayViewControllerDelegate {
    func browseWordsWithTag(withTag tag: Tag, atRect: CGRect, cell: UICollectionViewCell) {
        print("Browse words tagged: \(tag.name)")

        browseViewFromHomeAnimator.sourceFrame = atRect
        browseViewFromHomeAnimator.sourceCell = cell

        performSegue(withIdentifier: "BrowseViewControllerSegue", sender: tag)
    }
    
    func quizWordsWithTag(withTag tag: Tag, atRect: CGRect, cell: UICollectionViewCell) {
        print("Quiz words tagged: \(tag.name)")
        
        controller.selectedQuizTag = tag
        browseViewFromHomeAnimator.sourceFrame = atRect
        browseViewFromHomeAnimator.sourceCell = cell
        
        
        performSegue(withIdentifier: "QuizViewControllerSegue", sender: tag)
        
    }
}



