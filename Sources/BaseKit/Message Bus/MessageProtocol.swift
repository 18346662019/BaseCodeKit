//
//  MessageProtocol.swift
//  fff
//
//  Created by apple on 2026/2/6.
//

import Foundation
protocol MessageProtocol {
    var id: String { get }
    var sender: AnyHashable? { get }
    var timestamp: Date { get }
}

struct Message: MessageProtocol {
    let id: String
    let sender: AnyHashable?
    let timestamp: Date
    let payload: Any?
    
    init(id: String, sender: AnyHashable?, timestamp: Date, payload: Any?) {
        self.id = id
        self.sender = sender
        self.timestamp = timestamp
        self.payload = payload
    }
}
