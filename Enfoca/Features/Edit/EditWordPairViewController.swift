//
//  WordPairEditorViewController.swift
//  Enfoca
//
//  Created by Trevis Thomas on 5/29/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import UIKit

class EditWordPairViewController: UIViewController {
    var controller: EditWordPairController!
    fileprivate var tagViewController: TagSelectionViewController!

    @IBOutlet weak var tagSummaryLabel: UILabel!
    @IBOutlet weak var englishTextField: UITextField!
    @IBOutlet weak var spanishTextField: UITextField!
    
    @IBOutlet weak var tagContainerView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()

        initializeLookAndFeel()
        initializeSubViews()
        
        controller.initialize()
        
        getAppDelegate().activeController = controller
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func cancelButtonAction(_ sender: Any) {
        dismiss(animated: true) {
            //done
        }
    }
    
    private func initializeLookAndFeel() {
        updateFields()
    }
    
    private func initializeSubViews(){
        tagViewController = createTagSelectionViewController(inContainerView: tagContainerView)
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    fileprivate func updateFields(){
        title = controller.title()
        tagSummaryLabel.text = controller.tagsAsString()
    }

}

extension EditWordPairViewController: EditWordPairControllerDelegate {
    func onError(title: String, message: EnfocaError) {
        self.presentAlert(title: title, message: message)
    }

    func onTagsLoaded(tags: [Tag], selectedTags: [Tag]) {
        tagViewController.initialize(tags: tags, selectedTags: selectedTags, delegate: self)
    }
    
    func onUpdate() {
        updateFields()
    }
}

extension EditWordPairViewController: WordTagSelectionDelegate {
    func onTagSelected(tag: Tag){
        controller.addTag(tag: tag)
    }
    
    func onTagDeselected(tag: Tag) {
        controller.removeTag(tag: tag)
    }
}


