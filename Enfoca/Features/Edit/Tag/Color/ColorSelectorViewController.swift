//
//  ColorSelectorViewController.swift
//  Enfoca
//
//  Created by Trevis Thomas on 7/14/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import UIKit

struct ColorLabel {
    let name: String
    let hexColor: String
}

protocol ColorSelectorViewControllerDelegate {
    func selectedColor(color: String?) //nil means default
}

class ColorSelectorViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerView: UIView!
    
    fileprivate var delegate: ColorSelectorViewControllerDelegate!
    
    fileprivate var colors: [ColorLabel] = [
                                        ColorLabel(name: "Default", hexColor: "#FFFFFF"),
                                        ColorLabel(name: "Blue", hexColor: "#0369A4"),
                                        ColorLabel(name: "Green", hexColor: "#1BA95E"),
                                        ColorLabel(name: "Yellow", hexColor: "#FFD831"),
                                        ColorLabel(name: "Orange", hexColor: "#FC7D04"),
                                        ColorLabel(name: "Pink", hexColor: "#F08EB1"),
                                        ColorLabel(name: "Red", hexColor: "#E31C3F")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        preferredContentSize = CGSize(width: 304, height: 375)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initialize(delegate: ColorSelectorViewControllerDelegate) {
        self.delegate = delegate
    }
}


extension ColorSelectorViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return colors.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ColorCell.identifier, for: indexPath) as? ColorCell else { fatalError() }
        
        cell.initialize(colorLabel: colors[indexPath.row])
        
        return cell
    }
    
}

extension ColorSelectorViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0 {
            delegate.selectedColor(color: nil)
        } else {
            delegate.selectedColor(color: colors[indexPath.row].hexColor)
        }
        
        dismiss(animated: true) {
            //whatever
        }
    }
}
