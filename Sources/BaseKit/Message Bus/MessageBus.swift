//
//  Moditer.swift
//  fff
//
//  Created by apple on 2026/2/6.
//

import Foundation
import Combine

public final class MessageBus: @unchecked Sendable {
    public static let shared = MessageBus()
    private init() {}
    
    /// 存储所有订阅者
    private var subscriptions: [String: [(SubscriberIdentifer, (Message) -> Void)]] = [:]

    private var messageHistory: [Message] = []
    
    private var maxHistoryCount: Int = 100
    
    private var historyService: IMessageHistoryService?
    
    private let logger = Logger(category: "MessageBus")
    
    func setMessageHistoryService(_historyService: IMessageHistoryService) {
        self.historyService = _historyService
    }
    
    /// 订阅特定消息
    /// - Parameters:
    ///  - messageType: 消息类型
    ///  - subscriberId: 订阅者标识符
    ///  - handler: 处理消息的闭包
    public func subscribe(_ subscriber: SubscriberIdentifer, to messageId: MessageType,  handler: @escaping (Message) -> Void) {
        if subscriptions[messageId.rawValue] == nil {
            subscriptions[messageId.rawValue] = []
        }
        subscriptions[messageId.rawValue]?.append((subscriber, handler))
    }
    
    /// 订阅多个消息
    public func subscribe(_ subscriber: SubscriberIdentifer, to messageIds: [MessageType], handler: @escaping(Message) -> Void) {
        for messageId in messageIds {
            subscribe(subscriber, to: messageId, handler: handler)
        }
    }
    
    
    /// 取消订阅

    /// 取消特定消息
    public func unsubscribe(_ subscriber: SubscriberIdentifer, from messageId: MessageType) {
        guard var subscribers = subscriptions[messageId.rawValue] else { return }
        // 2. 记录原始数量用于调试
          let originalCount = subscribers.count
          
          // 3. 使用 indices 从后向前遍历，避免索引问题
          subscribers.removeAll { existingSubscriber, _ in
              existingSubscriber.id == subscriber.id && existingSubscriber.type == subscriber.type
          }
          
          // 4. 更新订阅列表
          if subscribers.isEmpty {
              subscriptions.removeValue(forKey: messageId.rawValue)
              logger.log("取消订阅: \(subscriber.id) -> \(messageId.rawValue)，已删除该消息类型的所有订阅")
          } else {
              subscriptions[messageId.rawValue] = subscribers
              logger.log("取消订阅: \(subscriber.id) -> \(messageId.rawValue)，剩余订阅者: \(subscribers.count)/\(originalCount)")
          }
    }
    
    /// 取消订阅所有消息
    public func unsubscribeAll(_ subscriber: SubscriberIdentifer) {
        for (messageId, _) in subscriptions {
            unsubscribe(subscriber, from: MessageType(rawValue: messageId)!)
        }
    }
    
    ///移除所有订阅者
    public func removeAllSubscribers() {
        subscriptions.removeAll()
    }
    
    /// 发布消息
    /// 发布给所有订阅者
    /// - Parameter messageId: 消息Id
    /// - sender: 发送者标识
    /// - payload: 消息负载
    public func send(_ messageId: MessageType,
              sender: AnyHashable? = nil,
              payload: Any? = nil) {
        let message = Message(id: messageId.rawValue, sender: sender, timestamp: Date(), payload: payload)
        saveToHistory(message)
        guard let subscribers = subscriptions[messageId.rawValue] else {
            logger.log("发送消息但是没有订阅者\(messageId.rawValue)")
            return
        }
        logger.log("发送消息：\(messageId.rawValue) 订阅者数量: \(subscribers.count)")
        for (subscriber, handler) in subscribers {
            logger.log("    -> 通知： \(subscriber.id)")
            handler(message)
        }
    }

