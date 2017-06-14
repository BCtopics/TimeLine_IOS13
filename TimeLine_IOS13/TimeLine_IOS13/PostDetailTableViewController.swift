//
//  PostDetailTableViewController.swift
//  TimeLine_IOS13
//
//  Created by Bradley GIlmore on 6/12/17.
//  Copyright © 2017 Bradley Gilmore. All rights reserved.
//

import UIKit

class PostDetailTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(postCommentsChanged(_:)), name: PostController.PostCommentsChangedNotification, object: nil)
        
        // Dynamic Heights
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 40
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateViews()
    }
    
    func postCommentsChanged(_ notification: Notification) {
        
        guard let notificationPost = notification.object as? Post,
            let post = post, notificationPost === post else { return } // Not our post
        updateViews()
    }
    
    //MARK: - Properties
    
    var post: Post?
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var postImageView: UIImageView!
    
    //MARK: - IBActions
    
    @IBAction func commentButtonTapped(_ sender: Any) {
        
        var alertTextField: UITextField?
        
        let alertController = UIAlertController(title: "Add Comment", message: "Please enter your comment", preferredStyle: .alert)
        
        alertController.addTextField { (textField) in
            alertTextField = textField
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let addAction = UIAlertAction(title: "Add", style: .default) { _ in
            
            guard let text = alertTextField?.text, !text.isEmpty else { return }
            guard let post = self.post else { return }
            
            PostController.shared.addComment(toPost: post, text: text)
            
            self.updateViews()
        }
        // ^^Creates the new comment from the text we put in the textfield
        
        alertController.addAction(addAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func shareButtonTapped(_ sender: Any) {
        
        guard let photo = post?.photo,
            let comment = post?.comments.first else { return }
        
        let text = comment.text
        let activityViewController = UIActivityViewController(activityItems: [photo, text], applicationActivities: nil)
        
        present(activityViewController, animated: true, completion: nil)
    }
    
    @IBAction func followButtonTapped(_ sender: Any) {
        
        
        
    }
    
    
    //MARK: - Update
    
    func updateViews() {
        
        guard let post = post else { return }
        postImageView.image = post.photo
        self.tableView.reloadData()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let post = post else { return 0 }
        return post.comments.count //FIXME: - Is this right?
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath)

        let comment = self.post?.comments[indexPath.row]
        cell.textLabel?.text = comment?.text
        cell.detailTextLabel?.text = "\(comment?.timestamp)" //FIXME: - Fix time

        return cell
    }
}
