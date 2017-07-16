//
//  QuizPerfectScoreViewController.swift
//  Enfoca
//
//  Created by Trevis Thomas on 6/18/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import UIKit

class QuizPerfectScoreViewController: UIViewController {
    
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var headerHightConstrant: NSLayoutConstraint!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentBodyView: UIView!
    fileprivate var sharedViewModel: QuizViewModel!
    fileprivate var defaultAnimator: EnfocaDefaultAnimator = EnfocaDefaultAnimator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sharedViewModel.updateDataStoreCache()
    }
    
    @IBAction func okButtonAction(_ sender: Any) {
        performSegue(withIdentifier: "HomeSegue", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let to = segue.destination as? ModularHomeViewController {
            to.transitioningDelegate = self
        } else if let to = segue.destination as? BrowseViewController {
            to.transitioningDelegate = self
            let wordPairs = sharedViewModel.getAllWordPairs()
            to.initialize(wordPairs: wordPairs)
        }
    }
    
    @IBAction func showDetailedResultsAction(_ sender: Any) {
        performSegue(withIdentifier: "BrowseSegue", sender: nil)
    }
    
    func initialize(sharedViewModel: QuizViewModel){
        self.sharedViewModel = sharedViewModel
    }
}

extension QuizPerfectScoreViewController: UIViewControllerTransitioningDelegate {
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        if let _ = presented as? ModularHomeViewController, let _ = source as? QuizPerfectScoreViewController {
            return HomeFromQuizResultAnimator()
        }
        
        
        if let _ = presented as? BrowseViewController, let _ = source as? QuizPerfectScoreViewController {
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

extension QuizPerfectScoreViewController: EnfocaDefaultAnimatorTarget {
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
}

extension QuizPerfectScoreViewController: HomeFromQuizAnimatorTarget {
    func getHeaderHeight() -> CGFloat {
        return headerHightConstrant.constant
    }
}


