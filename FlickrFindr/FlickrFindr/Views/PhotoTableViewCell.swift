//
//  PhotoTableViewCell.swift
//  FlickrFindr
//
//  Created by Aaron Martinez on 9/20/19.
//  Copyright © 2019 Aaron Martinez. All rights reserved.
//

import UIKit

class PhotoTableViewCell: UITableViewCell {

    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!

    func configure(with photo: Photo) {

        backgroundColor = .systemBackground

        photoImageView.backgroundColor = .systemGray2
        photoImageView.layer.cornerRadius = 15
        photoImageView.clipsToBounds = true

        titleLabel.text = photo.title
    }

    override func prepareForReuse() {
        photoImageView.image = nil
        titleLabel.text = nil
    }
}
