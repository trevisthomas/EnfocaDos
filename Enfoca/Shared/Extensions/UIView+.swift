//
//  UIView+.swift
//  Enfoca
//
//  Created by Trevis Thomas on 6/30/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import UIKit

extension UIView {
    func jiggle(untilFalse: @escaping()->(Bool)){
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.33, delay: 0, options: [.curveEaseInOut], animations: {
            //
            
            UIView.animateKeyframes(withDuration: 1, delay: 0, options: [], animations: { 
                UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.25, animations: { 
                    self.transform = CGAffineTransform(rotationAngle: -.pi/64)
                })
                UIView.addKeyframe(withRelativeStartTime: 0.25, relativeDuration: 0.75, animations: {
                    self.transform = CGAffineTransform(rotationAngle: +.pi/64)
                })
                UIView.addKeyframe(withRelativeStartTime: 0.75, relativeDuration: 1.0, animations: {
                    self.transform = .identity
                })
            }, completion: nil)
            
        }) { (_: UIViewAnimatingPosition) in
            if untilFalse() {
                self.jiggle(untilFalse: untilFalse)
            }
        }
    }
}


//Clever
//https://stackoverflow.com/questions/28854469/change-uibutton-bordercolor-in-storyboard
extension UIView {
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
}
