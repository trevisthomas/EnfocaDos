//
//  QuizFrontSubViewController.swift
//  Enfoca
//
//  Created by Trevis Thomas on 6/11/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import UIKit


class CardFrontViewController: UIViewController {

    @IBOutlet weak var termLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var bodyView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    
    private var sharedViewModel: QuizViewModel!
    
    fileprivate var animator: QuizCardAnimator = QuizCardAnimator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        termLabel.text = sharedViewModel.getFrontWord()
    }
    
    func initialize(viewModel: QuizViewModel){
        self.sharedViewModel = viewModel
    }


    @IBAction func okButtonAction(_ sender: EnfocaButton) {
        
        performFlip()
    }
    
    @IBAction func tappedAction(_ sender: UITapGestureRecognizer) {
        performFlip()
    }
    
    private func performFlip() {
        performSegue(withIdentifier: "QuizRearViewControllerSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let to = segue.destination as? CardRearViewController else { fatalError() }
        
        to.transitioningDelegate = self
        
        to.initialize(quizViewModel: sharedViewModel)
    }
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension CardFrontViewController: ChangeCardAnimatorTarget, QuizCardAnimatorTarget {
    func getView() -> UIView {
        return view
    }
    
    func getCardView() -> UIView {
        return bodyView
    }
    
    func rightNavButton() -> UIView? {
        return nil
    }
    
    func getTitleLabel() -> UIView? {
        return titleLabel
    }
}

//For animated transitions
extension CardFrontViewController: UIViewControllerTransitioningDelegate {
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {

        if let _ = presented as? CardRearViewController, let _ = source as? CardFrontViewController {
            
            animator.presenting = true
            return self.animator
        }
        
        return nil
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        
        if let _ = dismissed as? CardRearViewController {
            animator.presenting = false
            return animator
        }
        
        return nil
    }
}
