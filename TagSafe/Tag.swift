//
//  Tag.swift
//  TagSafe
//
//  Created by PATTYN Willem-Jan (s) on 20/05/2019.
//  Copyright © 2019 Erasmix4. All rights reserved.
//

import UIKit

class Tag: NSObject {
    var name: String?
    var color: String?
    
    init(name: String?, color: String?) {
        self.name = name
        self.color = color
    }
}
