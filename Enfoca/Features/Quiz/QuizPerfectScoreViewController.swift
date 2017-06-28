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
    
    func initialize(sharedViewModel: QuizViewModel){
        self.sharedViewModel = sharedViewModel
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


