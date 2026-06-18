//
//  ConsoleLogMacrosPlugin.swift
//  ConsoleLog
//
//  Created by Hosung.Kim on 2026.06.18 18:44.
//

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

@main
struct ConsoleLogMacrosPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        ConsoleLoggerCategoryMacro.self,
        ConsoleLoggerCategoryHiddenMacro.self
    ]
}
