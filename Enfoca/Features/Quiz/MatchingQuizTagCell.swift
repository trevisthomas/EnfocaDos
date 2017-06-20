//
//  MatchingQuizTagCell.swift
//  Enfoca
//
//  Created by Trevis Thomas on 6/13/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import UIKit



class MatchingQuizTagCell: UICollectionViewCell {
    static let identifier: String = "MatchingQuizTagCell"
    
    @IBOutlet weak var titleLabel: UILabel!
    
    
    
    private var previousState: MatchingQuizState?
    private var initialized: Bool = false
    
    private var matchingPair: MatchingPair!
    private var incorrect: Bool = false
    
    private func applyColors(text: UIColor, background: UIColor) {
        self.backgroundColor = background
        self.titleLabel.textColor = text
    }
    
//    func initialize(){
//        initialized = true
//        refresh()
//    }
    
    func applyMatchingPair(matchingPair: MatchingPair, incorrect: Bool = false) {
        self.matchingPair = matchingPair
        self.incorrect = incorrect
        
        refresh()
    }
    
    private func refresh() {
//        guard initialized else { return }
        
        switch matchingPair.state {
        case .disabled:
            applyNormalColor(matchingPair: matchingPair)
            backgroundColor = backgroundColor?.withAlphaComponent(0.5)
        case .hidden:
            applyColors(text: Theme.lightness, background: Theme.gray)
        case .normal:
            if incorrect == true {
                wiggleAnimation()
            }
            applyNormalColor(matchingPair: matchingPair)
        case .selected:
            applyNormalColor(matchingPair: matchingPair)
            self.bounceAnimation()
        }
        
        previousState = matchingPair.state
    }
    
    func setTitle(_ title: String) {
        titleLabel.text = title
    }
    
    private func applyNormalColor(matchingPair: MatchingPair) {
        switch matchingPair.cardSide {
        case .definition:
            applyColors(text: Theme.lightness, background: Theme.green)
        case .term:
            applyColors(text: Theme.lightness, background: Theme.orange)
        default: fatalError()
        }
    }
    
    
    // a function to add a bit of snap. Just a quick bounce of the entire view.
    private func bounceAnimation() {
        UIView.animate(withDuration: 0.1, delay: 0.0, options: [.curveEaseIn], animations: {
            self.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }, completion: { (_ :Bool) in
            UIView.animate(withDuration: 0.33, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.0, options: [.curveEaseOut], animations: {
                self.transform = .identity
            }, completion: { (_ :Bool) in })
        })
    }
    
    private func wiggleAnimation() {
        UIView.animate(withDuration: 0.1, delay: 0.0, options: [.curveEaseIn], animations: {
            self.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }, completion: { (_ :Bool) in
            let originalX = self.frame.origin.x
            self.frame.origin.x = self.frame.origin.x - self.frame.height * 0.5
            UIView.animate(withDuration: 0.33, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.0, options: [.curveEaseOut], animations: {
                self.frame.origin.x = originalX
            }, completion: { (_ :Bool) in
                self.transform = .identity
            })
        })
    }
    
}
