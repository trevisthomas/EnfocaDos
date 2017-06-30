//
//  HomeViewController.swift
//  Enfoca
//
//  Created by Trevis Thomas on 5/14/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var oldTitleLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var languageSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var searchOrCreateTextField: UITextField!
    fileprivate var controller: HomeController!
    
    @IBOutlet weak var quizByTagContainerView: UIView!
    @IBOutlet weak var browseByTagContainerView: UIView!
    
    
    @IBOutlet weak var expandingTableViewHolder: UIView!
    @IBOutlet weak var searchResultsTableViewContainer: UIView!
    
    fileprivate var browseByTagViewController: TagSelectionViewController!
    fileprivate var quizByTagViewControler: TagSelectionViewController!
    fileprivate var wordPairTableViewController: WordPairTableViewController!
    
    @IBOutlet weak var hightConstraintOnGray: NSLayoutConstraint!
    
    @IBOutlet weak var titleTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var searchResultsTableViewContainerLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var searchOrCreateLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var languageSelectorLeftConstraint: NSLayoutConstraint!
    private var originalHeightConstraintOnGray: CGFloat!
    private var expandedHeightConstraintOnGray: CGFloat!
    
    @IBOutlet weak var browseLabelLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var quizLabelLeftConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var magifierCloseView: MagnifierCloseView!
    
    fileprivate var editWordPairAnimator = EnfocaDefaultAnimator()
    fileprivate var wordPairs : [WordPair] = []
    @IBOutlet weak var headerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var headerBackgroundView: UIView!
    
    fileprivate let browseViewFromHomeAnimator = BrowseFromHomeAnimator()
    
    @IBOutlet weak var searchUnderlineView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        controller = HomeController(delegate: self)
        
        initializeLookAndFeel()
        
        initializeSubViews()
        
        
        controller.initialize()
        getAppDelegate().addListener(listener: controller)
        
    }
    
    
    private func initializeLookAndFeel(){
        
        originalHeightConstraintOnGray = hightConstraintOnGray.constant
        expandedHeightConstraintOnGray = view.frame.height + originalHeightConstraintOnGray - expandingTableViewHolder.frame.height
        
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
        browseByTagViewController = createTagSelectionViewController(inContainerView: browseByTagContainerView)
        
        quizByTagViewControler = createTagSelectionViewController(inContainerView: quizByTagContainerView)
        
        wordPairTableViewController = createWordPairTableViewController(inContainerView: searchResultsTableViewContainer)
        
        wordPairTableViewController.initialize(delegate: self, order: controller.wordOrder)
        
        browseByTagViewController.animateCollectionViewCellCreation = true
        quizByTagViewControler.animateCollectionViewCellCreation = true
        
    }
    
    private func isWordTableContracted() -> Bool{
        return hightConstraintOnGray.constant == originalHeightConstraintOnGray
    }
    
    private func isWordTableExpanded() -> Bool{
        return hightConstraintOnGray.constant == expandedHeightConstraintOnGray
    }
    
    private func showWordTable(){
        guard isWordTableContracted() else {
//            print("already expanded")
            return
        }
        
        controller.phrase = ""
        controller.search()
        hightConstraintOnGray.constant = expandedHeightConstraintOnGray

        magifierCloseView.toggle()
        UIView.animate(withDuration: 1.2, delay: 0.2, options: [.curveEaseInOut], animations: { 
            self.view.layoutIfNeeded()
        }) { ( _ ) in
            //Nada
        }
        
    }
    
    private func hideWordTable(){
        wordPairTableViewController.offerCreation(withText: "")
        
        guard isWordTableExpanded() else {
//            print("already contracted")
            return
        }
        
        dismissKeyboard()
        
        hightConstraintOnGray.constant = originalHeightConstraintOnGray
        
        magifierCloseView.toggle()
        UIView.animate(withDuration: 0.6, delay: 0.2, options: [.curveEaseInOut], animations: {
            self.view.layoutIfNeeded()
        }) { ( _ ) in
            self.wordPairTableViewController.clearWordPairs()
        }

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
    
    @IBAction func tappedMagnifierCloseAction(_ sender: Any) {
        //The way this works is anoying.  TODO: Change the MagnifierCloseView so that you can just pass it a boolean. Toggle is anoying
        if !self.magifierCloseView.isSearchMode! {
            self.searchOrCreateTextField.text = "" //Causes it to close. No!
            hideWordTable()
        } else {
            showWordTable()
        }
    }
    
    @IBAction func backButtonAction(_ sender: Any) {
        performSegue(withIdentifier: "DictionarySelectionSeque", sender: nil)
    }
 
    //The animator calls this method to let it know that the transition animation is complete
    func transitionComplete() {
        controller.reloadTags()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let toBrowseViewController = segue.destination as? BrowseViewController {
            guard let tag = sender as? Tag else { fatalError() }
            //TODO: Didnt you decide not to do this? All delegates all the time right?
            let browseController = BrowseController(tag: tag, wordOrder: controller.wordOrder, delegate: toBrowseViewController)
            
            toBrowseViewController.transitioningDelegate = self
            toBrowseViewController.controller = browseController
        }
        
        if let editWordPairVC = segue.destination as? EditWordPairViewController  {
            
            editWordPairVC.transitioningDelegate = self
            
            editWordPairVC.delegate = self
            
        }
        
        if let quizViewController = segue.destination as? QuizOptionsViewController {
            quizViewController.transitioningDelegate = self
            
            quizViewController.delegate = self
            
        }
        
        if let to = segue.destination as? NewAppLaunchViewController {
            to.initialize(autoload: false)
        }

    }
}

