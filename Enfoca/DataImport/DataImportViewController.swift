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
    @IBOutlet weak var textView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//        enfocaIdTextField.text = "DFC2AF01-C0C1-4CC9-8353-F1AF5AB6A1B5" //Clean
//        enfocaIdTextField.text = "15584C98-24BC-4F31-AA75-1FEC0C1DEDBB" //Test - bad delete
//        enfocaIdTextField.text = "ACA750CB-DB60-473F-9488-0D170F42250E" //Demo - garbage
        
        enfocaIdTextField.text = "EA5BA3EC-B3DE-4BDE-955D-6875A1A64CC0" //Test
        
        
        textView.text = nil
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
        
        let importer = Import(enfocaRef: enfocaRef, textView: textView)
//        let importer = Import(enfocaRef: enfocaRef)
        
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
