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

class RecentSearchManager {

    weak var delegate: RecentSearchManagerDelegate?

    private var recentSearches = [String]()

    init() {
        fetchRecentSearchTerms()
    }

    private lazy var filePathURL: URL? = {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("FlickrFindrRecentSearches")
    }()

    private func fetchRecentSearchTerms() {
        guard let url = filePathURL
            else { return }

        do {
            let data = try Data(contentsOf: url)
            recentSearches = try JSONDecoder().decode([String].self, from: data)
        } catch {
            print("There was an error retrieving recent searches from disk: \(error)")
        }
    }

    private func saveToDisk() {
        guard let url = filePathURL
            else { return }

        do {
            let data = try JSONEncoder().encode(recentSearches)
            try data.write(to: url)
        } catch {
            print("There was an error writing data to the disk: \(error)")
        }
    }

    func recentSearchTerms() -> [String] {
        fetchRecentSearchTerms()
        
        return recentSearches
    }

    func insert(searchTerm: String) {
        if let index = recentSearches.firstIndex(of: searchTerm) {
            recentSearches.remove(at: index)
        }

        if recentSearches.count == 15 {
            recentSearches.removeLast()
        }

        recentSearches.insert(searchTerm, at: 0)
        saveToDisk()
        delegate?.recentSearchTermsWereUpdated()
    }
}
