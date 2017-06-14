//
//  PostListTableViewController.swift
//  TimeLine_IOS13
//
//  Created by Bradley GIlmore on 6/12/17.
//  Copyright © 2017 Bradley Gilmore. All rights reserved.
//

import UIKit

class PostListTableViewController: UITableViewController, UISearchResultsUpdating {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.requestFullSync()
        
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(refresh), name: PostController.PostsChangedNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
    }
    
    func refresh() {
        self.tableView.reloadData()
    }
    
    //MARK: - IBActions
    
    @IBAction func refreshPulled(_ sender: Any) {
        
        self.requestFullSync() {
            self.refreshControl?.endRefreshing()
        }
        
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return PostController.shared.posts.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as? PostTableViewCell else { return UITableViewCell() }
        
        let post = PostController.shared.posts[indexPath.row]
        cell.post = post

        return cell
    }
    
    //MARK: - SearchResultsController Functions
    
    private func setUpSearchController() {
        
        let resultsController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SearchResultsTableViewController")
        
        searchController = UISearchController(searchResultsController: resultsController)
        searchController?.searchResultsUpdater = self
        searchController?.searchBar.sizeToFit()
        searchController?.hidesNavigationBarDuringPresentation = true
        tableView.tableHeaderView = searchController?.searchBar
        
        definesPresentationContext = true
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        
        if let resultsViewController = searchController.searchResultsController as? SearchResultsTableViewController,
            let searchTerm = searchController.searchBar.text?.lowercased() {
            
            let posts = PostController.shared.posts
            let filteredPosts = posts.filter { $0.matches(searchTerm: searchTerm) }.map { $0 as SearchableRecord }
            resultsViewController.resultsArray = filteredPosts
            resultsViewController.tableView.reloadData()
        }
    }
    
    //MARK: - Properties
    
    var searchController: UISearchController?
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // From Initial View
        if segue.identifier == "toDetailView" {
            if let detailVC = segue.destination as? PostDetailTableViewController {
                guard let index = self.tableView.indexPathForSelectedRow?.row else { NSLog("index invalid"); return }
                let post = PostController.shared.posts[index]
                detailVC.post = post
            }
        }
        
        // From Initial View, BUT using a searchTerm
        if segue.identifier == "toPostDetailFromSearch" {
            if let detailViewController = segue.destination as? PostDetailTableViewController,
                let sender = sender as? PostTableViewCell,
                let selectedIndexPath = (searchController?.searchResultsController as? SearchResultsTableViewController)?.tableView.indexPath(for: sender),
                let searchTerm = searchController?.searchBar.text?.lowercased() {
                
                let posts = PostController.shared.posts.filter({ $0.matches(searchTerm: searchTerm) })
                let post = posts[selectedIndexPath.row]
                
                detailViewController.post = post
            }
        }
        
    }
    
    //MARK: - Sync With CloudKit
    
    private func requestFullSync(_ completion: (() -> Void)? = nil) {
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        PostController.shared.peformFullSync { () -> (Void) in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            completion?() //FIXME: - Why Do I have to unwrapp this / Is this optional?
        }
    }
    
}

















