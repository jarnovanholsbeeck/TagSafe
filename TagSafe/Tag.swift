//
//  Tag.swift
//  TagSafe
//
//  Created by Jarno Van Holsbeeck on 21/05/2019.
//  Copyright © 2019 Erasmix4. All rights reserved.
//

import UIKit

class Tag: NSObject {
    var color: String!
    var name: String!
    
    init(color: String, name: String) {
        self.color = color
        self.name = name
    }
}
