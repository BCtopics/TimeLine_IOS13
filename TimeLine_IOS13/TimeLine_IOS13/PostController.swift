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
    }
    
    //MARK: - FetchFunction
    
    func fetchNewRecordsOf(type: String, completion: @escaping (() -> Void) = { _ in }) {
        
        // Get the CKReferences of already fetched posts, this way we aren't fetching anything we don't need to
        var refExcluded = [CKReference]()
        refExcluded = self.syncedRecordsOf(type: type).flatMap { $0.cloudKitReference }
        
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
                }
            case Comment.kType:
                guard let postReference = record[Comment.kPost] as? CKReference,
                    let postIndex = self.posts.index(where: { $0.cloudKitRecordID == postReference.recordID }),
                    let comment = Comment(record: record) else { return }
                let post = self.posts[postIndex]
                post.comments.append(comment)
                comment.post = post
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
    
    
    
}















