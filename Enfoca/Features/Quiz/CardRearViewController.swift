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
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var bodyView: UIView!
    
    private var delegate: CardViewControllerDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        definitionLabel.text = delegate.getRearWord()
    }
    
    func initialize(delegate: CardViewControllerDelegate){
        self.delegate = delegate
    }
    
    @IBAction func abortButtonAction(_ sender: UIButton) {
        performSegue(withIdentifier: "QuizResultsSegue", sender: self)
    }

    @IBAction func tappedAction(_ sender: UITapGestureRecognizer) {
        
        dismiss(animated: true) { 
            //whatever
        }
    }
    @IBAction func incorrectButtonAction(_ sender: EnfocaButton) {
        delegate.incorrect()
        showMatchingRound()
        
    }
    
    private func showMatchingRound() {
        performSegue(withIdentifier: "MatchingRoundSeque", sender: nil)
    }
    
    @IBAction func correctButtonAction(_ sender: EnfocaButton) {
        delegate.correct()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let to = segue.destination as? MatchingRoundViewController {
            to.initialize(delegate: delegate)
        }
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
