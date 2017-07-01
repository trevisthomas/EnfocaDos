//
//  DataImportViewController.swift
//  Enfoca
//
//  Created by Trevis Thomas on 6/6/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import UIKit

class DataImportViewController: UIViewController {

    @IBOutlet weak var enfocaIdTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func performImport(_ sender: Any) {
        guard let button = sender as? UIButton else { fatalError() }
        
        
        guard let enfocaRef = enfocaIdTextField.text else { fatalError() }
        
        button.isEnabled = false
        
        button.titleLabel?.text = "Importing!"
        
        let importer = Import(enfocaRef: enfocaRef)
        
        importer.process()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
