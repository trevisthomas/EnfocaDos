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
    @IBOutlet weak var tableViewContainer: UIView!
    
    @IBOutlet weak var headerBackgroundView: UIView!
    
    fileprivate var editWordPairFromCellAnimator = EditWordPairFromCellAnimator()
    
    fileprivate var wordPairTableViewController: WordPairTableViewController!
    
    var controller : BrowseController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.text = controller.title()
        
        initializeSubViews()
        
        controller.loadWordPairs()
        
        getAppDelegate().activeController = controller
    }
    
    private func initializeSubViews() {
        
        wordPairTableViewController = createWordPairTableViewController(inContainerView: tableViewContainer)
        
        wordPairTableViewController.initialize(delegate: self)
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let editWordPairVC = segue.destination as? EditWordPairViewController  {
            guard let wordPair = sender as? WordPair else { fatalError() }
            
            editWordPairVC.transitioningDelegate = self
            
            editWordPairVC.controller = EditWordPairController(delegate: editWordPairVC, wordPair: wordPair)
        }
        
    }

}

extension BrowseViewController: BrowseControllerDelegate {
    func onBrowseResult(words: [WordPair]) {
        wordPairTableViewController.updateWordPairs(order: controller.wordOrder, wordPairs: words)
    }
    
    func onError(title: String, message: EnfocaError) {
        presentAlert(title: title, message: message)
    }
}

extension BrowseViewController: WordPairTableDelegate {
    func onWordPairSelected(wordPair: WordPair, atRect: CGRect, cell: UITableViewCell) {
        
        editWordPairFromCellAnimator.sourceCell = cell
        
        performSegue(withIdentifier: "WordPairEditorViewControllerSegue", sender: wordPair)
    }
}

//For animated transitions
extension BrowseViewController: UIViewControllerTransitioningDelegate {
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        print("Presenting \(presenting.description)")
        
        if let _ = presented as? EditWordPairViewController, let _ = source as? BrowseViewController {
            editWordPairFromCellAnimator.presenting = true
            return editWordPairFromCellAnimator
        }
        
        return nil
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        print("Dismissing \(dismissed.description)")
        
        if let _ = dismissed as? EditWordPairViewController {
            editWordPairFromCellAnimator.presenting = false
            return editWordPairFromCellAnimator
        }
        
        return nil
    }
}
