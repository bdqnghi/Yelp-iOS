//
//  FiltersViewController.swift
//  Yelp
//
//  Created by Nghi Bui on 11/21/15.
//  Copyright © 2015 Timothy Lee. All rights reserved.
//

import UIKit

@objc protocol FiltersViewControllerDelegate {
    optional func filtersViewController(filFiltersViewController: FiltersViewController, didUpdateFilters filters: [String:AnyObject])
}

class FiltersViewController: UIViewController,UITableViewDelegate, UITableViewDataSource,SwitchCellDelegate,ComboCellDelegate {
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    @IBOutlet weak var tableView: UITableView!
    
    var ranges: [Float] = [0.0, 1, 3.0, 5.0, 10.0, 20.0, 50.0]
    var rangesList = ["Auto", "1 mile", "3 miles", "5 miles", "10 miles","20 miles","50 miles"]
    
    var categoriesDic: [[String: String]] = []
    var filters = [String : AnyObject]()
    
    var isSortSectionExpanded = true
    var isRadiusSectionExpanded = true
    var isCategorySectionExpanded = true
    
    var allSwitchStates = [Int:Bool]()
    
    weak var delegate: FiltersViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView.tableFooterView = UIView()
        
        categoriesDic = Utils.yelpCategories()
        
        let allSwitchStatesData = defaults.objectForKey("switchStates") as? NSData
        if let allSwitchStatesData = allSwitchStatesData {
            allSwitchStates = NSKeyedUnarchiver.unarchiveObjectWithData(allSwitchStatesData) as! [Int:Bool]
        }
        
        let filtersData = defaults.objectForKey("filters") as? NSData
        if let filtersData = filtersData {
            filters = NSKeyedUnarchiver.unarchiveObjectWithData(filtersData) as! [String : AnyObject]
        }
        
        if filters["sort"] == nil {
            filters["sort"] = Int(0)
        }
        
        if filters["radius"] == nil {
            filters["radius"] = Float(0.0)
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    @IBAction func onButtonCancelClicked(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func onSearchButtonClicked(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
        
        var selectedCategories = [String]()
        for (row, isSelected) in allSwitchStates {
            if isSelected {
                selectedCategories.append(categoriesDic[row]["code"]!)
            }
        }
        if selectedCategories.count > 0 {
            filters["categories"] = selectedCategories
        } else {
            filters["categories"] = nil
        }
        
        delegate?.filtersViewController?(self, didUpdateFilters: filters)
        
        // Save to NSUserDefaults
        let switchStatesData = NSKeyedArchiver.archivedDataWithRootObject(allSwitchStates)
        self.defaults.setObject(switchStatesData, forKey: "switchStates")
        
        let filtersData = NSKeyedArchiver.archivedDataWithRootObject(filters)
        self.defaults.setObject(filtersData, forKey: "filters")
        
        defaults.synchronize()
        
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 5
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return ranges.count
        case 2:
            return 3
        case 3:
            return categoriesDic.count + 1
        case 4:
            return 1
        default:
            return 0
        }
    }
    
    // All about table view
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            
            let cell = tableView.dequeueReusableCellWithIdentifier("FilterSwitchCell", forIndexPath: indexPath) as! FilterSwitchCell
            
            cell.delegate = self
            cell.switchLabel.text = "Offering a Deal"
            cell.switchControl.on = filters["deal"] as? Bool ?? false
            
            return cell
            
        case 1:
            
            let cell = tableView.dequeueReusableCellWithIdentifier("ComboCell", forIndexPath: indexPath) as! ComboCell
            
            cell.delegate = self
            cell.label.text =  rangesList[indexPath.row]
            
            Utils.setIconsForRadiusCell(indexPath.row, iconView: cell.iconView,filters: filters,isRadiusCollapsed: isRadiusSectionExpanded,ranges: ranges)
            Utils.setRadiusCellVisible(indexPath.row, cell: cell,filters: filters,isRadiusCollapsed: isRadiusSectionExpanded,ranges: ranges)
            
            return cell
            
        case 2:
            
            let cell = tableView.dequeueReusableCellWithIdentifier("ComboCell", forIndexPath: indexPath) as! ComboCell
            cell.delegate = self
            
            switch indexPath.row {
            case 0:
                cell.label.text = "Best Match"
                break
            case 1:
                cell.label.text = "Distance"
                break
            case 2:
                cell.label.text = "Rating"
                break
            default:
                break
            }
            
            Utils.setIconsForSortCell(indexPath.row, iconView: cell.iconView,filters: filters,isSortCollapsed: isSortSectionExpanded)
            Utils.setSortCellVisible(indexPath.row, cell: cell,filters: filters,isSortCollapsed: isSortSectionExpanded)
            
            return cell
            
        case 3:
            
            if indexPath.row != categoriesDic.count {
                
                let cell = tableView.dequeueReusableCellWithIdentifier("FilterSwitchCell", forIndexPath: indexPath) as! FilterSwitchCell
                
                cell.switchLabel.text = categoriesDic[indexPath.row]["name"]
                cell.delegate = self
                cell.switchControl.on = allSwitchStates[indexPath.row] ?? false
                
                Utils.setCategoryCellVisible(indexPath.row, cell: cell,filters: filters,isCategoryCollapsed: isCategorySectionExpanded,categoriesDic: categoriesDic)
                
                return cell
                
            } else {
                
                let cell = tableView.dequeueReusableCellWithIdentifier("SeeAllCell", forIndexPath: indexPath) as! SeeAllCell
                
                let expand = UITapGestureRecognizer(target: self, action: "expand:")
                cell.addGestureRecognizer(expand)
                
                return cell
            }
        default:
            let cell = UITableViewCell()
            return cell
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.section {
        case 0: break
        case 1:
            if(isRadiusSectionExpanded){
                tableView.reloadSections(NSIndexSet(index: indexPath.section), withRowAnimation: .Top)
            }else{
                tableView.reloadSections(NSIndexSet(index: indexPath.section), withRowAnimation: .Bottom)
            }
            
        case 2:
            if(isSortSectionExpanded){
                tableView.reloadSections(NSIndexSet(index: indexPath.section), withRowAnimation: .Top)
            }else{
                tableView.reloadSections(NSIndexSet(index: indexPath.section), withRowAnimation: .Bottom)
            }
            
        case 3:
            if(isCategorySectionExpanded){
                tableView.reloadSections(NSIndexSet(index: indexPath.section), withRowAnimation: .Top)
            }else{
                tableView.reloadSections(NSIndexSet(index: indexPath.section), withRowAnimation: .Bottom)
            }

            
        default: break
        }
    }

    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        let titleLabel = UILabel(frame: CGRect(x: 15, y: 15, width: 320, height: 30))
        
