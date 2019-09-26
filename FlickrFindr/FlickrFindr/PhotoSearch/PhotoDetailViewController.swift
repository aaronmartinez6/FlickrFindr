//
//  PhotoDetailViewController.swift
//  FlickrFindr
//
//  Created by Aaron Martinez on 9/21/19.
//  Copyright © 2019 Aaron Martinez. All rights reserved.
//

import UIKit

class PhotoDetailViewController: UIViewController {

    lazy var photoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        return activityIndicator
    }()

    let photo: Photo
    let imageProvider: ImageProvider

    init(photo: Photo, imageProvider: ImageProvider) {
        self.photo = photo
        self.imageProvider = imageProvider

        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        activityIndicator.startAnimating()

        view.backgroundColor = .systemBackground
        title = photo.title

        setupViews()

        imageProvider.fetchImage(for: photo) { [weak self] result in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                
                if case let .success(image) = result {
                    self?.photoImageView.image = image
                    self?.view.setNeedsDisplay()
                }
            }
        }
    }

    func setupViews() {
        view.addSubview(photoImageView)
        view.addSubview(activityIndicator)

        NSLayoutConstraint.activate([
            photoImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            photoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            photoImageView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            photoImageView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            activityIndicator.centerXAnchor.constraint(equalTo: photoImageView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: photoImageView.centerYAnchor)
        ])
    }

}
