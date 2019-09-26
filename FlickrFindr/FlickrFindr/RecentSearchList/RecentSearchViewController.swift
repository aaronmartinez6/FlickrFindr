//
//  RecentSearchViewController.swift
//  FlickrFindr
//
//  Created by Aaron Martinez on 9/23/19.
//  Copyright © 2019 Aaron Martinez. All rights reserved.
//

protocol RecentSearchViewControllerDelegate: class {
    func recentSearchTermTapped(searchTerm: String)
    func clearSearchHistoryTapped()
}

import UIKit

class RecentSearchViewController: UIViewController {

    weak var delegate: RecentSearchViewControllerDelegate?

    private let recentSearchManager: RecentSearchManagerService

    private var recentSearches = [String]()

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .systemBackground
        tableView.separatorStyle = .none
        tableView.keyboardDismissMode = .onDrag
        return tableView
    }()

    init(recentSearchManager: RecentSearchManager) {
        self.recentSearchManager = recentSearchManager
        recentSearches = recentSearchManager.recentSearchTerms()

        super.init(nibName: nil, bundle: nil)

        recentSearchManager.delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "RecentSearchCell")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "TrashSearchesCell")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        reloadTableView()
    }

    private func setupViews() {
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.readableContentGuide.leadingAnchor),
            tableView.topAnchor.constraint(equalTo: view.readableContentGuide.topAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.readableContentGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.readableContentGuide.bottomAnchor)
        ])
    }

    private func reloadTableView() {
        recentSearches = recentSearchManager.recentSearchTerms()
        tableView.reloadData()
    }

}

extension RecentSearchViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return !recentSearches.isEmpty ? recentSearches.count + 1 : 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if !recentSearches.isEmpty && indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TrashSearchesCell", for: indexPath)
            cell.textLabel?.text = NSLocalizedString("🗑 Clear History 🗑", comment: "Title for button to clear search history")
            cell.backgroundColor = .tertiarySystemGroupedBackground
            cell.textLabel?.textColor = .systemRed
            cell.textLabel?.textAlignment = .center
            return cell
        } else {
            let recentSearchTerm = recentSearches[safe: indexPath.row - 1] ?? ""

            let cell = tableView.dequeueReusableCell(withIdentifier: "RecentSearchCell", for: indexPath)
            cell.textLabel?.text = recentSearchTerm
            cell.backgroundColor = .secondarySystemGroupedBackground
            return cell
        }
    }
}

extension RecentSearchViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            delegate?.clearSearchHistoryTapped()
            reloadTableView()
        } else if let searchTerm = recentSearches[safe: indexPath.row - 1] {
            delegate?.recentSearchTermTapped(searchTerm: searchTerm)
        }
    }
}

extension RecentSearchViewController: RecentSearchManagerDelegate {

    func recentSearchTermsWereUpdated() {
        reloadTableView()
    }
}
