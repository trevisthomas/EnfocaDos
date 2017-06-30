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
    
    
    fileprivate var dictionaryList: [UserDictionary] = []
    fileprivate var isEditMode: Bool = false
    
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
        isEditMode = !isEditMode
        initializeLookAndFeel()
        
//        let cells = tableView.visibleCells
//        
//        for cell in cells {
//            cell.jiggle { () -> (Bool) in
//                return self.isEditMode
//            }
//        }
        
        tableView.setEditing(isEditMode, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let to = segue.destination as? DictionaryEditorViewController {
            //            to.transitioningDelegate = self
            guard let dictionary = sender as? UserDictionary else { fatalError() }
            to.initialize(dictionary: dictionary)
            
        } else if let to = segue.destination as? DictionaryLoadingViewController  {
            guard let dictionary = sender as? UserDictionary else { fatalError() }
            
            print("Loading dictionary: \(dictionary.subject) with enfocaId \(dictionary.enfocaId)")
            
            to.initialize(dictionary: dictionary)
        } else if let to = segue.destination as? DictionaryCreationViewController {
            to.initialize(isBackButtonNeeded: true)
        }
    }
}


extension DictionarySelectionViewController: UITableViewDelegate {
    
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
    func performSelect(dictionary: UserDictionary) {
        if isEditMode {
            performSegue(withIdentifier: "EditDictionarySegue", sender: dictionary)
        } else {
            performSegue(withIdentifier: "LoadDictionarySegue", sender: dictionary)
        }
    }
}
