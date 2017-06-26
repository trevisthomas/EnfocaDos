//
//  DictionaryCreationViewController.swift
//  Enfoca
//
//  Created by Trevis Thomas on 6/26/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import UIKit

class DictionaryCreationViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var viewModel: DictionaryCreationViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel = DictionaryCreationViewModel(delegate: self)
        
        initializeLookAndFeel()
        
        refresh()
        
    }

    private func initializeLookAndFeel() {
        tableView.separatorStyle = .none
    }
    

}
extension DictionaryCreationViewController: DictionaryCreationViewModelDelegate {
    func refresh() {
        tableView.reloadData()
    }
    
    func onError(title: String, message: EnfocaError) {
        presentAlert(title: title, message: message)
    }
}

extension DictionaryCreationViewController: UITableViewDelegate {
    
}

extension DictionaryCreationViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.dictionaryList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SubjectTableViewCell.identifier, for: indexPath) as? SubjectTableViewCell else { fatalError() }
        
        cell.initialize(dictionary: viewModel.dictionaryList[indexPath.row])
        
        return cell
    }
    
}
