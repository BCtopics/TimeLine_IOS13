//
//  Comment.swift
//  TimeLine_IOS13
//
//  Created by Bradley GIlmore on 6/12/17.
//  Copyright © 2017 Bradley Gilmore. All rights reserved.
//

import Foundation

class Comment {
    
    //MARK: - Internal Properties
    
    let text: String
    let timestamp: Date
    let post: Post
    
    //MARK: - Initializers
    
    init(text: String, timestamp: Date = Date(), post: Post) {
        
        self.text = text
        self.timestamp = timestamp
        self.post = post
    }
    
}

//MARK: - SearchableRecord Functions

extension Comment: SearchableRecord {
    func matches(searchTerm: String) -> Bool {
        return text.contains(searchTerm)
    }
}

