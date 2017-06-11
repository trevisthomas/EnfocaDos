//
//  QuizFrontSubViewController.swift
//  Enfoca
//
//  Created by Trevis Thomas on 6/11/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import UIKit


protocol CardViewControllerDelegate {
    func getRearWord() -> String
    func getFrontWord() -> String
    func correct()
    func incorrect()
}


class CardFrontViewController: UIViewController {

    @IBOutlet weak var termLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var bodyView: UIView!
    
    private var delegate: CardViewControllerDelegate!
    
    fileprivate var animator: QuizCardAnimator = QuizCardAnimator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        termLabel.text = delegate.getFrontWord()
    }
    
    func initialize(delegate: CardViewControllerDelegate){
        self.delegate = delegate
    }


    @IBAction func okButtonAction(_ sender: EnfocaButton) {
        
        performSegue(withIdentifier: "QuizRearViewControllerSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let to = segue.destination as? CardRearViewController else { fatalError() }
        
        to.transitioningDelegate = self
        
        to.initialize(delegate: delegate)
    }
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension CardFrontViewController: QuizCardAnimatorTarget {
    func getBodyView() -> UIView {
        return bodyView
    }
    func getView() -> UIView {
        return view
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
