//
//  ConsoleLog.swift
//  ConsoleLog
//
//  Created by Hosung.Kim on 2026.06.17 16:27.
//

@_exported import ConsoleLogger

@attached(peer, names: arbitrary)
public macro ConsoleLoggerCategory() = #externalMacro(module: "ConsoleLogMacro", type: "ConsoleLoggerCategoryMacro")

@attached(peer)
public macro hidden() = #externalMacro(module: "ConsoleLogMacro", type: "ConsoleLoggerCategoryHiddenMacro")
