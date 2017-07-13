//
//  TagFilterViewController.swift
//  Enfoca
//
//  Created by Trevis Thomas on 12/28/16.
//  Copyright © 2016 Trevis Thomas. All rights reserved.
//

import UIKit

protocol TagFilterViewControllerDelegate {
//    func tagFilterUpdated(_ callback: (() -> ())?)
    var selectedTags : [Tag] {get set}
//    func getSelectedTags()->[Tag]
//    func onSelectedTagsChanged(tags: [Tag])
}

class TagFilterViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tagSummaryLabel: UILabel!
    @IBOutlet weak var editDoneButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    
    @IBOutlet weak var searchOrCreateTextField: UITextField!
    private var tagFilterDelegate : TagFilterViewControllerDelegate?
    
    @IBOutlet weak var headerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var searchMagnifierView: MagnifierCloseView!
    var viewModel : TagFilterViewModel!

    @IBOutlet weak var titleLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = TagFilterViewModel()
        
        initLookAndFeel()
        
        if let tagFilterDelegate = tagFilterDelegate {
            viewModel.initialize(delegate: self, selectedTags: tagFilterDelegate.selectedTags) {
                self.updateSelectedSummary()
                self.tableView.reloadData() // Not unit tested :-(
            }
        } else {
            viewModel.initialize(delegate: self, selectedTags: []) {
                self.updateSelectedSummary()
                self.tableView.reloadData() // Not unit tested :-(
            }
        }
        
        getAppDelegate().addListener(listener: viewModel)
        
    }
    
    func initialize(delegate : TagFilterViewControllerDelegate? = nil){
        self.tagFilterDelegate = delegate
    }
    
    private func initLookAndFeel(){
        
        searchMagnifierView.initialize()
        searchMagnifierView.isSearchMode = true
        
        searchOrCreateTextField.addTarget(self, action: #selector(searchOrCreateTextDidChange(_:)), for: [.editingChanged])
        
        searchOrCreateTextField.addTarget(self, action: #selector(searchOrCreateTextEditingDidEnd(_:)), for: [.editingDidEnd])
        
        
        searchOrCreateTextField.addTarget(self, action: #selector(searchOrCreateTextDidBegin(_:)), for: [.editingDidBegin])
        
        searchOrCreateTextField.setPlaceholderTextColor(color: UIColor(hexString: "#ffffff", alpha: 0.19))
        
        tagSummaryLabel.isHidden = isSelectionDisabled()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 96 //Doesn't matter
        
        hideKeyboardWhenTappedAround()
    }
    
    fileprivate func isSelectionDisabled() -> Bool {
        return tagFilterDelegate == nil
    }
    
    @IBAction func tappedMagnifierCloseAction(_ sender: Any) {
        searchOrCreateTextField.text = nil
        searchOrCreateTextDidChange(searchOrCreateTextField)
    }
    
    func searchOrCreateTextDidChange(_ textField: UITextField) {
        guard let text = textField.text else { return }
        viewModel.searchTagsFor(prefix: text)
        tableView.reloadData()
        updateMagnifier(text)
        
        
        if !text.isEmpty {
            exitEditMode()
        }
    }
    
    
    
    func searchOrCreateTextDidBegin(_ textField: UITextField) {
        
        updateMagnifier(textField.text)
    }
    
    func searchOrCreateTextEditingDidEnd(_ textField: UITextField) {
        dismissKeyboard()
        updateMagnifier(textField.text)
    }

    func updateMagnifier(_ text: String?){
        let text = text ?? ""
        if  !text.isEmpty{
            searchMagnifierView.setSearchModeIfNeeded(false)
        } else {
            searchMagnifierView.setSearchModeIfNeeded(true)
        }

    }

    @IBAction func applyFilterAction(_ sender: UIButton) {
        tagFilterDelegate?.selectedTags = viewModel.getSelectedTags()
        
        self.dismiss(animated: true, completion: nil) //I dont know how to unit test this dismiss
    }
    
    fileprivate func updateSelectedSummary(){
        let selected = viewModel.getSelectedTags()
        
        guard selected.count > 0 else {
            tagSummaryLabel.text = "Selected: (none)"
            return
        }
        tagSummaryLabel.text = "Selected: \(selected.tagsToText())"
    }

    var selectedPaths : [IndexPath] = []
    @IBAction func editDoneButtonAction(_ sender: Any) {
        if tableView.isEditing {
            exitEditMode()
        } else {
            enterEditMode()
        }
    }
    
    private func exitEditMode() {
        doneButton.isHidden = false
        tableView.setEditing(false, animated: true)
        editDoneButton.setTitle("Edit", for: .normal)
        for path in selectedPaths {
            tableView.selectRow(at: path, animated: false, scrollPosition: .none)
        }
    }
    
    private func enterEditMode() {
        doneButton.isHidden = true
        editDoneButton.setTitle("Cancel", for: .normal)
        if let paths = tableView.indexPathsForSelectedRows {
            selectedPaths = paths
        }
        tableView.setEditing(true, animated: true)
    }
    
}

extension TagFilterViewController : TagFilterViewModelDelegate{
    func selectedTagsChanged() {
        updateSelectedSummary()
    }
    
    func reloadTable() {
        searchOrCreateTextField.text = nil
        tableView.reloadData()
    }
    
    func alert(title: String, message: String) {
        presentAlert(title: title, message : message)
    }
}

extension TagFilterViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.tableView(tableView, numberOfRowsInSection: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = viewModel.tableView(tableView, cellForRowAt: indexPath) as! TagCell
        
        cell.initialize(isSelectionDisabled: isSelectionDisabled())
        
        return cell
    }
    
    
}

extension TagFilterViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        viewModel.tableView(tableView, commit: editingStyle, forRowAt: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return viewModel.tableView(tableView, willSelectRowAt: indexPath)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.tableView(tableView, didSelectRowAt: indexPath)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        viewModel.tableView(tableView, didDeselectRowAt: indexPath)
    }

}

extension TagFilterViewController: EnfocaDefaultAnimatorTarget {
    
    func getRightNavView() -> UIView? {
        return doneButton
    }
    func getTitleView() -> UIView {
        return titleLabel
    }
    func getHeaderHeightConstraint() -> NSLayoutConstraint {
        return headerHeightConstraint
    }
    func additionalComponentsToHide() -> [UIView] {
        return [editDoneButton, searchOrCreateTextField, tagSummaryLabel]
    }
    func getBodyContentView() -> UIView {
        return tableView
    }
    
}
