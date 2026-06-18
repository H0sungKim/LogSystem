//
//  LogStore.swift
//  SwiftDataaa
//
//  Created by Hosung.Kim on 2026.06.17 10:42.
//

import Foundation
import OSLog

import ConsoleLogger

public struct LogStore {
    
    private let subsystem: String
    
    private let logStore: OSLogStore
    private let logEntryDecoder: LogEntryDecoder
    
    //        let position = logStore.position(date: Date().addingTimeInterval(-600))
    
    public init(subsystem: String) throws {
        self.subsystem = subsystem
        self.logStore = try OSLogStore(scope: .currentProcessIdentifier)
        self.logEntryDecoder = LogEntryDecoder()
    }
    
    public func getLogEntries() throws {
        let entries = try logStore.getEntries(matching: NSPredicate(format: "subsystem == %@", subsystem))
        for entry in entries {
            print("=============")
            print(entry.date)
            print(entry.composedMessage)
        }
    }
}
