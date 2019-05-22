//
//  File.swift
//  TagSafe
//
//  Created by Jarno Van Holsbeeck on 22/05/2019.
//  Copyright © 2019 Erasmix4. All rights reserved.
//

import UIKit

class File: NSObject {
    var filename: String
    var fileDetail: String
    var fileType: String
    var date: String
    
    init(name: String, detail: String, type: String, date: String) {
        self.filename = name
        self.fileDetail = detail
        self.fileType = type
        self.date = date
    }
}
