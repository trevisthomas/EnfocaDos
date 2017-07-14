//
//  ColorCell.swift
//  Enfoca
//
//  Created by Trevis Thomas on 7/14/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import UIKit

class ColorCell: UITableViewCell {
    
    static let identifier = "ColorCell"
    @IBOutlet weak var colorNameLabel: UILabel!
    @IBOutlet weak var colorSampleView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func initialize(colorLabel: ColorLabel) {
        colorNameLabel.text = colorLabel.name
        colorSampleView.backgroundColor = UIColor.init(hexString: colorLabel.hexColor)
    }

}
