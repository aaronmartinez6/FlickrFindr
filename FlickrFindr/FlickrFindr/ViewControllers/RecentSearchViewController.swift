//
//  RecentSearchViewController.swift
//  FlickrFindr
//
//  Created by Aaron Martinez on 9/23/19.
//  Copyright © 2019 Aaron Martinez. All rights reserved.
//

import UIKit

class RecentSearchViewController: UIViewController {

    let recentSearchManager: RecentSearchManager

    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .systemGroupedBackground
        tableView.separatorStyle = .none
        tableView.keyboardDismissMode = .onDrag
        return tableView
    }()

    init(recentSearchManager: RecentSearchManager) {
        self.recentSearchManager = recentSearchManager

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
    }

    func setupViews() {
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.readableContentGuide.leadingAnchor),
            tableView.topAnchor.constraint(equalTo: view.readableContentGuide.topAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.readableContentGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.readableContentGuide.bottomAnchor)
        ])
    }

}

extension RecentSearchViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recentSearchManager.recentSearchTerms().count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecentSearchCell", for: indexPath)
        let recentSearchTerm = recentSearchManager.recentSearchTerms()[safe: indexPath.row] ?? ""
        cell.textLabel?.text = recentSearchTerm
        return cell
    }
}

extension RecentSearchViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Tapped recent search")
    }
}

extension RecentSearchViewController: RecentSearchManagerDelegate {

    func recentSearchTermsWereUpdated() {
        tableView.reloadData()
    }
}
