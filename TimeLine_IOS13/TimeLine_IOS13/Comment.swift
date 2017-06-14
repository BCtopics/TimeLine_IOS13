//
//  Comment.swift
//  TimeLine_IOS13
//
//  Created by Bradley GIlmore on 6/12/17.
//  Copyright © 2017 Bradley Gilmore. All rights reserved.
//

import Foundation
import CloudKit

class Comment: CloudKitSyncable {
    
    //MAKR: - Keys
    
    static let kType = "Comment"
    static let kText = "text"
    static let kPost = "post"
    static let kTimestamp = "timestamp"
    
    //MARK: - Internal Properties
    
    let text: String
    let timestamp: Date
    var post: Post?
    
    //MARK: - Initializers
    
    init(text: String, timestamp: Date = Date(), post: Post?) {
        
        self.text = text
        self.timestamp = timestamp
        self.post = post
    }
    
    // MARK: CloudKitSyncable
    
    convenience required init?(record: CKRecord) {
        
        guard let timestamp = record.creationDate,
            let text = record[Comment.kText] as? String else { return nil }
        
        self.init(text: text, timestamp: timestamp, post: nil)
        cloudKitRecordID = record.recordID
    }
    
    var cloudKitRecordID: CKRecordID?
    var recordType: String { return Comment.kType }
    
}

//MARK: - SearchableRecord Functions

extension Comment: SearchableRecord {
    func matches(searchTerm: String) -> Bool {
        return text.contains(searchTerm)
    }
}

extension CKRecord {
    convenience init(_ comment: Comment) {
        guard let post = comment.post else { fatalError("Comment's Post is nil") }
        let postRecordID = post.cloudKitRecordID ?? CKRecord(post).recordID
        let recordID = CKRecordID(recordName: UUID().uuidString)
        
        self.init(recordType: comment.recordType, recordID: recordID)
        
        self[Comment.kTimestamp] = comment.timestamp as CKRecordValue?
        self[Comment.kText] = comment.text as CKRecordValue?
        self[Comment.kPost] = CKReference(recordID: postRecordID, action: .deleteSelf)
    }
}

