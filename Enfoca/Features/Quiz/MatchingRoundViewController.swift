//
//  MatchingRoundViewController.swift
//  Enfoca
//
//  Created by Trevis Thomas on 6/13/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import UIKit

class MatchingRoundViewController: UIViewController {
    
    private var delegate: CardViewControllerDelegate!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func initialize(delegate: CardViewControllerDelegate){
        self.delegate = delegate
    }

    @IBAction func skipAction(_ sender: UIButton) {
        resumeQuiz()
    }
    
    private func resumeQuiz(){
        performSegue(withIdentifier: "ResumeQuizSegue", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let to = segue.destination as? CardFrontViewController else { fatalError() }
        
        to.initialize(delegate: delegate)
    }
}

//Trevis: Dont forget that the FlowDelegate interets from the CollecionViewDelegate too
extension MatchingRoundViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5.0 //Column spacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout
        collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5.0 // row spacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if section > 0 {
            return UIEdgeInsets(top: 10.0, left: 0, bottom: 0, right: 0)
        } else {
            return UIEdgeInsets(top: 0.0, left: 0, bottom: 0, right: 0)
        }
    }
}


extension MatchingRoundViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MatchingQuizTagCell.identifier, for: indexPath) as? MatchingQuizTagCell else { fatalError() }
        
        if indexPath.section == 0 {
            cell.applyColors(text: Theme.lightness, background: Theme.green)
        } else {
            cell.applyColors(text: Theme.lightness, background: Theme.orange)
        }
        
        return cell
    }
    
    
}
