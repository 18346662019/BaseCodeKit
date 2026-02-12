//
//  File.swift
//  BaseKit
//
//  Created by apple on 2026/2/11.
//

import Foundation
import Combine

public class BaseAppModel: ObservableObject {
    let messageBus = MessageBus.shared
    let fileManager = FileManagerFactory()
    let appContainer = AppContainer.shared.container
    let netWork = NetworkManager.shared
    let logger = Logger(category: "App")
}


