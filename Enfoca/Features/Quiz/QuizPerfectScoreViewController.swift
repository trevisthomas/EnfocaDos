//
//  QuizPerfectScoreViewController.swift
//  Enfoca
//
//  Created by Trevis Thomas on 6/18/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import UIKit

class QuizPerfectScoreViewController: UIViewController, HomeFromQuizAnimatorTarget {

    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var headerHightConstrant: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func okButtonAction(_ sender: Any) {
        performSegue(withIdentifier: "HomeSegue", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let to = segue.destination as? HomeViewController {
            to.transitioningDelegate = self
        }
    }
}

extension QuizPerfectScoreViewController: UIViewControllerTransitioningDelegate {
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        guard let _ = presented as? HomeViewController, let _ = source as? QuizPerfectScoreViewController else {
            fatalError()
        }
        
        return HomeFromQuizResultAnimator()
    }
}
    


