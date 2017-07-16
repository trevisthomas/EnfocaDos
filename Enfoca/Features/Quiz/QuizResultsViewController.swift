//
//  QuizResultsViewController.swift
//  Enfoca
//
//  Created by Trevis Thomas on 6/11/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import UIKit

class QuizResultsViewController: UIViewController {

    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var askedLabel: UILabel!
    @IBOutlet weak var correctLabel: UILabel!
    @IBOutlet weak var headerHightConstrant: NSLayoutConstraint!
    @IBOutlet weak var titleLabel: UILabel!
    private var sharedViewModel: QuizViewModel!
    fileprivate var defaultAnimator: EnfocaDefaultAnimator = EnfocaDefaultAnimator()
    
    @IBOutlet weak var contentBodyView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        correctLabel.text = "\(sharedViewModel.getCorrectCount())"
        askedLabel.text = "\(sharedViewModel.getWordsAskedCount())"
        scoreLabel.text = sharedViewModel.getScore()
        
        
        sharedViewModel.updateDataStoreCache()
    }
    
    func initialize(sharedViewModel: QuizViewModel){
        self.sharedViewModel = sharedViewModel
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let to = segue.destination as? ModularHomeViewController {
            to.transitioningDelegate = self
        } else if let to = segue.destination as? MatchingRoundViewController {
            to.transitioningDelegate = self
            to.initialize(sharedViewModel: sharedViewModel)
        } else if let to = segue.destination as? BrowseViewController {
            to.transitioningDelegate = self
            let wordPairs = sharedViewModel.getAllWordPairs()
            to.initialize(wordPairs: wordPairs)
        }
    }
    @IBAction func showDetailedResultsAction(_ sender: Any) {
        performSegue(withIdentifier: "BrowseSegue", sender: nil)
    }
    @IBAction func retryAction(_ sender: Any) {
        performSegue(withIdentifier: "MatchingReviewSegue", sender: nil)
    }
    @IBAction func doneAction(_ sender: Any) {
        performSegue(withIdentifier: "HomeSegue", sender: nil)
    }
    
    
}

extension QuizResultsViewController: UIViewControllerTransitioningDelegate {
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        if let _ = presented as? ModularHomeViewController, let _ = source as? QuizResultsViewController {
            return HomeFromQuizResultAnimator()
        }
        
        if let _ = presented as? CardFrontViewController, let _ = source as? QuizResultsViewController {
            let animator = QuizResultsAnimator()
            animator.presenting = false
            return animator
        }
        
        if let _ = presented as? MatchingRoundViewController, let _ = source as? QuizResultsViewController {
            return MatchingRoundAnimator()
        }
        
        if let _ = presented as? BrowseViewController {
            defaultAnimator.presenting = true
            return defaultAnimator
        }
        
        fatalError() //Becaue something is wrong
        
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        if let _ = dismissed as? BrowseViewController {
            defaultAnimator.presenting = false
            return defaultAnimator
        }
        return nil
    }
}

extension QuizResultsViewController: EnfocaDefaultAnimatorTarget, ChangeCardAnimatorTarget {
    func getRightNavView() -> UIView? {
        return nil
    }
    func getTitleView() -> UIView {
        return titleLabel
    }
    func getHeaderHeightConstraint() -> NSLayoutConstraint {
        return headerHightConstrant
    }
    func additionalComponentsToHide() -> [UIView]{
        return []
    }
    func getBodyContentView() -> UIView {
        return contentBodyView
    }
    
    func getCardView() -> UIView {
        return contentBodyView
    }
    func getView() -> UIView {
        return view
    }
    func rightNavButton() -> UIView? {
        return nil
    }
    func getTitleLabel() -> UIView? {
        return titleLabel
    }
}

extension QuizResultsViewController: HomeFromQuizAnimatorTarget {
    func getHeaderHeight() -> CGFloat {
        return headerHightConstrant.constant
    }
}



