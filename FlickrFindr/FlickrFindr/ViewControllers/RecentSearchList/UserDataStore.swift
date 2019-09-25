//
//  UserDataStore.swift
//  FlickrFindr
//
//  Created by Aaron Martinez on 9/25/19.
//  Copyright © 2019 Aaron Martinez. All rights reserved.
//

import Foundation

protocol UserDataStore {

    func fetchContents() -> [String]
    func insertContent(_ string: String)
}
