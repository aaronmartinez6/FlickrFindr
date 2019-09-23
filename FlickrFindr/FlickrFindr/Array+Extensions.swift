//
//  Array+Extensions.swift
//  FlickrFindr
//
//  Created by Aaron Martinez on 9/22/19.
//  Copyright © 2019 Aaron Martinez. All rights reserved.
//

import Foundation

extension Array {

    subscript(safe index: Int) -> Element? {
        return indices ~= index ? self[index] : nil
    }
    
}
