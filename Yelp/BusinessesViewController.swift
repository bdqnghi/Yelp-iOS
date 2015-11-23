//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit
import SVProgressHUD

class BusinessesViewController: UIViewController,UITableViewDelegate, UITableViewDataSource,FiltersViewControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var businesses: [Business]!
    
    var totalResult = 0 as Int
    var searchBar: UISearchBar!
    var filters = [String : AnyObject]()
    
    var isLoading = false
    var isEnd = false
    
    var count = 0
   
    var categories = [String]()
    var sort = 0
    var ranges: Float?
    var deals = false
    
    var loadingIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.hidden = true
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 300
        tableView.separatorColor = UIColor(red: 210/255, green: 180/255, blue: 170/255, alpha: 1)
        
        searchBar = UISearchBar()
        searchBar.delegate = self
        searchBar.sizeToFit()
        navigationItem.titleView = searchBar
        
        let tableFooterView = UIView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, 50))
        loadingIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        loadingIndicator.center = tableFooterView.center
        loadingIndicator.hidesWhenStopped = true
        
        tableFooterView.addSubview(loadingIndicator)
        tableView.tableFooterView = tableFooterView
        
        filters["categories"] = [String]()
        filters["sort"] = 0
        filters["deal"] = false
        filters["radius"] = nil
        SVProgressHUD.show()
        
        Business.searchWithTerm("", sort: YelpSortMode(rawValue:  sort), categories: categories, deals: deals, ranges: ranges,count:20) { (result: SearchResult!, error: NSError!) -> Void in
            
            self.businesses = result.businesses
            self.totalResult = result.total!
            self.tableView.reloadData()
            self.tableView.hidden = false
            SVProgressHUD.dismiss()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if businesses != nil {
            return businesses.count
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("BusinessCell", forIndexPath: indexPath) as! BusinessCell
        
        cell.business = businesses[indexPath.row]
        cell.nameLabel.text = String(indexPath.row + 1) + ". " + businesses[indexPath.row].name!
        
        cell.layoutMargins = UIEdgeInsetsZero
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsetsZero
        
        if !isLoading && !isEnd {
            if indexPath.row == businesses.count - 1 {
                self.count += self.totalResult
                loadingIndicator.startAnimating()
                isLoading = true
                
                let sort = filters["sort"] as? Int
                let categories = self.filters["categories"] as? [String]
                let deal = self.filters["deal"] as? Bool
                let ranges = self.filters["radius"] as! Float?
                var term: String = ""
                if !searchBar.text!.isEmpty {
                    term = searchBar.text!
                }

                searchBusisness(term, sort: sort, ranges: ranges, categories: categories, deals: deal, count: count)
            }
        }

        return cell
    }
   
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        let navigationController = segue.destinationViewController as! UINavigationController
        
        let filtersViewController = navigationController.topViewController as! FiltersViewController
        filtersViewController.delegate = self
    }
    
    func filtersViewController(filFiltersViewController: FiltersViewController, didUpdateFilters filters: [String : AnyObject]) {

        SVProgressHUD.show()
        var term: String = ""
        if !searchBar.text!.isEmpty {
            term = searchBar.text!
        }
        let sort = filters["sort"] as? Int
        let categories = filters["categories"] as? [String]
        let deal = filters["deal"] as? Bool
        var ranges = filters["radius"] as! Float?
        if let rangesValue = ranges {
            ranges = rangesValue * 1609.344
        }
        
        // Set filters in this view controller
        self.filters["sort"] = 1
        self.filters["categories"] = categories
        self.filters["deal"] = deal
        self.filters["radius"] = ranges
        
        Business.searchWithTerm(term, sort: YelpSortMode(rawValue: sort!), categories: categories, deals: deal, ranges: ranges,count:count) { (result: SearchResult!, error: NSError!) -> Void in
            
            if result != nil {
                self.totalResult = result.total!
                self.businesses = result.businesses
                self.tableView.reloadData()
            
                // Scroll to the top of table view
                self.tableView.contentOffset = CGPointMake(0, 0 - self.tableView.contentInset.top)
                
            } else {
                self.totalResult = 0
            }
            
            self.tableView.reloadData()
            SVProgressHUD.dismiss()
        }
    }
    

}
extension BusinessesViewController: UISearchBarDelegate {
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        searchBar.enablesReturnKeyAutomatically = false
        searchBar.showsCancelButton = true
        return true;
    }
    
    func searchBarShouldEndEditing(searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(false, animated: true)
        return true;
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
       searchBar.resignFirstResponder()
    }

    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        businesses.removeAll(keepCapacity: false)
        tableView.reloadData()
        
        let sort = filters["sort"] as? Int
        let categories = self.filters["categories"] as? [String]
        let deals = self.filters["deal"] as? Bool
        let ranges = self.filters["radius"] as! Float?
        //let offset = businesses.count
        var term: String = ""
        if !searchBar.text!.isEmpty {
            term = searchBar.text!
        }
        
        searchBusisness(term,sort:sort,ranges: ranges,categories: categories,deals: deals,count: count)
        searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        
        searchBar.enablesReturnKeyAutomatically = false
        searchBar.showsCancelButton = true
        
        self.navigationController?.navigationBar.bringSubviewToFront(searchBar)
    }
    
    func searchBusisness(term: String!, sort: Int!, ranges: Float?, categories: [String]?, deals: Bool?, count: Int?) {
       
        if !isLoading {
            SVProgressHUD.show()
        }
        Business.searchWithTerm(term!, sort: YelpSortMode(rawValue:  sort), categories: categories, deals: deals, ranges: ranges,count:count) { (result: SearchResult!, error: NSError!) -> Void in
            
            if result != nil {
                self.totalResult = result.total!
                
                for b in result.businesses {
                    self.businesses.append(b)
                }
                self.isEnd = self.businesses.count < self.totalResult
                
            } else {
                self.totalResult = 0
                self.isEnd = true
            }
            self.tableView.reloadData()
            self.tableView.hidden = false
            self.isLoading = false
            SVProgressHUD.dismiss()

        }
    }
}