//For animated transitions
extension HomeViewController: UIViewControllerTransitioningDelegate {
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        print("Presenting \(presenting.description)")
        
        if let _ = presented as? BrowseViewController, let _ = source as? HomeViewController {
            browseViewFromHomeAnimator.presenting = true
            return browseViewFromHomeAnimator
        }
        
        if let _ = presented as? EditWordPairViewController, let _ = source as? HomeViewController {
            editWordPairAnimator.presenting = true
            return editWordPairAnimator
        }
        
        if let _ = presented as? QuizOptionsViewController, let _ = source as? HomeViewController {
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

extension HomeViewController: HomeControllerDelegate {
    func onTagsLoaded(tags: [Tag]) {
        
        browseByTagViewController.initialize(tags: tags, browseDelegate: self)
        quizByTagViewControler.initialize(tags: tags, quizDelegate: self)
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

extension HomeViewController: BrowseTagSelectionDelegate {
    func browseWordsWithTag(withTag tag: Tag, atRect: CGRect, cell: UICollectionViewCell) {
        print("Browse words tagged: \(tag.name)")
        
        browseViewFromHomeAnimator.sourceFrame = atRect
        browseViewFromHomeAnimator.sourceCell = cell
        
        performSegue(withIdentifier: "BrowseViewControllerSegue", sender: tag)
    }
}

extension HomeViewController: QuizTagSelectionDelegate {
    func quizWordsWithTag(forTag tag: Tag, atRect: CGRect, cell: UICollectionViewCell) {
        print("Quiz words tagged: \(tag.name)")
        
        controller.selectedQuizTag = tag
        browseViewFromHomeAnimator.sourceFrame = atRect
        browseViewFromHomeAnimator.sourceCell = cell
        
        
        performSegue(withIdentifier: "QuizViewControllerSegue", sender: tag)
        
    }
}

extension HomeViewController: WordPairTableDelegate {
    func onCreate(atRect: CGRect, cell: UITableViewCell) {
        
        controller.selectedWordPair = nil
        
//        editWordPairFromCellAnimator.sourceCell = cell
        
        performSegue(withIdentifier: "EditWordPairControllerSegue", sender: nil)
    }
    
    func onWordPairSelected(wordPair: WordPair, atRect: CGRect, cell: UITableViewCell) {
        
//        editWordPairFromCellAnimator.sourceCell = cell
        
        controller.selectedWordPair = wordPair
        
        performSegue(withIdentifier: "EditWordPairControllerSegue", sender: wordPair)
    }
    
//    func onWordPairSelected(wordPair: WordPair, atRect: CGRect, cell: UITableViewCell) {
//        print("Selected \(wordPair.word)")
//        print("at Rect \(atRect)")
//    }
}

extension HomeViewController: EditWordPairViewControllerDelegate {
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

extension HomeViewController: QuizViewControllerDelegate {
    func tagSelectedForQuiz() -> Tag {
        return controller.selectedQuizTag!
    }
}

extension HomeViewController: EnfocaDefaultAnimatorTarget {
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

