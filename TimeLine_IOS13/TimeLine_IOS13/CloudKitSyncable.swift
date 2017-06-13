//
//  CloudKitSyncable.swift
//  TimeLine_IOS13
//
//  Created by Bradley GIlmore on 6/13/17.
//  Copyright © 2017 Bradley Gilmore. All rights reserved.
//

import Foundation
import CloudKit

protocol CloudKitSyncable {
    
init?(record: CKRecord)

var cloudKitRecordID: CKRecordID? { get set }
var recordType: String { get }
    
}

extension CloudKitSyncable {
    var isSynced: Bool {
        return cloudKitRecordID != nil
    }
    
    var cloudKitReference: CKReference? {
        
        guard let recordID = cloudKitRecordID else { return nil }
        
        return CKReference(recordID: recordID, action: .none)
    }
}
