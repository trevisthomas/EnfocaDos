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
    
//    var viewModel: DictionarySelectionViewModel!
    
    fileprivate var dictionaryList: [Dictionary] = []
    
    fileprivate var isEditMode: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Clearing out current device cache!
        getAppDelegate().applicationDefaults.clearUserDefauts()
        
        initializeLookAndFeel()
        
        tableView.reloadData()
        
//        initialize()

//        viewModel = DictionarySelectionViewModel(delegate: self)
        
//        viewModel.fetchDictionaries {
//            //Do you care that the list has been fetched?
//        }
    }
    
    private func initializeLookAndFeel() {
        tableView.separatorStyle = .none
    }
    
    func initialize(dictionaryList: [Dictionary]) {
        self.dictionaryList = dictionaryList
    }
    
//    private func initialize(){
//        
//        getAppDelegate().applicationDefaults = LocalApplicationDefaults()
//        
//        let service: WebService
//        
//        //TODO: Use this to decide which services implementation to use
//        if isTestMode() {
//            print("We're in test mode")
//            service = UiTestWebService()
//        } else {
//            print("Production")
//            service = LocalCloudKitWebService()
//            //        let service = CloudKitWebService()
//            //        let service = DemoWebService()
//        }
//        
//        getAppDelegate().webService = service
//    }

    @IBAction func newSubjectAction(_ sender: Any) {
        
    }
    
    @IBAction func editButtonAction(_ sender: Any) {
        if isEditMode {
            editButton.setTitle("Edit", for: .normal)
        } else {
            editButton.setTitle("Done", for: .normal)
        }
        isEditMode = !isEditMode
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let to = segue.destination as? DictionaryEditorViewController {
            //            to.transitioningDelegate = self
            guard let dictionary = sender as? Dictionary else { fatalError() }
            to.initialize(dictionary: dictionary)
            
        } else if let to = segue.destination as? DictionaryLoadingViewController  {
            guard let dictionary = sender as? Dictionary else { fatalError() }
            to.initialize(dictionary: dictionary)
        }
    }

        

}

//@deprecated
//extension DictionarySelectionViewController: DictionarySelectionViewModelDelegate {
//    func refresh() {
//        tableView.reloadData()
//    }
//    
//    func onError(title: String, message: EnfocaError) {
//        presentAlert(title: title, message: message)
//    }
//}

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
    func performSelect(dictionary: Dictionary) {
        if isEditMode {
            performSegue(withIdentifier: "EditDictionarySegue", sender: dictionary)
        } else {
            performSegue(withIdentifier: "LoadDictionarySegue", sender: dictionary)
        }
    }
}
