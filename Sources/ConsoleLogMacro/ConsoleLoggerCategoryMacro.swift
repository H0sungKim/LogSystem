//
//  ConsoleLoggerCategoryMacro.swift
//  ConsoleLog
//
//  Created by Hosung.Kim on 2026.06.18 18:46.
//

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct ConsoleLoggerCategoryMacro: PeerMacro {
    
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let targetEnum = declaration.as(EnumDeclSyntax.self) else {
            throw ConsoleLogMacroError("@ConsoleLoggerCategory can only be applied to an enum")
        }
        
        let isStringRawValue = targetEnum.inheritanceClause?.inheritedTypes.contains {
            $0.type.as(IdentifierTypeSyntax.self)?.name.text == "String"
        } ?? false
        guard isStringRawValue else {
            throw ConsoleLogMacroError("enum '\(targetEnum.name.text)' must store 'String' raw values")
        }
        
        var generatedCodes: [DeclSyntax] = []
        var isDefaultExplicitlyDeclared = false
        
        for member in targetEnum.memberBlock.members {
            guard let caseDecl = member.decl.as(EnumCaseDeclSyntax.self) else { continue }
            
            let isHidden = caseDecl.attributes.contains { attribute in
                attribute.as(AttributeSyntax.self)?
                    .attributeName.as(IdentifierTypeSyntax.self)?
                    .name.text == "hidden"
            }
            
            for element in caseDecl.elements {
                let caseName = element.name.text
                if caseName == "`default`" {
                    isDefaultExplicitlyDeclared = true
                }
                let accessLevelModifier = isHidden ? "private" : "public"
                generatedCodes.append("\(raw: accessLevelModifier) static let \(raw: caseName) = ConsoleLogger(category: \(raw: targetEnum.name.text).\(raw: caseName).rawValue)")
            }
        }
        if !isDefaultExplicitlyDeclared {
            generatedCodes.append("private static let `default` = ConsoleLogger(category: \"Default\")")
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
