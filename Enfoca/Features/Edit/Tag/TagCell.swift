//
//  TagCell.swift
//  Enfoca
//
//  Created by Trevis Thomas on 1/15/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//
// Trevis! Note that you had to enable Clip Subviews on the cell view to fix that weird issue that  caused the stuff that was off the screen to stay clipped when deleting.
// This helped a bit http://vinsol.com/blog/2015/01/06/custom-edit-control-for-uitableviewcell/

import UIKit

protocol TagCellDelegate {
    func update(activityIndicator: ActivityIndicatable, tag: Tag, updatedTag: Tag, callback: @escaping (Bool)->())
    func validate(tag: Tag, newTagName: String?) -> Bool
    func presentColorSelector(colorSelectorDelegate: ColorSelectorViewControllerDelegate, source: UIView)
}


class TagCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBOutlet weak var tagSelectedView: CheckMarkView?
    @IBOutlet weak var tagSubtitleLabel: UILabel?
    @IBOutlet weak var tagTitleLabel: UILabel?
    @IBOutlet weak var colorButton: UIButton!
    
    
    @IBOutlet weak var createButton: UIButton!
//    @IBOutlet weak var primaryStackViewToTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var centerAlignYEditTagConstraint: NSLayoutConstraint! {
        didSet {
            centerAlignYEditTagConstraintOriginal = centerAlignYEditTagConstraint.constant
        }
    }
    
    @IBOutlet weak var topTagTitleConstraint: NSLayoutConstraint! {
        didSet{
            topTagTitleConstraintOriginal = topTagTitleConstraint.constant
        }
    }
    
    @IBOutlet var bottomSubTitleConstraint: NSLayoutConstraint! {
        didSet{
            bottomSubTitleConstraintOriginal = bottomSubTitleConstraint.constant
        }
    }
    
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var editTagTextField: UITextField!
    private var isTagEditing : Bool = false
    
    private var centerAlignYEditTagConstraintOriginal: CGFloat!
    private var topTagTitleConstraintOriginal: CGFloat!
    private var bottomSubTitleConstraintOriginal: CGFloat!
    
    var tagUpdateDelegate : TagCellDelegate?
    
    var sourceTag : Tag! {
        didSet {
            tagTitleLabel?.text = sourceTag.name
            tagSubtitleLabel?.text = formatDetailText(sourceTag.count)
            
            editTagTextField.addTarget(self, action: #selector(wordTextDidChange(_:)), for: [.editingChanged])
            
            colorButton.backgroundColor = sourceTag.uiColor
            
            invokeLater {
                self.applyTagEditingMode()
            }
        }
    }
    
    func initialize(isSelectionDisabled: Bool = false) {
        if isSelectionDisabled {
            //A shameless 30 second hack to totally hide the check mark when you're not in seelction mode.
            tagSelectedView?.isHidden = true
            tagSelectedView = nil
        }
    }
    
    func formatDetailText(_ count : Int ) -> String {
        if count == 0 {
            return ""
        } else if count == 1{
            return "One word tagged"
        } else {
            return "\(count) words tagged"
        }
    }
    
    @IBAction func changeColorAction() {
        tagUpdateDelegate?.presentColorSelector(colorSelectorDelegate: self, source: colorButton)
    }
    
    @IBAction func createButtonAction(_ sender: UIButton) {
        createButton?.isHidden = true
        guard let callback = createTagCallback else {return}
        guard let tagValue = tagTitleLabel?.text else {return}
        callback(self, tagValue, nil) //TODO, user Color
    }
    
    var createTagCallback : ((TagCell, String, String?)->())? = nil {
        didSet{
            createButton?.isHidden = createTagCallback == nil
            
            tagSelectedView?.isHidden = !(createButton!.isHidden)
        }
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        editButton.isHidden = !editing
        
        if(createButton!.isHidden) {
            tagSelectedView?.isHidden = editing
        }
        
        if isTagEditing {
            toggleTagEditor()
        }
    }
    
    @IBAction func editTagValueAction(_ sender: UIButton) {
        if sender.title(for: .normal) == "Edit" {
            toggleTagEditor()
        } else {
            
            guard let valid = tagUpdateDelegate?.validate(tag: sourceTag, newTagName: editTagTextField.text) else {
                    fatalError()
                }
            
            guard valid else {
                toggleTagEditor()
                return
            }
            
            tagTitleLabel?.text = editTagTextField.text
            toggleTagEditor()
            
//            tagUpdateDelegate?.update(activityIndicator: self, tag: sourceTag, newTagName: editTagTextField.text!)
            
            performUpdate(name: editTagTextField.text!, color: sourceTag.color)
        }
        
    }
    
    fileprivate func performUpdate(name: String, color: String? = nil, callback: @escaping (Bool) -> () = {_ in }) {
        let updatedTag = Tag(name: name, color: color)
        tagUpdateDelegate?.update(activityIndicator: self, tag: sourceTag, updatedTag: updatedTag, callback: callback)
    }
    
    func wordTextDidChange(_ textField: UITextField) {
        guard let valid = tagUpdateDelegate?.validate(tag: sourceTag, newTagName: editTagTextField.text) else {
            fatalError()
        }
        if valid {
            editButton.setTitle("Save", for: .normal)
        }
        else {
            editButton.setTitle("Done", for: .normal)
            return
        }

    }
    
    func toggleTagEditor() {
        
        isTagEditing = !isTagEditing
        
        applyTagEditingMode()
    }
    
    private func applyTagEditingMode(){
        layoutIfNeeded()
        
        
        if isTagEditing {
            editButton.setTitle("Done", for: .normal)
            
            centerAlignYEditTagConstraint.constant = centerAlignYEditTagConstraintOriginal
            topTagTitleConstraint.constant = topTagTitleConstraintOriginal + frame.height
            bottomSubTitleConstraint.isActive = false
            
            editTagTextField.text = tagTitleLabel?.text
        } else {
            editButton.setTitle("Edit", for: .normal)
            
            centerAlignYEditTagConstraint.constant = centerAlignYEditTagConstraintOriginal - frame.height
            topTagTitleConstraint.constant = topTagTitleConstraintOriginal
            bottomSubTitleConstraint.isActive = true
        }
        
        UIView.animate(withDuration: 0.5) {
            self.layoutIfNeeded()
        }
    }
    
    override func willTransition(to state: UITableViewCellStateMask) {
        if (state.contains(.showingDeleteConfirmationMask)){
//            editButton.setTitle("Woah", for: .normal)
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        tagSelectedView?.checked(selected, animated: animated)
    }
}

extension TagCell: ActivityIndicatable {
    func startActivity() {
        activityIndicator.startAnimating()
    }
    func stopActivity() {
        activityIndicator.stopAnimating()
    }
}

extension TagCell: ColorSelectorViewControllerDelegate {
    func selectedColor(color: String?) {
        performUpdate(name: sourceTag.name, color: color) {
            (success : Bool) in
            
            guard success else { return }
            
            if let color = color {
                self.colorButton.backgroundColor = UIColor(hexString: color)
            } else {
                self.colorButton.backgroundColor = nil
            }
            
        }
    }
}

