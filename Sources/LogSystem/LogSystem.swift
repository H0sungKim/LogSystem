//
//  LogSystem.swift
//  LogSystem
//
//  Created by Hosung.Kim on 2026.06.17 16:27.
//

@_exported import ConsoleLogger

@attached(member, names: arbitrary)
public macro LogSystem() = #externalMacro(module: "LogSystemMacro", type: "LogSystemMacro")
