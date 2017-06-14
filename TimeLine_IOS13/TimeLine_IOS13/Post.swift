//
//  Post.swift
//  TimeLine_IOS13
//
//  Created by Bradley GIlmore on 6/12/17.
//  Copyright © 2017 Bradley Gilmore. All rights reserved.
//

import UIKit
import CloudKit

class Post: CloudKitSyncable {
    
    //MARK: - Keys
    
    static let kTimestamp = "timestamp"
    static let kPhotoData = "photoData"
    static let kType = "post"
    
    //MARK: - Internal Properties
    
    let photoData: Data?
    let timestamp: Date
    var comments: [Comment]
    var cloudKitRecordID: CKRecordID?
    
    var recordType: String {
        return "post"
    }
    
    // Create photo from photoData
    var photo: UIImage {
        guard let photoData = photoData else { NSLog("photoData was nil when trying to create the photo"); return UIImage() }
        guard let image = UIImage(data: photoData) else { NSLog("Error creating image"); return UIImage() }
        return image
    }
    
    //MARK: - Initializers
    
    init(photoData: Data?, timestamp: Date = Date(), comments: [Comment] = []) {

        self.photoData = photoData
        self.timestamp = timestamp
        self.comments = comments
    }
    
    convenience required init?(record: CKRecord) {
        
        guard let timestamp = record.creationDate,
            let photoAsset = record[Post.kPhotoData] as? CKAsset else { return nil }
        
        let photoData = try? Data(contentsOf: photoAsset.fileURL)
        self.init(photoData: photoData, timestamp: timestamp)
        cloudKitRecordID = record.recordID
    }
}


//MARK: - SearchableRecord Functions

extension Post: SearchableRecord {
    func matches(searchTerm: String) -> Bool {
        let matchingComments = comments.filter { $0.matches(searchTerm: searchTerm) }
        return !matchingComments.isEmpty
    }
    
    
    //MARK: - CloudKitSyncable
    
    fileprivate var temporaryPhotoURL: URL {
        
        // Must write to temporary directory to be able to pass image file path url to CKAsset
        
        let temporaryDirectory = NSTemporaryDirectory()
        let temporaryDirectoryURL = URL(fileURLWithPath: temporaryDirectory)
        let fileURL = temporaryDirectoryURL.appendingPathComponent(UUID().uuidString).appendingPathExtension("jpg")
        
        try? photoData?.write(to: fileURL, options: [.atomic])
        
        return fileURL
    }
}

extension CKRecord {
    convenience init(_ post: Post) {
        let recordID = CKRecordID(recordName: UUID().uuidString)
        self.init(recordType: post.recordType, recordID: recordID)
        
        self[Post.kTimestamp] = post.timestamp as CKRecordValue?
        self[Post.kPhotoData] = CKAsset(fileURL: post.temporaryPhotoURL)
    }
}
