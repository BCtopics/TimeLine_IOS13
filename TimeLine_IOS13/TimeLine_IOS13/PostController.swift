//
//  PostController.swift
//  TimeLine_IOS13
//
//  Created by Bradley GIlmore on 6/12/17.
//  Copyright © 2017 Bradley Gilmore. All rights reserved.
//

import UIKit
import CloudKit

class PostController {
    
    //MARK: - Shared Instances
    
    static let shared = PostController()
    
    //MARK: - Properties
    
    let cloudKitManager = CloudKitManager()
    var posts: [Post] = []
    
    //MARK: - Create, and Add Functions
    
    func createPostWith(image: UIImage, caption: String) {
        
        // Get data from the image
        guard let data = UIImageJPEGRepresentation(image, 0.8) else { return }
        
        let post: Post = Post(photoData: data)
        addComment(toPost: post, text: caption)

        cloudKitManager.saveRecord(CKRecord(post)) { (record, error) in
            if let error = error {
                NSLog("Error saving Post record \(error.localizedDescription)")
                return
            }
            
            guard let recordID = record?.recordID else { return }
            post.cloudKitRecordID = recordID
        }
        
        self.posts.append(post)
    }
    
    func addComment(toPost post: Post, text: String) {
        let comment = Comment(text: text, post: post)
        
        cloudKitManager.saveRecord(CKRecord(comment)) { (record, error) in
            if let error = error {
                NSLog("Error saving Comment record \(error.localizedDescription)")
                return
            }
            
            guard let recordID = record?.recordID else { return }
            comment.cloudKitRecordID = recordID
        }
        
        post.comments.append(comment)
    }
    
}















