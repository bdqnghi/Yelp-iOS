//
//  SearchResult.swift
//  Yelp
//
//  Created by Nghi Bui on 11/22/15.
//  Copyright © 2015 Timothy Lee. All rights reserved.
//

import UIKit

class SearchResult: NSObject {
    let total: Int?
    let businesses: [Business]!
    
    init(businesses: [Business]!) {
        self.total = businesses.count
        self.businesses = businesses
    }
}