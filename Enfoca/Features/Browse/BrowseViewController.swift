//
//  BrowseViewController.swift
//  Enfoca
//
//  Created by Trevis Thomas on 5/25/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import UIKit

class BrowseViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var quizButton: UIButton!
    @IBOutlet weak var tableViewContainer: UIView!
    @IBOutlet weak var underSidePlaceHolderForWordEditor: UIView!
    
    @IBOutlet weak var headerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var headerBackgroundView: UIView!
    
//    fileprivate var editWordPairFromCellAnimator = EditWordPairFromCellAnimator()
    
    fileprivate var editWordPairAnimator = EnfocaDefaultAnimator()
    
    fileprivate var wordPairTableViewController: WordPairTableViewController!
    
    fileprivate var controller : BrowseController!
    
    private var showQuizButton: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.text = controller.title()
        
        initializeLookAndFeel()
        
        initializeSubViews()
        
//        getAppDelegate().addListener(listener: controller)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        controller.loadWordPairs()
    }
    
    func initialize(tag: Tag, wordOrder: WordPairOrder, showBackButton: Bool = false){
        controller = BrowseController(tag: tag, wordOrder: wordOrder, delegate: self)
        self.showQuizButton = showBackButton
    }
    
    func initialize(wordPairs: [WordPair]) {
        sortByScore(wordPairs: wordPairs, callback: { sortedWordPairs in
            self.controller = BrowseController(wordPairs: sortedWordPairs, delegate: self)
            self.showQuizButton = false
        })
    }
    
    private func sortByScore(wordPairs: [WordPair], callback: @escaping ([WordPair])->()) {
        
        fetchMetaData(forWordPairs: wordPairs) { (metaDict: [String : MetaData?]) in
            let sorted = wordPairs.sorted(by: { (wp1:WordPair, wp2:WordPair) -> Bool in
                guard let meta1 = metaDict[wp1.pairId] as? MetaData else {
                    return false
                }
                
                guard let meta2 = metaDict[wp2.pairId] as? MetaData else {
                    return true
                }
                
                return meta1.score > meta2.score
            })
            callback(sorted)
        }
    }
    
    private func initializeSubViews() {
        
        wordPairTableViewController = createWordPairTableViewController(inContainerView: tableViewContainer)
        
        wordPairTableViewController.initialize(delegate: self, order: controller.wordOrder)
        
//        let emptyEditorViewController = createEditorViewController(inContainerView: underSidePlaceHolderForWordEditor)
    }
    
    private func initializeLookAndFeel() {
        quizButton.isHidden = !showQuizButton
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func doneButtonAction(_ sender: Any) {
        dismiss(animated: true) { 
            //done
        }
    }
    
    @IBAction func presentQuizAction(_ sender: Any) {
        performSegue(withIdentifier: "QuizSegue", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let to = segue.destination as? EditWordPairViewController  {
            guard let sourceWordPair = sender as? WordPair else { fatalError() }
            to.transitioningDelegate = self
            
            to.initialize(delegate: self, wordPair: sourceWordPair)
            
        } else if let to = segue.destination as? QuizOptionsViewController {
            to.initialize(delegate: self)
        }
    }
    
    private func fetchMetaData(forWordPairs: [WordPair], callback: @escaping ([String: MetaData?])->()) {
        var metaDataDict: [String: MetaData] = [:]
        for wordPair in forWordPairs {
            getAppDelegate().webService.fetchMetaData(forWordPair: wordPair) { (metaData: MetaData?, error) in
                metaDataDict[wordPair.pairId] = metaData
                
                if metaDataDict.count == forWordPairs.count {
                    callback(metaDataDict)
                }
            }
        }
    }

}

extension BrowseViewController: EditWordPairViewControllerDelegate {
    func isCreateMode() -> Bool {
        return false
    }
    func getCreateText() -> String {
        fatalError()
    }
    func getWordPairOrder() -> WordPairOrder {
        fatalError()
    }
    
}

extension BrowseViewController: BrowseControllerDelegate {
    func onBrowseResult(words: [WordPair]) {
        titleLabel.text = controller.title() //Because sometimes this is called because the currently viewd tag was updated.
        wordPairTableViewController.updateWordPairs(order: controller.wordOrder, wordPairs: words)
    }
    
    func onError(title: String, message: EnfocaError) {
        presentAlert(title: title, message: message)
    }
    
    func scrollToWordPair(wordPair: WordPair) {
        wordPairTableViewController.scrollToWordPair(wordPair: wordPair)
    }
}

extension BrowseViewController: WordPairTableDelegate {
    func onCreate(atRect: CGRect, cell: UITableViewCell) {
        fatalError("Creating from browse is not implemented")
    }

    func onWordPairSelected(wordPair: WordPair, atRect: CGRect, cell: UITableViewCell) {
//        editWordPairFromCellAnimator.sourceCell = cell
        //Tap Bounce?
        performSegue(withIdentifier: "WordPairEditorViewControllerSegue", sender: wordPair)
    }
}

//For animated transitions
extension BrowseViewController: UIViewControllerTransitioningDelegate {
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        if let _ = presented as? EditWordPairViewController, let _ = source as? BrowseViewController {
            editWordPairAnimator.presenting = true
            return editWordPairAnimator
        }
        
        return nil
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        if let _ = dismissed as? EditWordPairViewController {
            editWordPairAnimator.presenting = false
            return editWordPairAnimator
        }
        
        return nil
    }
}

extension BrowseViewController: EnfocaHeaderViewAnimationTarget {
    func getView() -> UIView {
        return view
    }
    func getHeaderBackgroundView() -> UIView {
        return headerBackgroundView
    }
}

extension BrowseViewController: EnfocaDefaultAnimatorTarget {
    
    func getRightNavView() -> UIView? {
        return doneButton
    }
    func getTitleView() -> UIView {
        return titleLabel
    }
    func getHeaderHeightConstraint() -> NSLayoutConstraint {
        return headerHeightConstraint
    }
    func additionalComponentsToHide() -> [UIView] {
        return []
    }
    func getBodyContentView() -> UIView {
        return tableViewContainer
    }
    
}

extension BrowseViewController: QuizViewControllerDelegate {
    func tagSelectedForQuiz() -> Tag {
        return controller.tag
    }
}
