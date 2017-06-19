//
//  QuizRearSubViewController.swift
//  Enfoca
//
//  Created by Trevis Thomas on 6/11/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import UIKit


class CardRearViewController: UIViewController, HomeFromQuizAnimatorTarget {

    @IBOutlet weak var definitionLabel: UILabel!
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var bodyView: UIView!
    @IBOutlet weak var headerHightConstrant: NSLayoutConstraint!
    
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
        if sharedViewModel.isTimeForMatchingRound() {
            return "MatchingRoundSeque"
        } else {
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
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let to = segue.destination as? MatchingRoundViewController {
            to.initialize(sharedViewModel: sharedViewModel)
        } else if let to = segue.destination as? CardFrontViewController {
            to.initialize(viewModel: sharedViewModel)
        } else if let to = segue.destination as? QuizResultsViewController {
            to.initialize(sharedViewModel: sharedViewModel)
        } else if let to = segue.destination as? HomeViewController {
            to.transitioningDelegate = self
        }
    }
}

extension CardRearViewController: UIViewControllerTransitioningDelegate {
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        if let _ = presented as? HomeViewController, let _ = source as? CardRearViewController {
            return HomeFromQuizResultAnimator()
        }
        
        return nil
        
    }
}

extension CardRearViewController: QuizCardAnimatorTarget {
    func getBodyView() -> UIView {
        return bodyView
    }
    func getView() -> UIView {
        return view
    }
}
