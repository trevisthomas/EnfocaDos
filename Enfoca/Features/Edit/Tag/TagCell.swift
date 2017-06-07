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

class TagCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBOutlet weak var tagSelectedView: UIView?
    @IBOutlet weak var tagSubtitleLabel: UILabel?
    @IBOutlet weak var tagTitleLabel: UILabel?
    
    
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var primaryStackViewToTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var editTagTextField: UITextField!
    private var isTagEditing : Bool = false
    var tagUpdateDelegate : TagCellDelegate?
    
    var sourceTag : Tag! {
        didSet {
            tagTitleLabel?.text = sourceTag.name
            tagSubtitleLabel?.text = formatDetailText(sourceTag.count)
        }
    }
    
    func formatDetailText(_ count : Int ) -> String {
        return "\(count) words tagged."
    }
    
    @IBAction func createButtonAction(_ sender: UIButton) {
        createButton?.isHidden = true
        guard let callback = createTagCallback else {return}
        guard let tagValue = tagTitleLabel?.text else {return}
        callback(self, tagValue)
    }
    
    var createTagCallback : ((TagCell, String)->())? = nil {
        didSet{
            createButton?.isHidden = createTagCallback == nil
        }
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        editButton.isHidden = !editing
        
        if isTagEditing {
            toggleTagEditor()
        }
    }
    
    @IBAction func editTagValueAction(_ sender: UIButton) {
        if sender.title(for: .normal) == "Edit" {
            toggleTagEditor()
        } else {
            
            guard let valid = tagUpdateDelegate?.validate(tag: sourceTag, newTagName: editTagTextField.text) else { return }
            
            guard valid else { return }
            
            print("Save")
            tagTitleLabel?.text = editTagTextField.text
            toggleTagEditor()
            
            tagUpdateDelegate?.update(tagCell: self, tag: sourceTag, newTagName: editTagTextField.text!)
        }
        
    }
    
    func toggleTagEditor() {
        layoutIfNeeded()
        
        isTagEditing = !isTagEditing
        if isTagEditing {
            editButton.setTitle("Save", for: .normal)
            primaryStackViewToTopConstraint.constant = -35
            editTagTextField.text = tagTitleLabel?.text
        } else {
            editButton.setTitle("Edit", for: .normal)
            primaryStackViewToTopConstraint.constant = 5
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

        // Configure the view for the selected state
        tagSelectedView?.isHidden = !selected
    }
}

protocol TagCellDelegate {
    func update(tagCell: TagCell, tag: Tag, newTagName: String)
    func validate(tag: Tag, newTagName: String?) -> Bool
}
