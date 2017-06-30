//
//  AnimatedLabelTextField.swift
//  MobileTTDC
//
//  Created by Trevis Thomas on 12/18/16.
//  Copyright © 2016 Trevis Thomas. All rights reserved.
//

import UIKit

class AnimatedTextField: UITextField, UITextFieldDelegate {
    private var label : UILabel!
    
    var labelScale : CGFloat = 0.45
    var textInset : CGFloat = 6.0
    var placeHolderColor = UIColor.black {
        didSet {
            label.textColor = placeHolderColor
        }
    }
    var placeHolderAlpha : CGFloat = 0.2
    var borderHighlightColor : UIColor = UIColor.orange
    //var borderHighlightColor : UIColor = UIColor(hexString: "#A8D379")
    //    var borderDefaultColor : UIColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1)
    var borderDefaultColor : UIColor = UIColor.gray.withAlphaComponent(0.3)
    var defaultBackgroundColor : UIColor = UIColor.clear
    private var placeholderTextBackup : String?
    
    private var placeholderRect : CGRect = CGRect.zero
    private var labelRect : CGRect = CGRect.zero
    var inLabelMode : Bool = false
    
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        clipsToBounds = false
        placeholderTextBackup = placeholder
        
        setup()
    }
    
    //    override func awakeFromNib() {
    //        super.awakeFromNib()
    //        setup()
    //    }
    
    func setup() {
        
        delegate = self
        
        label = UILabel(frame: CGRect(x: textInset, y: bounds.origin.y, width: bounds.width, height: bounds.height))
        
        label.font = self.font
        
        placeholderRect = label.bounds
        labelRect = CGRect(x: 0, y: -(self.bounds.height * 0.45), width: placeholderRect.width, height: placeholderRect.height)
        
        
        label.textAlignment = NSTextAlignment.left
        
        label.text = placeholder
        label.textColor = placeHolderColor
        label.alpha = placeHolderAlpha
        self.addSubview(label)
        placeholder = nil
        
        self.layer.borderWidth = 0.5
        self.layer.borderColor = borderDefaultColor.cgColor
        
        self.layer.cornerRadius = 5
        self.borderStyle = .roundedRect
        
        label.layer.setRotationPoint(rotationPoint: CGPoint(x: 0, y: 0))
        
//        self.addTarget(self, action: #selector(textFieldValueChanged(_:)), for: .valueChanged)
        
    }
    
    //I really didnt want to do this but, im wasting time.  Overidding text breaks the baseclass.  I just wanted to know when the text was set programatically!
    func initialize() {
        textFieldDidEndEditing(self)
    }
    
    override var text: String? {
        didSet {
            textFieldDidEndEditing(self)
        }
    }
    
    
    override var placeholder: String? {
        didSet {
            placeholderTextBackup = placeholder
            textFieldDidEndEditing(self)
        }
    }
    
//    func textFieldValueChanged(_ textField: UITextField) {
//                textFieldDidEndEditing(self)
//            }
//    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("End")
        borderColorToDefault()
        
        guard let t = self.text else {
            showAsPlaceholder()
            return
        }
        
        if t.isEmpty {
            showAsPlaceholder()
        } else {
            showAsLabel()
        }
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("Begin")
        showAsLabel()
        highligtBorderColor()
        
    }
    
    
    func showAsPlaceholder() {
        print("as showAsPlaceholder")
        guard inLabelMode == true else {
            return //In progress, or already in label
        }
        
        inLabelMode = false
        
        UIView.animate(withDuration: 0.25, delay: 0.0, options: [.curveEaseOut], animations: {
            self.label.alpha = self.placeHolderAlpha
            self.label.transform = CGAffineTransform(scaleX: 1.0, y: 1.0).concatenating (
                CGAffineTransform(translationX: self.placeholderRect.origin.x, y: self.placeholderRect.origin.y)
            )
            self.label.text = self.placeholderTextBackup
            self.layer.borderColor = self.borderDefaultColor.cgColor
            
        }, completion: nil)
        
    }
    
    func borderColorToDefault(){
        UIView.animate(withDuration: 0.25, delay: 0.0, options: [.curveEaseOut], animations: {
            self.layer.borderColor = self.borderDefaultColor.cgColor
            
        }, completion: nil )
    }
    
    func highligtBorderColor(){
        UIView.animate(withDuration: 0.2, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.0, options: [.curveEaseIn], animations: {
            
            self.layer.borderColor = self.borderHighlightColor.cgColor
            self.backgroundColor = self.borderHighlightColor.withAlphaComponent(0.05)
            
        }, completion: {
            _ in
            UIView.animate(withDuration: 0.7, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 3.0, options: [.curveEaseIn], animations: {
                self.backgroundColor = self.defaultBackgroundColor
            }, completion:nil)
            
        })
    }
    
    func showAsLabel() {
        print("as label")
        guard inLabelMode == false else {
            return //In progress, or already in label
        }
        
        inLabelMode = true
        
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1.0, options: [.curveEaseIn], animations: {
            
            self.label.alpha = 1.0
            
            self.label.transform = CGAffineTransform(scaleX: self.labelScale, y: self.labelScale).concatenating (
                CGAffineTransform(translationX: self.labelRect.origin.x, y: self.labelRect.origin.y)
            )
            
            if let t = self.placeholderTextBackup {
                self.label.text = "\(t):"
            }
            
        }, completion: {
            _ in
            //            self.layer.borderColor = self.highlightColor.cgColor
            //            delay(seconds: 2) {
            //                self.showAsPlaceholder()
            //            }
            
        })
        
        
        
        
    }
    
}

extension AnimatedTextField {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        let nextTag = textField.tag+1;
//        
//        if let loginButton = textField.superview?.viewWithTag(nextTag) as? UIButton!{
//            loginButton.sendActions(for: UIControlEvents.touchUpInside)
//        } else if let nextResponder=textField.superview?.viewWithTag(nextTag) as UIResponder!{
//            nextResponder.becomeFirstResponder()
//        } else {
//            textField.resignFirstResponder()
//        }
//        return false // We do not want UITextField to insert line-breaks.
//        return false 
        
        textField.endEditing(true)
        return false
    }
}
