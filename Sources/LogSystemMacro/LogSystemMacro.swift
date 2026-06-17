//
//  LogSystemMacro.swift
//  LogSystem
//
//  Created by Hosung.Kim on 2026.06.17 16:29.
//

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

@main
struct LogSystemMacroPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        LogSystemMacro.self
    ]
}

public struct LogSystemMacro: MemberMacro {
    
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let parentEnum = declaration.as(EnumDeclSyntax.self) else {
            throw LogSystemMacroError("@LogSystem can only be applied to an enum")
        }
        
        let loggerTypeEnum = parentEnum.memberBlock.members
            .compactMap { $0.decl.as(EnumDeclSyntax.self) }
            .first { $0.name.text == "LoggerType" }
        
        guard let loggerType = loggerTypeEnum else {
            throw LogSystemMacroError("@LogSystem requires a nested 'LoggerType' enum")
        }
        
        let hasString = loggerType.inheritanceClause?.inheritedTypes.contains {
            $0.type.as(IdentifierTypeSyntax.self)?.name.text == "String"
        } ?? false
        
        guard hasString else {
//            Method 'a()' must be as accessible as its enclosing type because it matches a requirement in protocol 'Adf'
//            throw LogSystemMacroError("@LogSystem requires enum LoggerType")
            throw LogSystemMacroError("enum 'LoggerType' must store 'String' raw values")
        }
        
        let hasStaticSubsystem = parentEnum.memberBlock.members.contains { member in
            guard let varDecl = member.decl.as(VariableDeclSyntax.self) else { return false }
            
            let isStatic = varDecl.modifiers.contains { modifier in
                modifier.name.text == "static"
            }
            guard isStatic else { return false }
            
            return varDecl.bindings.contains { binding in
                binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text == "subsystem"
            }
        }
        
        guard hasStaticSubsystem else {
            throw LogSystemMacroError("@LogSystem requires static property 'subsystem'")
        }
        
        var generatedCodes: [DeclSyntax] = []
        
        generatedCodes.append("private static let `default` = ConsoleLogger(subsystem: subsystem, category: \"Default\")")
        
        for member in loggerType.memberBlock.members {
            guard let caseDecl = member.decl.as(EnumCaseDeclSyntax.self) else { continue }
            for element in caseDecl.elements {
                let caseName = element.name.text
                
                generatedCodes.append("public static let \(raw: caseName) = ConsoleLogger(subsystem: subsystem, category: LoggerType.\(raw: caseName).rawValue)")
            }
        }
        
        let levels = ["d", "i", "n", "e", "f"]
        for level in levels {
            generatedCodes.append("""
            public static func \(raw: level)(_ objects: Any?..., separator: String = " ", method: ConsoleLogger.OutputMethod = .oslog, fileName: String = #fileID, line: Int = #line, funcName: String = #function) {
                `default`.\(raw: level)(objects, separator: separator, method: method, fileName: fileName, line: line, funcName: funcName)
            }
            """)
        }
        
        return generatedCodes
    }
}

struct LogSystemMacroError: Error, CustomStringConvertible {
    private let message: String
    
    init(_ message: String) {
        self.message = message
    }
    
    var description: String {
        message
    }
}
