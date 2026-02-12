//
//  MessageProtocol.swift
//  fff
//
//  Created by apple on 2026/2/6.
//

import Foundation
public protocol MessageProtocol {
    var id: String { get }
    var sender: AnyHashable? { get }
    var timestamp: Date { get }
}

public struct Message: MessageProtocol {
    public let id: String
    public let sender: AnyHashable?
    public let timestamp: Date
    public let payload: Any?
    
    init(id: String, sender: AnyHashable?, timestamp: Date, payload: Any?) {
        self.id = id
        self.sender = sender
        self.timestamp = timestamp
        self.payload = payload
    }
}
