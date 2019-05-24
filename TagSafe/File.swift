//
//  File.swift
//  TagSafe
//
//  Created by PATTYN Willem-Jan (s) on 24/05/2019.
//  Copyright © 2019 Erasmix4. All rights reserved.
//

import UIKit

class File: NSObject {

    var id: String
    var filename: String
    var fileDetail: String
    var fileType: String
    var date: String
    var content: String
    
    init(id: String, name: String, detail: String, type: String, date: String, content: String) {
        self.id = id
        self.filename = name
        self.fileDetail = detail
        self.fileType = type
        self.date = date
        self.content = content
    }
}
