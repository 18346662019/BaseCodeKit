//
//  IMessageBusService.swift
//  fff
//
//  Created by apple on 2026/2/10.
//

import Foundation
protocol IMessageHistoryService {
    func saveMessage(message: Message)
    func getMessageHistory() -> [Message]
    func getMessageHistory(forMessageId messageId: String) -> [Message]
}
class MemoryMessageHistoryService: IMessageHistoryService {
    private var messageHistory: [Message] = []
    private var maxHistoryCount: Int = 100
    
    func saveMessage(message: Message) {
        messageHistory.append(message)
        if messageHistory.count > maxHistoryCount {
            messageHistory.removeFirst(messageHistory.count - maxHistoryCount)
        }
    }
    
    func getMessageHistory() -> [Message] {
        return messageHistory
    }
    
    func getMessageHistory(forMessageId messageId: String) -> [Message] {
       return  messageHistory.filter({$0.id == messageId })
    }
}
    
    
