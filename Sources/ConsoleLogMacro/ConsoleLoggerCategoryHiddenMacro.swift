//
//  ConsoleLoggerCategoryHiddenMacro.swift
//  ConsoleLog
//
//  Created by Hosung.Kim on 2026.06.17 16:29.
//

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct ConsoleLoggerCategoryHiddenMacro: PeerMacro {
    
    public static func expansion(
        of node: SwiftSyntax.AttributeSyntax,
        providingPeersOf declaration: some SwiftSyntax.DeclSyntaxProtocol,
        in context: some SwiftSyntaxMacros.MacroExpansionContext
    ) throws -> [SwiftSyntax.DeclSyntax] {
        
        guard let caseDecl = declaration.as(EnumCaseDeclSyntax.self) else {
            throw ConsoleLogMacroError("@hidden can only be applied to an enum case")
        }
        
        let isValidParent = context.lexicalContext.first?.as(EnumDeclSyntax.self)?.attributes.contains { attribute in
            attribute.as(AttributeSyntax.self)?
                .attributeName.as(IdentifierTypeSyntax.self)?
                .name.text == "ConsoleLoggerCategory"
        } ?? false
        
        guard isValidParent else {
            throw ConsoleLogMacroError("@hidden can only be applied to a case within an enum annotated with @ConsoleLoggerCategory")
        }
        
        return []
    }
}
