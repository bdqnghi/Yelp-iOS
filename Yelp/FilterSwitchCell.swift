//
//  FilterSwitchCell.swift
//  Yelp
//
//  Created by Nghi Bui on 11/21/15.
//  Copyright © 2015 Timothy Lee. All rights reserved.
//

import UIKit

@objc protocol SwitchCellDelegate {
    optional func filterSwitchCell(switchCell: FilterSwitchCell, didChangeValue value: Bool)
}

class FilterSwitchCell: UITableViewCell {

    @IBOutlet weak var switchLabel: UILabel!
    
    
    @IBOutlet weak var switchControl: UISwitch!
    
    
    var delegate: SwitchCellDelegate!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        switchControl.on = false
        switchControl.addTarget(self, action: "switchValueChanged", forControlEvents: UIControlEvents.ValueChanged)
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func switchValueChanged() {
        if delegate != nil {
            delegate?.filterSwitchCell?(self, didChangeValue: switchControl.on)
        }
    }

}
