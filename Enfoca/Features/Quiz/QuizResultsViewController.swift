//
//  QuizResultsViewController.swift
//  Enfoca
//
//  Created by Trevis Thomas on 6/11/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import UIKit

class QuizResultsViewController: UIViewController, HomeFromQuizAnimatorTarget {

    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var askedLabel: UILabel!
    @IBOutlet weak var correctLabel: UILabel!
    @IBOutlet weak var headerHightConstrant: NSLayoutConstraint!
    @IBOutlet weak var titleLabel: UILabel!
    private var sharedViewModel: QuizViewModel!
    
    @IBOutlet weak var contentBodyView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        correctLabel.text = "\(sharedViewModel.getCorrectCount())"
        askedLabel.text = "\(sharedViewModel.getWordsAskedCount())"
        scoreLabel.text = sharedViewModel.getScore()
    }
    
    func initialize(sharedViewModel: QuizViewModel){
        self.sharedViewModel = sharedViewModel
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let to = segue.destination as? HomeViewController {
            to.transitioningDelegate = self
        } else if let to = segue.destination as? CardFrontViewController {
            to.transitioningDelegate = self
            to.initialize(viewModel: sharedViewModel)
        }
        
        
    }
    @IBAction func showDetailedResultsAction(_ sender: Any) {
    }
    @IBAction func retryAction(_ sender: Any) {
        sharedViewModel.retry()
        performSegue(withIdentifier: "RetryQuizSegue", sender: nil)
    }
    @IBAction func doneAction(_ sender: Any) {
        performSegue(withIdentifier: "HomeSegue", sender: nil)
    }
    
    
}

extension QuizResultsViewController: UIViewControllerTransitioningDelegate {
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        if let _ = presented as? HomeViewController, let _ = source as? QuizResultsViewController {
            return HomeFromQuizResultAnimator()
        }
        
        if let _ = presented as? CardFrontViewController, let _ = source as? QuizResultsViewController {
            let animator = QuizResultsAnimator()
            animator.presenting = false
            return animator
        }
        
        return nil
        
    }
}

extension QuizResultsViewController: EnfocaDefaultAnimatorTarget {
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