    /// 发送消息给特定类型的订阅者
    public func send(_ messageId: MessageType, to subscribeType: String, sender: AnyHashable? = nil,  payload: Any? = nil) {
        let message = Message(id: messageId.rawValue, sender: sender, timestamp: Date(), payload: payload)
        // 保存消息到历史记录
        saveToHistory(message)
        guard let subscribers = subscriptions[messageId.rawValue] else { return }
        
        let filteredSubscribers = subscribers.filter { $0.0.type == subscribeType }
        
        for (subscriber , handler) in filteredSubscribers {
            logger.log("发送消息: \(messageId.rawValue) 给订阅者: \(subscriber.id) [\(subscriber.type)]")
            handler(message)
        }
    }
    /// 发消息给除发送者外的所有订阅者
    public func sendToOthers(_ messageId: MessageType, sender: AnyHashable, payload: Any? = nil) {
        let message = Message(id: messageId.rawValue, sender: sender, timestamp: Date(), payload: payload)
        
        saveToHistory(message)
        
        guard let subscribers = subscriptions[messageId.rawValue] else { return }
        
        let senderIdString = "\(sender.hashValue)"
        
        let filteredSubscribers = subscribers.filter{ "\($0.0.id)" != senderIdString }
        
        for (subscriber, handler) in filteredSubscribers {
            logger.log("排除发送者：\(messageId) -> \(subscriber.id)")
            handler(message)
        }
    }
    /// 获取历史消息
    public func getHistory(for messageId: MessageType? = nil, limit: Int = 100) -> [Message] {
        var filteredHistory: [Message]
        
        if let messageId {
            filteredHistory = messageHistory.filter { $0.id == messageId.rawValue }
        } else {
            filteredHistory = messageHistory
        }
        return Array(filteredHistory.suffix(limit))
    }
    /// 清空历史记录
    public func clearHistory() {
        messageHistory.removeAll()
    }
    /// 查询和统计
    /// 获取所有消息类型
    public func getAllMessageTypes() -> [String] {
        return Array(subscriptions.keys)
    }
    /// 获取特定消息的订阅者数量
    public func getSubscriberCount(for messageId: MessageType) -> Int {
        return subscriptions[messageId.rawValue]?.count ?? 0
    }
    
    /// 获取所有订阅者
    public func getAllSubscribers() -> [String: [SubscriberIdentifer]] {
        var result: [String: [SubscriberIdentifer]] = [:]
        for (messageId, subscribers) in subscriptions {
            result[messageId] = subscribers.map { $0.0 }
        }
        return result
    }
    /// 打印当前状态
    public func printStatus() {
        logger.log("消息总线状态：")
        logger.log("消息总线类型： \(subscriptions.count)")
        
        for (messageId, subscribers) in subscriptions {
            logger.log(" -> \(messageId): \(subscribers.count) 个订阅者")
            
            for (subscriber, _) in subscribers {
                logger.log(".    \(subscriber.id) [\(subscriber.type)]")
            }
        }
        
        logger.log(" 历史消息数量：\(messageHistory.count)")
    }
    
    public func saveToHistory(_ message: Message) {
        messageHistory.append(message)
        if messageHistory.count > maxHistoryCount {
            messageHistory.removeFirst(messageHistory.count - maxHistoryCount)
        }
    }
    
}

extension MessageBus {
    /// 为ViewModel 创建的便捷订阅方法
    public static func subscribe<T: AnyObject>(_ subscriber: T, to messageId: MessageType, handler: @escaping(T, Message) -> Void) {
        let uuid = UUID()
        let identifier = SubscriberIdentifer(id: uuid, type: String(describing: T.self))
        
        shared.subscribe(identifier, to: messageId) { [weak subscriber] message in
            guard let subscriber = subscriber else {return}
            handler(subscriber, message)
        }
    }
    
    /// 便捷发送消息
    public static func send(_ messageId: MessageType, sender: AnyObject? = nil, payload: Any? = nil) {
        let senderHasshable: AnyHashable? = sender.map { ObjectIdentifier($0) }
        shared.send(messageId, sender: senderHasshable, payload: payload)
    }
}


