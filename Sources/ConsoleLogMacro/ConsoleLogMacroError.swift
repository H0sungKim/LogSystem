//
//  ConsoleLogMacroError.swift
//  ConsoleLog
//
//  Created by Hosung.Kim on 2026.06.18 18:47.
//

internal struct ConsoleLogMacroError: Error, CustomStringConvertible {
    private let message: String
    
    internal init(_ message: String) {
        self.message = message
    }
    
    internal var description: String {
        message
    }
}
