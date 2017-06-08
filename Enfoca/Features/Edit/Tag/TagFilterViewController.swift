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
    @IBOutlet weak var applyButton: UIButton!
    
    @IBOutlet weak var searchOrCreateTextField: UITextField!
    var tagFilterDelegate : TagFilterViewControllerDelegate!
    
    @IBOutlet weak var searchMagnifierView: MagnifierCloseView!
    var viewModel : TagFilterViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = TagFilterViewModel()
        
        initLookAndFeel()
        
        
        viewModel.initialize(delegate: self, selectedTags: tagFilterDelegate.selectedTags) {
            self.updateSelectedSummary()
            self.tableView.reloadData() // Not unit tested :-(
        }
        
        getAppDelegate().addListener(listener: viewModel)
        
    }
    
    private func initLookAndFeel(){
        
        searchMagnifierView.initialize()
        searchMagnifierView.isSearchMode = true
        
        searchOrCreateTextField.addTarget(self, action: #selector(searchOrCreateTextDidChange(_:)), for: [.editingChanged])
        
        searchOrCreateTextField.addTarget(self, action: #selector(searchOrCreateTextEditingDidEnd(_:)), for: [.editingDidEnd])
        
        
        searchOrCreateTextField.addTarget(self, action: #selector(searchOrCreateTextDidBegin(_:)), for: [.editingDidBegin])
        
        searchOrCreateTextField.setPlaceholderTextColor(color: UIColor(hexString: "#ffffff", alpha: 0.19))
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 96 //Doesn't matter
        
        hideKeyboardWhenTappedAround()
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

//    private func applyFilter(){
//        //Clear out the delegates selecions
////        tagFilterDelegate.selectedTags = []
//        
////        viewModel.applySelectedTagsToDelegate()
//        
//        
////        tagFilterDelegate.tagFilterUpdated(nil)
//        
//        tagFilterDelegate.selectedTags = viewModel.getSelectedTags()
//    }
    
    @IBAction func applyFilterAction(_ sender: UIButton) {
        tagFilterDelegate.selectedTags = viewModel.getSelectedTags()
        
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
            tableView.setEditing(false, animated: true)
            editDoneButton.setTitle("Edit", for: .normal)
            for path in selectedPaths {
                tableView.selectRow(at: path, animated: false, scrollPosition: .none)
            }
        } else {
            editDoneButton.setTitle("Done", for: .normal)
            if let paths = tableView.indexPathsForSelectedRows {
                selectedPaths = paths
            }
            tableView.setEditing(true, animated: true)
        }
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
        return viewModel.tableView(tableView, cellForRowAt: indexPath)
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
