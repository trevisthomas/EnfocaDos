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
    @IBOutlet weak var headerHightConstrant: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func closeButtonAction(_ sender: UIButton) {
        performSegue(withIdentifier: "HomeSegue", sender: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let to = segue.destination as? HomeViewController {
            to.transitioningDelegate = self
        }
    }
}

extension QuizResultsViewController: UIViewControllerTransitioningDelegate {
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        guard let _ = presented as? HomeViewController, let _ = source as? QuizResultsViewController else {
            fatalError()
        }
        
        return HomeFromQuizResultAnimator()
    }
}
