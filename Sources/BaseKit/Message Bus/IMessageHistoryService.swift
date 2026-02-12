//
//  IMessageBusService.swift
//  fff
//
//  Created by apple on 2026/2/10.
//

import Foundation
public protocol IMessageHistoryService {
    func saveMessage(message: Message)
    func getMessageHistory() -> [Message]
    func getMessageHistory(forMessageId messageId: String) -> [Message]
}
public class MemoryMessageHistoryService: IMessageHistoryService {
    public var messageHistory: [Message] = []
    public var maxHistoryCount: Int = 100
    
    public func saveMessage(message: Message) {
        messageHistory.append(message)
        if messageHistory.count > maxHistoryCount {
            messageHistory.removeFirst(messageHistory.count - maxHistoryCount)
        }
    }
    
    public func getMessageHistory() -> [Message] {
        return messageHistory
    }
    
    public func getMessageHistory(forMessageId messageId: String) -> [Message] {
       return  messageHistory.filter({$0.id == messageId })
    }
}
    
    
