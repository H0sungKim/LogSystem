//
//  ConsoleLogger.swift
//  LogSystem
//
//  Created by 김호성 on 2025.06.28.
//

import Foundation
import os

/// A lightweight logging utility that supports multiple output methods.
///
/// Each log message includes debugging information such as:
/// - Timestamp
/// - Log level
/// - Category
/// - Thread identifier
/// - Source file and line number
/// - Function name
///
/// ### Example output
/// ```text
/// 2026-06-11T06:21:15.782Z [DEBUG] [LifeCycle] [MainThread] [SplashViewController.swift:21] [init(viewModel:)]
/// SplashViewController init
/// ```
public struct ConsoleLogger: Sendable {
    private let logger: Logger
    private let category: String
    
    public init(subsystem: String, category: String) {
        self.category = category
        logger = Logger(subsystem: subsystem, category: category)
    }
}

// MARK: - Public API
extension ConsoleLogger {
    
    /// Logs a debug message.
    /// - Note: These logs are only compiled and executed in DEBUG builds.
    public func d(_ objects: Any?..., separator: String = " ", method: OutputMethod = .oslog, fileName: String = #fileID, line: Int = #line, funcName: String = #function) {
        #if DEBUG
        log(objects, separator: separator, level: .debug, method: method, fileName: fileName, line: line, funcName: funcName)
        #endif
    }
    
    /// Logs an info message.
    public func i(_ objects: Any?..., separator: String = " ", method: OutputMethod = .oslog, fileName: String = #fileID, line: Int = #line, funcName: String = #function) {
        log(objects, separator: separator, level: .info, method: method, fileName: fileName, line: line, funcName: funcName)
    }
    
    /// Logs a notice message.
    public func n(_ objects: Any?..., separator: String = " ", method: OutputMethod = .oslog, fileName: String = #fileID, line: Int = #line, funcName: String = #function) {
        log(objects, separator: separator, level: .notice, method: method, fileName: fileName, line: line, funcName: funcName)
    }
    
    /// Logs an error message.
    public func e(_ objects: Any?..., separator: String = " ", method: OutputMethod = .oslog, fileName: String = #fileID, line: Int = #line, funcName: String = #function) {
        log(objects, separator: separator, level: .error, method: method, fileName: fileName, line: line, funcName: funcName)
    }
    
    /// Logs a fault message.
    public func f(_ objects: Any?..., separator: String = " ", method: OutputMethod = .oslog, fileName: String = #fileID, line: Int = #line, funcName: String = #function) {
        log(objects, separator: separator, level: .fault, method: method, fileName: fileName, line: line, funcName: funcName)
    }
}

// MARK: - Level
extension ConsoleLogger {
    public enum Level: String, CustomStringConvertible, Sendable {
        case debug  = "DEBUG"
        case info   = "INFO"
        case notice = "NOTICE"
        case error  = "ERROR"
        case fault  = "FAULT"
        
        internal var osLogType: OSLogType {
            switch self {
            case .debug:
                return .debug
            case .info:
                return .info
            case .notice:
                return .`default`
            case .error:
                return .error
            case .fault:
                return .fault
            }
        }
        
        public var description: String {
            return self.rawValue
        }
    }
}

// MARK: - ThreadType
extension ConsoleLogger {
    public enum ThreadType: CustomStringConvertible, Sendable {
        case main
        case background(threadNumber: Int?)
        
        package init?(description: String) {
            switch description {
            case "MainThread":
                self = .main
                return
                
            case "BackgroundThread":
                self = .background(threadNumber: nil)
                return
                
            default:
                let threadNumberRegex = /^Thread(?<threadNumber>\d+)$/
                if let match = description.firstMatch(of: threadNumberRegex),
                   let threadNumber = Int(match.output.threadNumber) {
                    self = .background(threadNumber: threadNumber)
                    return
                }
            }
            
            return nil
        }
        
        internal static var current: Self {
            let currentThread = Thread.current
            if currentThread.isMainThread {
                return .main
            }
            // <NSThread: 0x600001709040>{number = 6, name = (null)}
            let threadNumberRegex = /number\s*=\s*(?<threadNumber>\d+)/
            if let match = currentThread.description.firstMatch(of: threadNumberRegex) {
                let threadNumber = Int(match.output.threadNumber)
                return .background(threadNumber: threadNumber)
            }
            return .background(threadNumber: nil)
        }
        
        public var description: String {
            switch self {
            case .main:
                return "MainThread"
            case let .background(threadNumber):
                if let threadNumber {
                    return "Thread\(threadNumber)"
                } else {
                    return "BackgroundThread"
                }
            }
        }
    }
}

// MARK: - OutputMethod
extension ConsoleLogger {
    public enum OutputMethod {
        case oslog
        case nslog
        case print
    }
}

// MARK: - Logging
extension ConsoleLogger {
    private func log(_ objects: [Any?], separator: String, level: Level, method: OutputMethod, fileName: String, line: Int, funcName: String) {
        let content: String = objects.map({ "\($0 ?? "nil")" }).joined(separator: separator)
        
        let entry = Entry(
            timestamp: Date(),
            level: level,
            category: category,
            thread: ThreadType.current,
            fileName: fileName.lastFilePathComponent,
            line: line,
            funcName: funcName,
            content: content
        )
        
        switch method {
        case .oslog:
            logger.log(level: level.osLogType, "\(entry)")
        case .nslog:
            NSLog(entry.description)
        case .print:
            print(entry)
        }
    }
}

// MARK: - Entry
extension ConsoleLogger {
    
    /// A single log entry used to build a formatted log message.
    ///
    /// Example:
    /// 2026-06-11T06:21:15.782Z [DEBUG] [Main] [BaseViewController.swift:21] [init(viewControllerFactory:)]
    /// SplashViewController init
    public struct Entry: Sendable, CustomStringConvertible {
        let timestamp: Date
        let level: Level
        let category: String
        let thread: ThreadType
        let fileName: String
        let line: Int
        let funcName: String
        let content: String
        
        package init(timestamp: Date, level: Level, category: String, thread: ThreadType, fileName: String, line: Int, funcName: String, content: String) {
            self.timestamp = timestamp
            self.level = level
            self.category = category
            self.thread = thread
            self.fileName = fileName
            self.line = line
            self.funcName = funcName
            self.content = content
        }
        
        public var description: String {
            """
            \(timestamp.formatted(Self.dateFormatStyle)) [\(level)] [\(category)] [\(thread)] [\(fileName):\(line)] [\(funcName)]
            \(content)
            """
        }
        
        private static let dateFormatStyle: Date.ISO8601FormatStyle = .iso8601
            .year()
            .month()
            .day()
            .dateSeparator(.dash)
            .timeZone(separator: .colon)
            .time(includingFractionalSeconds: true)
            .timeSeparator(.colon)
    }
}

// MARK: - Utility
extension String {
    fileprivate var lastFilePathComponent: String {
        return URL(filePath: self).lastPathComponent
//        return (self as NSString).lastPathComponent
    }
}
