//
//  RecentSearchManagerService.swift
//  FlickrFindr
//
//  Created by Aaron Martinez on 9/24/19.
//  Copyright © 2019 Aaron Martinez. All rights reserved.
//

import Foundation

protocol RecentSearchManagerService {
    
    func insert(searchTerm: String)
    func recentSearchTerms() -> [String]
    func clearSearchHistory()
}
