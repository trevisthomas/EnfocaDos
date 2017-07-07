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
        
//        enfocaIdTextField.text = "EA5BA3EC-B3DE-4BDE-955D-6875A1A64CC0" //Test
        
        
//        enfocaIdTextField.text = "E04FD3FD-6F3D-48C4-8FC8-B1AFF262925C" // First prod! - deadloc delete
        
//        enfocaIdTextField.text = "54E044A6-DC95-4B16-B1E9-B6F45A744C4F"
        
//        enfocaIdTextField.text = "460AC85F-A561-45A7-A0F2-D1FD73347FC7"
        
//        enfocaIdTextField.text = "38A06181-422E-4EE7-BB20-84B8C4D0D6F1"
//        enfocaIdTextField.text = "1F88677A-7A19-4F58-BAA4-A3F08FF6185D"
        
        enfocaIdTextField.text = "601FE89B-5976-41A2-A91D-2F3F5CF1E19A"
        
//        enfocaIdTextField.text = "525C904F-FE2C-4ED4-8048-B17D63CFF7BB" -- GOT IT!
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



}
