//
//  Tag.swift
//  TagSafe
//
//  Created by PATTYN Willem-Jan (s) on 20/05/2019.
//  Copyright © 2019 Erasmix4. All rights reserved.
//

import UIKit

class Tag: NSObject {
    var id: String?
    var name: String?
    var color: String?
    
    init(id: String?, name: String?, color: String?) {
        self.id = id
        self.name = name
        self.color = color
    }
    
}
