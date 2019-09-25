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

    let recentSearchStore: UserDataStore

    init(userDataStore: UserDataStore) {
        self.recentSearchStore = userDataStore
    }

    func recentSearchTerms() -> [String] {
        return recentSearchStore.fetchContents()
    }

    func insert(searchTerm: String) {
        recentSearchStore.insertContent(searchTerm)
        delegate?.recentSearchTermsWereUpdated()
    }
    
}
