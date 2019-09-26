//
//  SearchViewController.swift
//  FlickrFindr
//
//  Created by Aaron Martinez on 9/20/19.
//  Copyright © 2019 Aaron Martinez. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    private let imageProvider = ImageProvider()
    private let recentSearchManager = RecentSearchManager(recentSearchStore: RecentSearchStore())

    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        return activityIndicator
    }()

    private lazy var searchController: UISearchController = {
        let recentSearchViewController = RecentSearchViewController(recentSearchManager: recentSearchManager)
        recentSearchViewController.delegate = self
        let searchController = UISearchController(searchResultsController: recentSearchViewController)
        searchController.searchBar.autocapitalizationType = .none
        searchController.searchBar.autocorrectionType = .default
        searchController.searchBar.enablesReturnKeyAutomatically = true
        searchController.searchBar.placeholder = NSLocalizedString("What would you like to see?", comment: "Placeholder text in search bar.")
        searchController.searchBar.delegate = self
        searchController.automaticallyShowsCancelButton = true
        searchController.showsSearchResultsController = true
        searchController.obscuresBackgroundDuringPresentation = false
        return searchController
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Flickr Findr"

        view.backgroundColor = .systemBackground

        view.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])

        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false

        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = 300
        tableView.rowHeight = UITableView.automaticDimension
        tableView.keyboardDismissMode = .onDrag
    }

    private func presentNoResultsAlert() {
        let alertController = UIAlertController(title: NSLocalizedString("No Results Found", comment: "The alert the user sees if their search returned zero results"), message: nil, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Button user taps to accept that their search returned zero results"), style: .default, handler: nil))
        navigationController?.present(alertController, animated: true, completion: nil)
    }
}

// MARK: - UITableViewDataSource

extension SearchViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return imageProvider.photos.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        fetchNextPage(indexPath: indexPath)

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PhotoCell", for: indexPath) as? PhotoTableViewCell
            else { return UITableViewCell() }

        let photo = imageProvider.photos[indexPath.row]

        cell.configure(with: photo)

        imageProvider.fetchImage(for: photo) { result in
            DispatchQueue.main.async {
                if case let .success(image) = result,
                    let indexPathOfCell = tableView.indexPath(for: cell),
                    indexPathOfCell == indexPath {

                    cell.photoImageView?.image = image
                }
            }
        }

        return cell
    }

    private func fetchNextPage(indexPath: IndexPath) {
        if indexPath.row % 25 == 0 {
            imageProvider.fetchNext { [weak self] result in
                DispatchQueue.main.async {
                    if case let .success(newPhotos) = result,
                        let imageProvider = self?.imageProvider {
                        let firstRow = imageProvider.photos.count - newPhotos.count

                        var indexPaths = [IndexPath]()
                        for index in 0..<newPhotos.count {
                            indexPaths.append(IndexPath(row: index + firstRow, section: 0))
                        }
                        
                        self?.tableView.insertRows(at: indexPaths, with: .none)
                    }
                }
            }
        }
    }

}

// MARK: - UITableViewDelegate

extension SearchViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let photo = imageProvider.photos[safe: indexPath.row]
            else { return }

        let photoDetailViewController = PhotoDetailViewController(photo: photo, imageProvider: imageProvider)
        navigationController?.pushViewController(photoDetailViewController, animated: true)
    }

}

// MARK: - UITableViewDataSourcePrefetching

extension SearchViewController: UITableViewDataSourcePrefetching {

    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {

        indexPaths.forEach { indexPath in
            guard let photo = imageProvider.photos[safe: indexPath.row] else { return }

            imageProvider.fetchImage(for: photo) { _ in } // Image is now in the cache
        }
    }

}

// MARK: - UISearchBar Delegate

extension SearchViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchController.dismiss(animated: false, completion: nil)
        imageProvider.clearPhotosSearchResults()
        tableView.reloadData()

        guard let searchTerm = searchBar.text,
            !searchTerm.isEmpty
            else { return }

        recentSearchManager.insert(searchTerm: searchTerm)

        activityIndicator.startAnimating()

        imageProvider.fetchPhotos(for: searchTerm) { [weak self] result in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                self?.tableView.reloadData()

                switch result {
                case .failure(let error):
                    print(error)
                case .success(_):
                    if self?.imageProvider.photos.isEmpty == true {
                        self?.presentNoResultsAlert()
                    }
                }
            }
        }
    }

}

// MARK: - RecentSearchViewControllerDelegate

extension SearchViewController: RecentSearchViewControllerDelegate {

    func recentSearchTermTapped(searchTerm: String) {
        searchController.searchBar.text = searchTerm
        searchBarSearchButtonClicked(searchController.searchBar)
    }

    func clearSearchHistoryTapped() {
        recentSearchManager.clearSearchHistory()
    }
}
