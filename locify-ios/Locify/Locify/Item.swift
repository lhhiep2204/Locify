//
//  Item.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 26/6/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
