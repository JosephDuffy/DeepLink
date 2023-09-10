import Foundation
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

public struct StaticDeepLink: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let string = node.arguments?.as(LabeledExprListSyntax.self)?.first?.expression.as(StringLiteralExprSyntax.self)?.representedLiteralValue else {
            fatalError()
        }

        return [
            #"""
            public var url: URL {
                URL(string: "\(Self.scheme)://\#(raw: string)")!
            }
            """#,
        ]
    }
}
