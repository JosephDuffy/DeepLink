import SwiftSyntax
import SwiftSyntaxMacros

public struct PathItem: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        // Only used to decorate members
        return []
    }
}
