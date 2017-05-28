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
    
    
    fileprivate var wordPairs : [WordPair] = []
    
    fileprivate let browseViewFromHomeAnimator = BrowseFromHomeAnimator()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initializeLookAndFeel()
        
        initializeSubViews()
        
        controller = HomeController(delegate: self)
        controller.initialize()
        getAppDelegate().activeController = controller
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
        
        let placeHolderText = searchOrCreateTextField.placeholder!
        searchOrCreateTextField.attributedPlaceholder = NSAttributedString(string: placeHolderText,
                                                               attributes: [NSForegroundColorAttributeName: UIColor(hexString: "#ffffff", alpha: 0.19)])
        
    }
    
    private func initializeSubViews() {
        browseByTagViewController = createTagSelectionViewController(inContainerView: browseByTagContainerView)
        
        quizByTagViewControler = createTagSelectionViewController(inContainerView: quizByTagContainerView)
        
        wordPairTableViewController = createWordPairTableViewController(inContainerView: searchResultsTableViewContainer)
        
        wordPairTableViewController.initialize(delegate: self)
        
    }
    
    private func isWordTableContracted() -> Bool{
        return hightConstraintOnGray.constant == originalHeightConstraintOnGray
    }
    
    private func isWordTableExpanded() -> Bool{
        return hightConstraintOnGray.constant == expandedHeightConstraintOnGray
    }
    
    private func showWordTable(){
        guard isWordTableContracted() else {
            print("already expanded")
            return
        }
        
        hightConstraintOnGray.constant = expandedHeightConstraintOnGray

        magifierCloseView.toggle()
        UIView.animate(withDuration: 1.2, delay: 0.2, options: [.curveEaseInOut], animations: { 
            self.view.layoutIfNeeded()
        }) { ( _ ) in
            //Nada
        }
        
    }
    
    private func hideWordTable(){
        guard isWordTableExpanded() else {
            print("already contracted")
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
        
        if text.isEmpty {
            hideWordTable()
        } else {
            controller.phrase = text
            showWordTable()
        }

        print(text)
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
    
    //Is there a better way to do this?  To detect that the transiton is complete?
    func transitionComplete() {
        browseByTagViewController.animateCollectionViewCellCreation = false
        quizByTagViewControler.animateCollectionViewCellCreation = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let toBrowseViewController = segue.destination as? BrowseViewController {
            guard let tag = sender as? Tag else { fatalError() }
            
            let browseController = BrowseController(tag: tag, wordOrder: controller.wordOrder, delegate: toBrowseViewController)
            
            toBrowseViewController.transitioningDelegate = self
            toBrowseViewController.controller = browseController
        }
    }
    
}


extension HomeViewController: UIViewControllerTransitioningDelegate {
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        print("Presenting \(presenting.description)")
        
        if let _ = presented as? BrowseViewController, let _ = source as? HomeViewController {
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
        default:
            fatalError()
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
    }
}

extension HomeViewController: WordPairTableDelegate {
    
}


