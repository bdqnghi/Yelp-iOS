//
//  ComboCell.swift
//  Yelp
//
//  Created by Nghi Bui on 11/21/15.
//  Copyright © 2015 Timothy Lee. All rights reserved.
//

import UIKit


@objc protocol ComboCellDelegate {
    optional func selectCell(comboCell: ComboCell, didSelect currentImg: UIImage)
}

class ComboCell: UITableViewCell {

    var delegate: ComboCellDelegate!
    
    @IBOutlet weak var label: UILabel!
    
    @IBOutlet weak var iconView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        if delegate != nil {
            delegate?.selectCell?(self, didSelect: iconView.image!)
        }    }

}
