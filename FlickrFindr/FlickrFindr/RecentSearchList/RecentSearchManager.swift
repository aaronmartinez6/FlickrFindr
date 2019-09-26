//
//  RecentSearchManager.swift
//  FlickrFindr
//
//  Created by Aaron Martinez on 9/23/19.
//  Copyright © 2019 Aaron Martinez. All rights reserved.
//

import Foundation

protocol RecentSearchManagerDelegate: class {

    func recentSearchTermsWereUpdated()
}

class RecentSearchManager: RecentSearchManagerService {

    weak var delegate: RecentSearchManagerDelegate?

    private let recentSearchStore: UserDataStore

    init(recentSearchStore: UserDataStore) {
        self.recentSearchStore = recentSearchStore
    }

    func recentSearchTerms() -> [String] {
        return recentSearchStore.fetchContents()
    }

    func insert(searchTerm: String) {
        recentSearchStore.insertContent(searchTerm)
        delegate?.recentSearchTermsWereUpdated()
    }

    func clearSearchHistory() {
        recentSearchStore.deleteAllContents()
    }
    
}
