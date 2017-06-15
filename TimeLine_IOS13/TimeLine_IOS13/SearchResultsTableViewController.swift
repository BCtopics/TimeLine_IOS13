//
//  SearchResultsTableViewController.swift
//  TimeLine_IOS13
//
//  Created by Bradley GIlmore on 6/12/17.
//  Copyright © 2017 Bradley Gilmore. All rights reserved.
//

import UIKit

class SearchResultsTableViewController: UITableViewController {
    
    //MARK: - Properties
    
    var resultsArray: [SearchableRecord] = []

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultsArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "searchPostCell", for: indexPath) as? PostTableViewCell else { return UITableViewCell() }

        guard let post = resultsArray[indexPath.row] as? Post else { return UITableViewCell() }
        cell.post = post

        return cell
    }
    
    //MARK: - UITableViewDelegate Functions
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sender = tableView.cellForRow(at: indexPath)
        presentingViewController?.performSegue(withIdentifier: "toDetailView", sender: sender)
    }
}
