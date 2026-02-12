//
//  SubscriberIdentifer.swift
//  fff
//
//  Created by apple on 2026/2/6.
//

import Foundation

public struct SubscriberIdentifer: Hashable {
    let id: UUID
    let type: String
    
    init(id: UUID, type: String = "default") {
        self.id = id
        self.type = type
    }
}
