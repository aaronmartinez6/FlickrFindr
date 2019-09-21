//
//  SearchTableViewController.swift
//  FlickrFindr
//
//  Created by Aaron Martinez on 9/20/19.
//  Copyright © 2019 Aaron Martinez. All rights reserved.
//

import UIKit

class SearchTableViewController: UITableViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!

    var imageProvider: ImageProvider?

    lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        return activityIndicator
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Flickr Findr"

        imageProvider = ImageProvider()

        view.backgroundColor = .systemBackground

        view.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            ])

        searchBar.delegate = self
        searchBar.placeholder = NSLocalizedString("What would you like to see?", comment: "Placeholder text in search bar.")

        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = 300
        tableView.rowHeight = UITableView.automaticDimension

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return imageProvider?.photos.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PhotoCell", for: indexPath) as?   PhotoTableViewCell,
            let photo = imageProvider?.photos[indexPath.row]
        else { return UITableViewCell() }

        cell.configure(with: photo)

        imageProvider?.fetchImage(farmID: photo.farmID, serverID: photo.serverID, imageID: photo.imageID, secret: photo.secret) { result in

            DispatchQueue.main.async {
                switch result {
                case .success(let image):
                    guard let indexPathOfCell = tableView.indexPath(for: cell),
                        indexPathOfCell == indexPath else { return }

                    cell.photoImageView?.image = image
                case .failure(let error):
                    print(error)
                }
            }
        }

        return cell
    }

}

// MARK: - UITableViewDataSourcePrefetching

extension SearchTableViewController: UITableViewDataSourcePrefetching {

    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {

        indexPaths.forEach { indexPath in
            guard let photo = imageProvider?.photos[indexPath.row] else { return }

            imageProvider?.fetchImage(farmID: photo.farmID, serverID: photo.serverID, imageID: photo.imageID, secret: photo.secret) { _ in
                // Image is now in the cache
            }
        }
    }

}

// MARK: - Search Bar Delegate

extension SearchTableViewController: UISearchBarDelegate {

    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        return true
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.isEmpty == true {
            // Reload table view with previous search suggestions
        }
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()

        guard let searchTerm = searchBar.text,
            !searchTerm.isEmpty
            else { return }

        activityIndicator.startAnimating()

        imageProvider?.fetchPhotos(for: searchTerm) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .failure(let error):
                    print(error)
                case .success(_):
                    self?.activityIndicator.stopAnimating()
                    self?.tableView.reloadData()
                }
            }
        }
    }
}