        titleLabel.textColor = UIColor(red: 250/255, green: 58/255, blue: 67/255, alpha: 1)
        headerView.backgroundColor = UIColor(red: 240/255, green: 235/255, blue: 245/255, alpha: 1)
        
        switch section {
        case 0:
            titleLabel.text = "Deal"
            break
        case 1:
            titleLabel.text = "Distance"
            break
        case 2:
            titleLabel.text = "Sort By"
            break
        case 3:
            titleLabel.text = "Category"
            break
        default:
            return nil
        }
        
        headerView.addSubview(titleLabel)
        
        return headerView
    }
    
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        switch indexPath.section {
        case 1:
            if isRadiusSectionExpanded {
                let radiusValue = Utils.getRanges(filters)
                if radiusValue != ranges[indexPath.row] {
                    return 0
                }
            }
            break
        case 2:
            if isSortSectionExpanded {
                let sortValue = Utils.getSort(filters)
                if sortValue != indexPath.row {
                    return 0
                }
            }
            break
        case 3:
            if isCategorySectionExpanded {
                if indexPath.row > 2 && indexPath.row != categoriesDic.count {
                    return 0
                }
            }
            break
        default:
            break
        }
        
        return 40.0
    }
    
    func expand(sender:UITapGestureRecognizer) {
        
        let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: categoriesDic.count, inSection: 3)) as! SeeAllCell
        
        if cell.label.text == "See All" {
            cell.label.text = "Collapse"
            isCategorySectionExpanded = false
        } else {
            cell.label.text = "See All"
            isCategorySectionExpanded = true
        }
        
        tableView.reloadData()
    }
    
    // Delegates
    
    func filterSwitchCell(switchCell: FilterSwitchCell, didChangeValue value: Bool) {
        
        let indexPath = tableView.indexPathForCell(switchCell)!
        
        if indexPath.section == 0 {
            self.filters["deal"] = value
        } else if indexPath.section == 3 {
            allSwitchStates[indexPath.row] = value
        }
    }
    
    func selectCell(comboCell: ComboCell, didSelect currentImg: UIImage) {
        
        let indexPath = tableView.indexPathForCell(comboCell)
        
        if indexPath != nil {
            if indexPath!.section == 1 {
                // Ranges area
                switch currentImg {
                case UIImage(named: "Arrow")!:
                    isRadiusSectionExpanded = false
                    break
                case UIImage(named: "Tick")!:
                    isRadiusSectionExpanded = true
                    break
                case UIImage(named: "Circle")!:
                    filters["radius"] = ranges[indexPath!.row]
                    isRadiusSectionExpanded = true
                    break
                default:
                    break
                }
            } else if indexPath!.section == 2 {
                // Sort area
                switch currentImg {
                case UIImage(named: "Arrow")!:
                    isSortSectionExpanded = false
                    break
                case UIImage(named: "Tick")!:
                    isSortSectionExpanded = true
                    break
                case UIImage(named: "Circle")!:
                    filters["sort"] = NSNumber(integer: indexPath!.row)
                    isSortSectionExpanded = true
                    break
                default:
                    break
                }
            }
            
            tableView.reloadData()
        }
    }
}