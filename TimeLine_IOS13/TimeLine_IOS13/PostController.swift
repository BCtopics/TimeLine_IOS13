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
    
    //MARK: - Initializers
    
    init() {
        self.peformFullSync {
            //FIXME: - Get rid of this empty area.
        }
    }
    
    //MARK: - Shared Instances
    
    static let shared = PostController()
    
    //MARK: - Properties
    
    var isSyncing: Bool = false
    let cloudKitManager = CloudKitManager()
    var posts: [Post] = [] {
        didSet {
            DispatchQueue.main.async {
                let nc = NotificationCenter.default
                nc.post(name: PostController.PostsChangedNotification, object: self)
            }
        }
    }
    
    var comments: [Comment] {
        return posts.flatMap { $0.comments }
    }
    
    //MARK: - What To Sync Helper Functions
    
    private func recordsOf(type: String) -> [CloudKitSyncable] {
        switch type {
        case "Post":
            return posts.flatMap { $0 as CloudKitSyncable }
        case "Comment":
            return comments.flatMap { $0 as CloudKitSyncable }
        default:
            return []
        }
    }
    
    func syncedRecordsOf(type: String) -> [CloudKitSyncable] {
        return recordsOf(type: type).filter { $0.isSynced }
    }
    
    func unsyncedRecordsOf(type: String) -> [CloudKitSyncable] {
        return recordsOf(type: type).filter { !$0.isSynced }
    }
    
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
        
        DispatchQueue.main.async {
            let nc = NotificationCenter.default
            nc.post(name: PostController.PostCommentsChangedNotification, object: post)
        }
    }
    
    //MARK: - FetchFunction
    
    func fetchNewRecordsOf(type: String, completion: @escaping (() -> Void) = { _ in }) {
        
        // Get the CKReferences of already fetched posts, this way we aren't fetching anything we don't need to
        var refExcluded = [CKReference]()
        let syncedRecords = self.syncedRecordsOf(type: type)
        
        refExcluded = syncedRecords.flatMap({ $0.cloudKitReference })
        
        // Create predicate for FetchRequest
        var predicate: NSPredicate!
        predicate = NSPredicate(format: "NOT(recordID IN %@)", argumentArray: [refExcluded])
        
        // If we haven't fetched any posts, fetch them all
        if refExcluded.isEmpty {
            predicate = NSPredicate(value: true)
        }
        
        cloudKitManager.fetchRecordsWithType(type, predicate: predicate, recordFetchedBlock: { (record) in
            
            switch type {
            case Post.kType:
                if let post = Post(record: record) {
                    self.posts.append(post)
                    post.cloudKitRecordID = record.recordID
                }
            case Comment.kType:
                guard let postReference = record[Comment.kPost] as? CKReference,
                    let postIndex = self.posts.index(where: { $0.cloudKitRecordID == postReference.recordID }),
                    let comment = Comment(record: record) else { return }
                let post = self.posts[postIndex]
                post.comments.append(comment)
                comment.post = post
                
                comment.cloudKitRecordID = record.recordID
            default: return
                }
            
        }) { (record, error) in
            
            if let error = error {
                NSLog("Failed to fetch records from cloudkit \(error.localizedDescription)")
                return
            }
            completion()
        }
        
    }
    
    //MARK: - Push Changes To CloudKit
    
    func pushChangesToCloudKit(completion: @escaping (Bool, Error?) -> Void) {
        
        // Get unsavedPosts
        let unsavedPosts = unsyncedRecordsOf(type: Post.kType) as? [Post] ?? []
        
        // Get unsavedComments
        let unsavedComments = unsyncedRecordsOf(type: Comment.kType) as? [Comment] ?? []
        
        // Create an empty dictionary variable to hold these objecs.
        var unsavedObjectsByRecord = [CKRecord: CloudKitSyncable]()
        
        // Go through everything in the unsavedPosts and create a CKRecord for it, Then add that to the unsavedObjectsByRecord
        for post in unsavedPosts {
            let newRecord = CKRecord(post)
            unsavedObjectsByRecord[newRecord] = post
        }
        
        // Go through everything in the unsavedComments and create a CKRecord for it, Then add that to the unsavedObjectsByRecord
        for comment in unsavedComments {
            let newRecord = CKRecord(comment)
            unsavedObjectsByRecord[newRecord] = comment
        }
        
        // These are the unsavedRecords of all the objects, dictionaries keys which lead to CKRecord Objects.
        let unsavedRecords = Array(unsavedObjectsByRecord.keys)
        
        cloudKitManager.saveRecords(unsavedRecords, perRecordCompletion: { (record, error) in
            
            if let error = error {
                NSLog("Error Saving CloudKitRecords. \(error.localizedDescription)")
                return
            }
            
            // Check that the record is there, then make that records id equal to the actual recordID.
            guard let record = record else { return }
            unsavedObjectsByRecord[record]?.cloudKitRecordID = record.recordID
            
        }) { (record, error) in
            
            // As long as record isn't nil success will be true, pass back through the completion true, and nil if succeds
            let success = record != nil
            completion(success, error)
            
        }
    }
    
    //MARK: - Perform Full Sync Function
    
    func peformFullSync(completion: @escaping () -> (Void)) {
        
        // Make sure nothing is currenty syncing, if it's not set isSyncing to true and begin sync proccess
        if isSyncing == true {
            NSLog("Syncing is already in progress")
            completion()
            return
        } else {
            isSyncing = true
        }
        
        // Push Changes to cloudKit
        self.pushChangesToCloudKit { (success, error) in
            
            if let error = error {
                NSLog("Error pushing changes to cloudkit \(error.localizedDescription)")
                return
            }
            
            if success {
                
                // Fetch New Post Records From CloudKit
                self.fetchNewRecordsOf(type: Post.kType, completion: {
                    
                    // Fetch New Commment Records From CloudKit
                    self.fetchNewRecordsOf(type: Comment.kType, completion: {
                        
                        self.isSyncing = false
                        completion()
                        
                    })
                })
                NSLog("Pushing Changes to cloudkit was a success!")
                return
            } else {
                NSLog("Success was not true for pushingtocloudkit function")
                return
            }
            
        }
        
    }
    
}

//MARK: - Notifications

extension PostController {
    static let PostsChangedNotification = Notification.Name("PostsChangedNotification")
    static let PostCommentsChangedNotification = Notification.Name("PostCommentsChangedNotification")
}















