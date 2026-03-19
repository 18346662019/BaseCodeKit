//
//  File.swift
//  BaseKit
//
//  Created by apple on 2026/2/11.
//

import Foundation
import Swinject

extension AppContainer{
    public func resolve<T>(_ type: T.Type) -> T {
        guard let service = container.resolve(type) else {
            fatalError("Dependency of type \(type) has not been registered.")
        }
        return service
    }
}

public final class AppContainer: @unchecked Sendable {
    public static let shared = AppContainer()
    public var container: Container
    
    public static func resolve<T>(_ type: T.Type) -> T {
        return AppContainer.shared.resolve(type)
    }
    
    public init() {
        container = Container()
    }
    
    // 对外可调用的 register 接口
    public func register<Service>(_ serviceType: Service.Type,
                                  name: String? = nil,
                                  factory: @escaping (any Resolver) -> Service) {
        container.register(serviceType, name: name) { resolver in
            return factory(resolver)
        }
    }
    
    // 简单的 resolve 辅助
    public func resolve<Service>(_ serviceType: Service.Type, name: String? = nil) -> Service? {
        return container.resolve(serviceType, name: name)
    }
    
}
