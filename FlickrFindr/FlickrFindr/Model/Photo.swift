//
//  Photo.swift
//  FlickrFindr
//
//  Created by Aaron Martinez on 9/20/19.
//  Copyright © 2019 Aaron Martinez. All rights reserved.
//

import UIKit

struct Photo: Decodable {

    enum CodingKeys: String, CodingKey {
        case imageID = "id"
        case serverID = "server"
        case farmID = "farm"
        case secret, title
    }

    var imageID: String
    var secret: String
    var serverID: String
    var farmID: Int
    var title: String
    var image: UIImage?
}

struct PhotosDictionary: Decodable {
    
    let photos: [Photo]
    
    enum CodingKeys: String, CodingKey {
        case photos = "photo"
    }
}

struct TopLevelObject: Decodable {

    enum CodingKeys: String, CodingKey {
        case photosDictionary = "photos"
    }

    let photosDictionary: PhotosDictionary
}
