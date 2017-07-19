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
    private var timer: Int!
    private var timerWarning: Int!
    private var timerActive: Bool = false
    
    private var startTime: Double!
    private var endTime: Double!
    
    fileprivate var animator: QuizCardAnimator = QuizCardAnimator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        termLabel.text = sharedViewModel.getFrontWord()
        
        startTheTimer()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.timerLabel.isHidden = true
    }
    
    func initialize(viewModel: QuizViewModel){
        self.sharedViewModel = viewModel
        
        timer = sharedViewModel.getCardTimeout()
        timerWarning = sharedViewModel.getCardTimeoutWarning()
    }

    @IBAction func okButtonAction(_ sender: EnfocaButton) {
        performFlip()
    }
    
    @IBAction func tappedAction(_ sender: UITapGestureRecognizer) {
        performFlip()
    }
    
    private func performFlip() {
        stopTheTimer()
        let elapsedMiliseconds = Int(endTime - startTime)
        
        sharedViewModel.timeTakenForCardInMiliSeconds = elapsedMiliseconds
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
    
    private func startTheTimer() {
        timerActive = true
        self.timerLabel.isHidden = true
        
        startTime = Date().miliSeconds
        
        perSecondTimer { () -> (Bool) in
            self.timer = self.timer - 1
            
            if self.timer < self.timerWarning {
                self.timerLabel.isHidden = false
                guard let t = self.timer else { fatalError() }
                self.timerLabel.text = "\(t)"
                CustomAnimations.animatePopIn(target: self.timerLabel, delay: 0.0, duration: 0.33)
                
                
            }
            
            if self.timer == 0 {
                self.performFlip()
            }
            
            return (self.timer > 0) && self.timerActive
        }
    }
    
    private func stopTheTimer() {
        self.endTime = Date().miliSeconds
        timerActive = false
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
