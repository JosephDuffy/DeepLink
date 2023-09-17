import Foundation
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

public struct TypedStringURLComponent: ExtensionMacro, MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        #warning("TODO: Fix when multiple protocols are provided")
        return protocols.map { `protocol` in
            ExtensionDeclSyntax(
                extendedType: type,
                inheritanceClause: InheritanceClauseSyntax(
                    inheritedTypes: InheritedTypeListSyntax(itemsBuilder: {
                        InheritedTypeSyntax(type: `protocol`)
                    })
                ),
                memberBlock: MemberBlockSyntax(members: "")
            )
        }
    }

    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        let baseModifiers = declaration.modifiers.filter({ modifier in
            switch (modifier.name.tokenKind) {
            case .keyword(.public):
                return true
            case .keyword(.internal):
                return true
            case .keyword(.fileprivate):
                return true
            case .keyword(.private):
                // The added functions should never be private
                return false
            default:
                return false
            }
        })

        return [
            """
            \(baseModifiers)let description: String

            \(baseModifiers)init(_ description: String) {
                self.description = description
            }

            \(baseModifiers)init(stringLiteral value: String) {
                description = value
            }
            """
        ]
    }
}
