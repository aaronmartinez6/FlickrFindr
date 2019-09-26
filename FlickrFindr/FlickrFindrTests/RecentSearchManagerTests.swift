//
//  RecentSearchManagerTests.swift
//  FlickrFindrTests
//
//  Created by Aaron Martinez on 9/24/19.
//  Copyright © 2019 Aaron Martinez. All rights reserved.
//

import XCTest
@testable import FlickrFindr

class RecentSearchManagerTests: XCTestCase {

    var sut: RecentSearchManager!

    override func setUp() {
        sut = RecentSearchManager(recentSearchStore: MockUserDataStore())
    }

    override func tearDown() {
        sut = nil
    }

    func test_insert_InsertsNewSearchTermAtIndexZero() {
        let a = "a"
        let b = "b"
        sut.insert(searchTerm: a)
        sut.insert(searchTerm: b)
        let recentSearchTerms = sut.recentSearchTerms()

        XCTAssertEqual(recentSearchTerms.count, 2)
        XCTAssertEqual(b, recentSearchTerms.first)
    }

    func test_Insert_AddsSearchTermToArray() {
        var recentSearchTerms = sut.recentSearchTerms()
        XCTAssertEqual(recentSearchTerms.count, 0)

        let a = "a"
        sut.insert(searchTerm: a)
        recentSearchTerms = sut.recentSearchTerms()

        XCTAssertEqual(recentSearchTerms.count, 1)
    }

    func test_delete_DeletesAllResults() {
        sut.insert(searchTerm: "a")
        sut.insert(searchTerm: "b")
        sut.insert(searchTerm: "c")

        var recentSearchTerms = sut.recentSearchTerms()

        XCTAssertEqual(recentSearchTerms.count, 3)

        sut.clearSearchHistory()
        recentSearchTerms = sut.recentSearchTerms()

        XCTAssertEqual(recentSearchTerms.count, 0)
    }

}

class MockUserDataStore: UserDataStore {

    var recentSearches = [String]()

    func fetchContents() -> [String] {
        return recentSearches
    }

    func insertContent(_ string: String) {
        recentSearches.insert(string, at: 0)
    }

    func deleteAllContents() {
        recentSearches = []
    }

}
