//
//  LogEntryDecoder.swift
//  LogSystem
//
//  Created by Hosung.Kim on 2026.06.18 09:34.
//

import Foundation

import ConsoleLogger

public struct LogEntryDecoder {
    func decode(_ entryComposedMessage: String) throws -> ConsoleLogger.Entry {
        
        let logEntryRegex = /^(?<timestamp>\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}Z)\s+\[(?<level>DEBUG|INFO|NOTICE|ERROR|FAULT)\]\s+\[(?<category>[^\]]+)\]\s+\[(?<thread>MainThread|Thread\d+|BackgroundThread)\]\s+\[(?<fileName>[^:]+):(?<line>\d+)\]\s+\[(?<funcName>[^\]]+)\]\n(?<content>.*)$/
        
        guard let match = entryComposedMessage.firstMatch(of: logEntryRegex) else {
            throw DecodeError.regexMatchFailed
        }
        
        let timestamp = try Date(String(match.output.timestamp), strategy: .iso8601)
        guard let level = ConsoleLogger.Level(rawValue: String(match.output.level)) else {
            throw DecodeError.invalidLevel(String(match.output.level))
        }
        let category = String(match.output.category)
        guard let thread = ConsoleLogger.ThreadType(description: String(match.output.thread)) else {
            throw DecodeError.invalidThread(String(match.output.thread))
        }
        let fileName = String(match.output.fileName)
        guard let line = Int(match.output.line) else {
            throw DecodeError.invalidLine(String(match.output.line))
        }
        let funcName = String(match.output.funcName)
        let content = String(match.output.content)
        
        return ConsoleLogger.Entry(
            timestamp: timestamp,
            level: level,
            category: category,
            thread: thread,
            fileName: fileName,
            line: line,
            funcName: funcName,
            content: content
        )
    }
    
    enum DecodeError: LocalizedError {
        case regexMatchFailed
        case invalidLevel(String)
        case invalidThread(String)
        case invalidLine(String)
    }
}
