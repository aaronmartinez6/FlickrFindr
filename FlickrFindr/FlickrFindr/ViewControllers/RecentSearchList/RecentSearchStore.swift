//
//  RecentSearchStore.swift
//  FlickrFindr
//
//  Created by Aaron Martinez on 9/25/19.
//  Copyright © 2019 Aaron Martinez. All rights reserved.
//

import Foundation

class RecentSearchStore: UserDataStore {

    private var recentSearches = [String]()

    private lazy var filePathURL: URL? = {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("FlickrFindrRecentSearches")
    }()
    
    func fetchContents() -> [String] {
        if recentSearches.isEmpty,
            let url = filePathURL {

            do {
                let data = try Data(contentsOf: url)
                let recentSearches = try JSONDecoder().decode([String].self, from: data)
                self.recentSearches = recentSearches
                return recentSearches
            } catch {
                print("There was an error retrieving recent searches from disk: \(error)")
                return []
            }
        } else {
            return recentSearches
        }
    }

    func insertContent(_ string: String) {
        if let index = recentSearches.firstIndex(of: string) {
            recentSearches.remove(at: index)
        }

        if recentSearches.count == 15 {
            recentSearches.removeLast()
        }

        recentSearches.insert(string, at: 0)
        save()
    }

    private func save() {
        guard let url = filePathURL
            else { return }

        do {
            let data = try JSONEncoder().encode(recentSearches)
            try data.write(to: url)
        } catch {
            print("There was an error writing data to the disk: \(error)")
        }
    }

}
