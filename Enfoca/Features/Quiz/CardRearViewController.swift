//
//  QuizRearSubViewController.swift
//  Enfoca
//
//  Created by Trevis Thomas on 6/11/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import UIKit


class CardRearViewController: UIViewController {

    @IBOutlet weak var definitionLabel: UILabel!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var bodyView: UIView!
    @IBOutlet weak var headerHightConstrant: NSLayoutConstraint!
    
    @IBOutlet weak var abortButton: UIButton!
    
    private var sharedViewModel: QuizViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        definitionLabel.text = sharedViewModel.getRearWord()
        
    }
    
    func initialize(quizViewModel: QuizViewModel){
        self.sharedViewModel = quizViewModel
    }
    
    @IBAction func abortButtonAction(_ sender: UIButton) {
        performSegue(withIdentifier: "HomeSegue", sender: self)
    }

    @IBAction func tappedAction(_ sender: UITapGestureRecognizer) {
        
        dismiss(animated: true) { 
            //whatever
        }
    }
    @IBAction func incorrectButtonAction(_ sender: EnfocaButton) {
        sharedViewModel.incorrect()
        performSegue(withIdentifier: decideWhichSegueToPerform(), sender: self)
    }
    
    @IBAction func correctButtonAction(_ sender: EnfocaButton) {
        sharedViewModel.correct()
        performSegue(withIdentifier: decideWhichSegueToPerform(), sender: self)
    }
    
    private func decideWhichSegueToPerform() -> String{

        if sharedViewModel.isFinished() {
            if sharedViewModel.isRetrySuggested() {
                return "QuizResultsSegue"
            } else {
                return "QuizPerfectScoreResultsSegue"
            }
        } else {
            return "CardFrontWithNewWordSegue"
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let to = segue.destination as? MatchingRoundViewController {
            to.transitioningDelegate = self
            to.initialize(sharedViewModel: sharedViewModel)
        } else if let to = segue.destination as? CardFrontViewController {
            to.transitioningDelegate = self
            to.initialize(viewModel: sharedViewModel)
        } else if let to = segue.destination as? QuizResultsViewController {
            to.transitioningDelegate = self
            to.initialize(sharedViewModel: sharedViewModel)
        } else if let to = segue.destination as? ModularHomeViewController {
            to.transitioningDelegate = self
        } else if let to = segue.destination as? QuizPerfectScoreViewController {
            to.transitioningDelegate = self
            to.initialize(sharedViewModel: sharedViewModel)
        }
    }
    
}

extension CardRearViewController: UIViewControllerTransitioningDelegate {
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        if let _ = presented as? ModularHomeViewController, let _ = source as? CardRearViewController {
            return HomeFromQuizResultAnimator()
        }
        
        if let _ = presented as? CardFrontViewController, let _ = source as? CardRearViewController {
            return ChangeCardAnimator()
        }
        
        if let _ = presented as? MatchingRoundViewController, let _ = source as? CardRearViewController {
            return MatchingRoundAnimator()
        }
        
        if let _ = presented as? QuizResultsViewController, let _ = source as? CardRearViewController {
            return QuizResultsAnimator()
        }
        
        if let _ = presented as? QuizPerfectScoreViewController, let _ = source as? CardRearViewController {
            return QuizResultsAnimator()
        }
        
        return nil
        
    }
}

extension CardRearViewController: ChangeCardAnimatorTarget, QuizCardAnimatorTarget {
    func getView() -> UIView {
        return view
    }
    
    func getCardView() -> UIView {
        return bodyView
    }
    
    func rightNavButton() -> UIView? {
        return abortButton
    }
    
    func getTitleLabel() -> UIView? {
        return titleLabel
    }
    
}

extension CardRearViewController: HomeFromQuizAnimatorTarget {
    func getHeaderHeight() -> CGFloat {
        return headerHightConstrant.constant
    }
}
