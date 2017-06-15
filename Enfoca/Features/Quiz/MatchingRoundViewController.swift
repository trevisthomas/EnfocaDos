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
    fileprivate var viewModel: MatchingRoundViewModel!

    @IBOutlet weak var collectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.estimatedItemSize = CGSize(width: 20, height: 20)
        
        viewModel = MatchingRoundViewModel(delegate: self, wordPairs: delegate.getWordPairsForMatching())
        
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
    
    fileprivate func sectionToCardSide(section: Int) -> CardSide {
        return section == 0 ? CardSide.term : CardSide.definition
    }
    
}

extension MatchingRoundViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cardSide = sectionToCardSide(section: indexPath.section)
        
        viewModel.selectPair(cardSide: cardSide, atRow: indexPath.row)
    }
}


extension MatchingRoundViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.matchingPairs.count / 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MatchingQuizTagCell.identifier, for: indexPath) as? MatchingQuizTagCell else { fatalError() }
        
        let cardSide = sectionToCardSide(section: indexPath.section)
        
        let matchingPair = viewModel.getPair(cardSide: cardSide, atRow: indexPath.row)
        
        cell.setTitle(matchingPair.title)
        
        
        switch matchingPair.state {
        case .disabled:
            cell.applyColors(text: Theme.lightness, background: Theme.gray)
        case .hidden:
            cell.applyColors(text: Theme.lightness, background: Theme.lightness)
        case .normal:
            applyNormalColor(matchingPair: matchingPair, cell: cell)
        case .selected:
            applyNormalColor(matchingPair: matchingPair, cell: cell)
            
        }
        
        
        
        return cell
    }
    
    private func applyNormalColor(matchingPair: MatchingPair, cell: MatchingQuizTagCell) {
        switch matchingPair.cardSide {
        case .definition:
        cell.applyColors(text: Theme.lightness, background: Theme.green)
        case .term:
        cell.applyColors(text: Theme.lightness, background: Theme.orange)
        default: fatalError()
        }
    }
}

extension MatchingRoundViewController: MatchingRoundViewModelDelegate {
    func removeCell(cardSide: CardSide, atRow: Int) {
        //doit
    }

    func reloadMatchingPairs() {
        collectionView.reloadData()
        collectionView.collectionViewLayout.invalidateLayout()
    }
}
