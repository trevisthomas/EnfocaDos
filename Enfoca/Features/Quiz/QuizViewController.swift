//
//  QuizViewController.swift
//  Enfoca
//
//  Created by Trevis Thomas on 6/9/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import UIKit

protocol QuizViewControllerDelegate {
    func tagSelectedForQuiz() -> Tag
}

class QuizViewController: UIViewController {
    var delegate : QuizViewControllerDelegate!
    
    @IBOutlet weak var cardSideSegmentedControl: UISegmentedControl!
    @IBOutlet weak var wordOrderPicker: UIPickerView!
    @IBOutlet weak var selectedTagLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var wordCountLabel: UILabel!
    
    fileprivate var viewModel : QuizViewModel!
    
    @IBAction func incrementWordCountAction(_ sender: UIButton) {
        viewModel.incrementWordCount()
        formatWordCountText()
    }
    
    
    @IBAction func cardSideSegmentedControlValueChanged(_ sender: UISegmentedControl) {
        viewModel.cardSide = CardSide.values[sender.selectedSegmentIndex]
    }
    
    @IBAction func decrementWordCountAction(_ sender: UIButton) {
        viewModel.decrementWordCount()
        formatWordCountText()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = QuizViewModel(tag: delegate.tagSelectedForQuiz())
        
        initializeLookAndFeel()
    }
    
    private func initializeLookAndFeel(){
        let font = Style.segmentedControlFont()
        cardSideSegmentedControl.setTitleTextAttributes([NSFontAttributeName: font], for: .normal)
        cardSideSegmentedControl.selectedSegmentIndex = CardSide.values.index(of: viewModel.cardSide)!
        selectedTagLabel.text = viewModel.tagName
        
        
        let selectedRow = CardOrder.values.index(of: viewModel.cardOrder)!
        wordOrderPicker.selectRow(selectedRow, inComponent: 0, animated: false)
        formatWordCountText()
        
    }
    
    private func formatWordCountText() {
        wordCountLabel.text = "Word Count: \(viewModel.wordCount!)"
    }
    
    @IBAction func cancelAction(_ sender: EnfocaButton) {
        dismiss(animated: true) { 
            //whatever
        }
    }

    @IBAction func startQuizAction(_ sender: EnfocaButton) {
        print("Quiz: \(viewModel.tagName) Words: \(viewModel.wordCount) Card Order: \(viewModel.cardOrder) Card Side: \(viewModel.cardSide)")
    }
   

}

extension QuizViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        viewModel.cardOrder = CardOrder.values[row]
    }
}

extension QuizViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return CardOrder.values.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return CardOrder.values[row].rawValue
    }
}
