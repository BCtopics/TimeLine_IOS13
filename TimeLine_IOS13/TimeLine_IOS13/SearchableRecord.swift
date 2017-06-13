//
//  SearchableRecord.swift
//  TimeLine_IOS13
//
//  Created by Bradley GIlmore on 6/13/17.
//  Copyright © 2017 Bradley Gilmore. All rights reserved.
//

import Foundation

protocol SearchableRecord {
    
    func matches(searchTerm: String) -> Bool
    
}
