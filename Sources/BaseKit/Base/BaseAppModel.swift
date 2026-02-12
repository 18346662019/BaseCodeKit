//
//  File.swift
//  BaseKit
//
//  Created by apple on 2026/2/11.
//

import Foundation
import Combine
import Swinject

public class BaseAppModel: ObservableObject {
    public let messageBus = MessageBus.shared
    public let fileManager = FileManagerFactory()
    public let appContainer = AppContainer.shared.container
    public let netWork = NetworkManager.shared
    public let logger = Logger(category: "App")
    
    public init() {
        
    }
}


