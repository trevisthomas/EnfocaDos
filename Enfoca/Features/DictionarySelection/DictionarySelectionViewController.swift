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
    
    var viewModel: DictionarySelectionViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeLookAndFeel()
        
        initialize()

        viewModel = DictionarySelectionViewModel(delegate: self)
        
        viewModel.fetchDictionaries {
            //Do you care that the list has been fetched?
        }
    }
    
    private func initializeLookAndFeel() {
        tableView.separatorStyle = .none
    }
    
    private func initialize(){
        
        getAppDelegate().applicationDefaults = LocalApplicationDefaults()
        
        let service: WebService
        
        //TODO: Use this to decide which services implementation to use
        if isTestMode() {
            print("We're in test mode")
            service = UiTestWebService()
        } else {
            print("Production")
            service = LocalCloudKitWebService()
            //        let service = CloudKitWebService()
            //        let service = DemoWebService()
        }
        
        getAppDelegate().webService = service
    }

    @IBAction func newSubjectAction(_ sender: Any) {
        
    }
        

}

extension DictionarySelectionViewController: DictionarySelectionViewModelDelegate {
    func refresh() {
        tableView.reloadData()
    }
    
    func onError(title: String, message: EnfocaError) {
        presentAlert(title: title, message: message)
    }
}

extension DictionarySelectionViewController: UITableViewDelegate {
    
}

extension DictionarySelectionViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.dictionaryList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SubjectTableViewCell.identifier, for: indexPath) as? SubjectTableViewCell else { fatalError() }
        
        cell.initialize(dictionary: viewModel.dictionaryList[indexPath.row])
        
        return cell
    }
    
}
