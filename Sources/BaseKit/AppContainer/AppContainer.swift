//
//  File.swift
//  BaseKit
//
//  Created by apple on 2026/2/11.
//

import Foundation
import Swinject

extension AppContainer{
    func resolve<T>(_ type: T.Type) -> T {
        guard let service = container.resolve(type) else {
            fatalError("Dependency of type \(type) has not been registered.")
        }
        return service
    }
}

class AppContainer : @unchecked Sendable {
    static let shared = AppContainer()
    var container: Container
    
    static func resolve<T>(_ type: T.Type) -> T {
        return AppContainer.shared.resolve(type)
    }
    
    private init() {
        container = Container()
        registerDependencies()
    }
    
    func registerDependencies() {
        
    }
}
