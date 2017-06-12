//
//  PostController.swift
//  TimeLine_IOS13
//
//  Created by Bradley GIlmore on 6/12/17.
//  Copyright © 2017 Bradley Gilmore. All rights reserved.
//

import UIKit

class PostController {
    
    //MARK: - Shared Instances
    
    static let shared = PostController()
    
    //MARK: - Properties
    
    var posts: [Post] = []
    
    //MARK: - Create, and Add Functions
    
    func createPostWith(image: UIImage, caption: String) {
        
        // Get data from the image
        guard let data = UIImageJPEGRepresentation(image, 0.8) else { return }
        
        let post: Post = Post(photoData: data)
        addComment(toPost: post, text: caption)
        
        self.posts.append(post)
    }
    
    func addComment(toPost post: Post, text: String) {
        let comment = Comment(text: text, post: post)
        post.comments.append(comment)
    }
    
}
