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
