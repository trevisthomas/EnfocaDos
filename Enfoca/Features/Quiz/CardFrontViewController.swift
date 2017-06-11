//
//  QuizFrontSubViewController.swift
//  Enfoca
//
//  Created by Trevis Thomas on 6/11/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import UIKit


protocol CardViewControllerDelegate {
    func getRearWord() -> String
    func getFrontWord() -> String
    func correct()
    func incorrect()
}


class CardFrontViewController: UIViewController {

    @IBOutlet weak var termLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    
    private var delegate: CardViewControllerDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        termLabel.text = delegate.getFrontWord()
    }
    
    func initialize(delegate: CardViewControllerDelegate){
        self.delegate = delegate
    }


    @IBAction func okButtonAction(_ sender: EnfocaButton) {
        
        performSegue(withIdentifier: "QuizRearViewControllerSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let to = segue.destination as? CardRearViewController else { fatalError() }
        
        to.initialize(delegate: delegate)
    }
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}
