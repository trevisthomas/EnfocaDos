//
//  DictionarySelectionViewController.swift
//  Enfoca
//
//  Created by Trevis Thomas on 6/26/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import UIKit


class DictionarySelectionViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var editButton: UIButton!
    
    @IBOutlet weak var headerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bodyView: UIView!
    
    fileprivate var dictionaryList: [UserDictionary] = []
    fileprivate var isEditMode: Bool = false
    fileprivate let animator = EnfocaDefaultAnimator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Clearing out current device cache!
        getAppDelegate().applicationDefaults.clearUserDefauts()
        
        initializeLookAndFeel()
        
        tableView.reloadData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
        initializeLookAndFeel()
    }
    
    private func initializeLookAndFeel() {
        tableView.separatorStyle = .none
        if isEditMode {
            editButton.setTitle("Done", for: .normal)
        } else {
            editButton.setTitle("Edit", for: .normal)
        }
    }
    
    
    func initialize(dictionaryList: [UserDictionary]) {
        self.dictionaryList = dictionaryList
    }
    
    @IBAction func newSubjectAction(_ sender: Any) {
        performSegue(withIdentifier: "DictionaryCreationSegue", sender: nil)
    }
    
    @IBAction func editButtonAction(_ sender: Any) {
        toggleEditMode()
    }
    
    func toggleEditMode(){
        isEditMode = !isEditMode
        initializeLookAndFeel()
        tableView.setEditing(isEditMode, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let to = segue.destination as? DictionaryEditorViewController {
            guard let dictionary = sender as? UserDictionary else { fatalError() }
            to.transitioningDelegate = self
            to.initialize(dictionary: dictionary, isLanguageSelectionAvailable: dictionary.language != nil)
            
        } else if let to = segue.destination as? DictionaryLoadingViewController  {
            guard let dictionary = sender as? UserDictionary else { fatalError() }
            to.transitioningDelegate = self
            print("Loading dictionary: \(dictionary.subject) with enfocaRef \(dictionary.enfocaRef)")
            
            to.initialize(dictionary: dictionary)
        } else if let to = segue.destination as? DictionaryCreationViewController {
            to.transitioningDelegate = self
            to.initialize(isBackButtonNeeded: true)
        }
    }
    
    func maybePerformDelete(dictionary: UserDictionary, callback: @escaping (_ deleted: Bool)->()){
        presentOkCancelAlert(title: "Delete Confirmation", message: "Are you sure that you want to delete \(dictionary.subject) and \(dictionary.countWordPairs) cards?") { (yes:Bool) in
            if yes {
                let alert = self.presentActivityAlert(title: "Deleting \(dictionary.subject)", message: "Please   wait...")
                
                self.performDelete(dictionary: dictionary, callback: { (_: Bool) in
                    alert.dismiss(animated: true, completion: nil)
                    callback(true)

                })
            } else {
                callback(false)
            }
        }
    }
    
    func performDelete(dictionary: UserDictionary, callback: @escaping (_ deleted: Bool)->()) {
        services().deleteDictionary(dictionary: dictionary) { (dictionary:UserDictionary?, error:EnfocaError?) in
            
            if let error = error {
                self.presentAlert(title: "Failed to update", message: error)
                
                callback(false)
                return
            }
            
            guard let _ = dictionary else { fatalError() }
            callback(true)
        }
    }
    
    
    
}

extension DictionarySelectionViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            let dict = dictionaryList[indexPath.row]
            maybePerformDelete(dictionary: dict, callback: { (deleted: Bool) in
                if deleted {
                    self.dictionaryList.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .left)
                    self.toggleEditMode()
                } else {
                    self.toggleEditMode()
                }
                
            })
        default: fatalError()
        }
    }
    
}


extension DictionarySelectionViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dictionaryList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SubjectTableViewCell.identifier, for: indexPath) as? SubjectTableViewCell else { fatalError() }
        
        cell.initialize(delegate: self, dictionary: dictionaryList[indexPath.row])
        
        return cell
    }
    
}

extension DictionarySelectionViewController: SubjectTableViewCellDelegate {
    
    func performSelect(title: String) {
        fatalError()
    }
    func performSelect(dictionary: UserDictionary) {
        if isEditMode {
            guard getAppDelegate().webService.isNetworkAvailable else {
                presentAlert(title: "Network unavalable", message: "Editing is not possible offline.")
                return
            }
            performSegue(withIdentifier: "EditDictionarySegue", sender: dictionary)
        } else {
            
            if !getAppDelegate().webService.isNetworkAvailable {
                //If there is no network, make sure that the dictionary exists offline
                guard let _ = getAppDelegate().applicationDefaults.loadDataStore(forDictionaryId: dictionary.dictionaryId) else {
                    presentAlert(title: "Network unavalable", message: "Dictionary unavailable for offline viewing.")
                    return
                }
            }
            performSegue(withIdentifier: "LoadDictionarySegue", sender: dictionary)
        }
    }
}

extension DictionarySelectionViewController: EnfocaDefaultAnimatorTarget {
    func getRightNavView() -> UIView? {
        return editButton
    }
    func getTitleView() -> UIView {
        return titleLabel
    }
    
    func additionalComponentsToHide() -> [UIView] {
        return []
    }
    func getBodyContentView() -> UIView {
        return bodyView
    }
}
extension DictionarySelectionViewController: UIViewControllerTransitioningDelegate {
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        animator.presenting = true
        return animator
        
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        animator.presenting = false
        return animator
        
    }
}
