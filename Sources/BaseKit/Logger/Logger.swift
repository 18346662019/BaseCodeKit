//
//  File.swift
//  BaseKit
//
//  Created by apple on 2026/2/11.
//

import Foundation
import os

/// 日志级别
public enum LogLevel: String, Sendable {
    case debug = "🟢 DEBUG"
    case info = "🔵 INFO"
    case warning = "🟡 WARNING"
    case error = "🔴 ERROR"
    case fatal = "💀 FATAL"
}

/// 日志记录器
@available(iOS 14.0, *)
public struct Logger {
    
    private let subsystem: String
    private let category: String
    private let osLogger: os.Logger
    
    public init(subsystem: String = Bundle.main.bundleIdentifier ?? "BaseKit",
                category: String = "App") {
        self.subsystem = subsystem
        self.category = category
        self.osLogger = os.Logger(subsystem: subsystem, category: category)
    }
    
    /// 记录日志
    public func log(_ message: String,
                    level: LogLevel = .info,
                    file: String = #file,
                    function: String = #function,
                    line: Int = #line) {
        
        #if DEBUG
        let fileName = (file as NSString).lastPathComponent
        let logMessage = "\(level.rawValue) [\(fileName):\(line)] \(function) - \(message)"
        
        switch level {
        case .debug:
            osLogger.debug("\(logMessage)")
        case .info:
            osLogger.info("\(logMessage)")
        case .warning:
            osLogger.warning("\(logMessage)")
        case .error:
            osLogger.error("\(logMessage)")
        case .fatal:
            osLogger.critical("\(logMessage)")
        }
        #endif
    }
    
    /// 性能监控
    public func measure<T>(_ name: String, operation: () throws -> T) rethrows -> T {
        let startTime = CFAbsoluteTimeGetCurrent()
        defer {
            let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
            log("\(name) 耗时: \(String(format: "%.3f", timeElapsed))s", level: .debug)
        }
        return try operation()
    }
}
