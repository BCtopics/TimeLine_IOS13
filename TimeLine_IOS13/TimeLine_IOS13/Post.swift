//
//  Post.swift
//  TimeLine_IOS13
//
//  Created by Bradley GIlmore on 6/12/17.
//  Copyright © 2017 Bradley Gilmore. All rights reserved.
//

import UIKit

class Post {
    
    //MARK: - Internal Properties
    
    let photoData: Data?
    let timestamp: Date
    var comments: [Comment]
    
    // Create photo from photoData
    var photo: UIImage {
        guard let photoData = photoData else { NSLog("photoData was nil when trying to create the photo"); return UIImage() }
        guard let image = UIImage(data: photoData) else { NSLog("Error creating image"); return UIImage() }
        return image
    }
    
    //MARK: - Initializers
    
    init(photoData: Data?, timestamp: Date = Date(), comments: [Comment] = []) {
        guard let photoData = photoData else { return }
        
        self.photoData = photoData
        self.timestamp = timestamp
        self.comments = comments
    }
}
