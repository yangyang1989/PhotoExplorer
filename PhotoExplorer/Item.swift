//
//  Item.swift
//  PhotoExplorer
//
//  Created by 杨洋 on 2024/10/2.
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
