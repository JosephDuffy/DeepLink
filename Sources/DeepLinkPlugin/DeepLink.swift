import Foundation
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

public struct DeepLink: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        let labeledArguments = node.arguments?.as(LabeledExprListSyntax.self)

        let addTrailingSlash = labeledArguments?
            .first(where: { $0.label?.trimmed.text == "trailingSlash" })?
            .expression
            .as(BooleanLiteralExprSyntax.self)?
            .literal
            .trimmed
            .text == "true"

        var hostVariables: [TokenSyntax] = []
        var pathItemVariables: [TokenSyntax] = []
        var queryItemVariables: [QueryItemVariable] = []

        for member in declaration.memberBlock.members {
            // is a property
            guard let variable = member.decl.as(VariableDeclSyntax.self) else {
                continue
            }

            lazy var boundPropertyIdentifiers = variable.bindings.compactMap({ binding in
                binding
                    .pattern
                    .as(IdentifierPatternSyntax.self)?
                    .identifier
            })

            for attribute in variable.attributes {
                guard let attribute = attribute.as(AttributeSyntax.self) else { continue }
                guard let attributeName = attribute.attributeName.as(IdentifierTypeSyntax.self)?.name.text else { continue }

                if attributeName == "PathItem" {
                    pathItemVariables.append(contentsOf: boundPropertyIdentifiers)
                } else if attributeName == "Host" {
                    hostVariables.append(contentsOf: boundPropertyIdentifiers)
                } else if attributeName == "QueryItem" {
                    var queryItemName: String?
                    var includeWhenNil = false

                    for argument in attribute.arguments?.as(LabeledExprListSyntax.self) ?? [] {
                        let trimmmedArgumentLabel = argument.label?.trimmed.text
                        if trimmmedArgumentLabel == "name" {
                            guard let expression = argument.expression.as(StringLiteralExprSyntax.self) else { continue }
                            switch expression.segments.first?.as(StringSegmentSyntax.self)?.content.tokenKind {
                            case .stringSegment(let text):
                                queryItemName = text
                            default:
                                break
                            }
                        } else if trimmmedArgumentLabel == "includeWhenNil" {
                            guard let expression = argument.expression.as(BooleanLiteralExprSyntax.self) else { continue }
                            switch expression.literal.tokenKind {
                            case .keyword(.true):
                                includeWhenNil = true
                            default:
                                break
                            }
                        }
                    }

                    let isOptional = variable.bindings.contains { binding in
                        guard let typeAnnotation = binding.typeAnnotation else { return false }
                        if typeAnnotation.type.is(OptionalTypeSyntax.self) {
                            return true
                        } else if let identifierType = typeAnnotation.type.as(IdentifierTypeSyntax.self) {
                            return identifierType.name.trimmed.text == "Optional"
                        }

                        return false
                    }

                    let variables = boundPropertyIdentifiers.map { identifier in
                        QueryItemVariable(
                            token: identifier,
                            isOptional: isOptional,
                            queryItemName: queryItemName,
                            includeWhenNil: includeWhenNil
                        )
                    }

                    queryItemVariables.append(contentsOf: variables)
                }
            }
        }

        var urlComponentsBuilder = """
        var components = URLComponents()
        components.scheme = Self.scheme
        """

        if let hostVariable = hostVariables.first {
            guard hostVariables.count == 1 else {
                fatalError()
            }

            urlComponentsBuilder += "\n"
            urlComponentsBuilder += #"components.host = "\(self.\#(hostVariable.trimmed))""#
        }

        var pathString = ""

        for pathItem in pathItemVariables {
            pathString += #"/\(self.\#(pathItem.trimmed))"#
        }

        if !pathString.isEmpty {
            if addTrailingSlash {
                pathString += "/"
            }

            urlComponentsBuilder += "\n"
            urlComponentsBuilder += #"components.path = "\#(pathString)""#
        }

        if !queryItemVariables.isEmpty {
            var requiredQueryItems: [String] = []
            var optionalQueryItems: [String] = []

            for queryItemVariable in queryItemVariables {
                let queryItemName = queryItemVariable.queryItemName ?? queryItemVariable.token.trimmed.text
                let variableName = queryItemVariable.token.trimmed

                if queryItemVariable.isOptional, !queryItemVariable.includeWhenNil {
                    optionalQueryItems.append("""
                    if let \(variableName) = self.\(variableName) {
                        queryItems.append(URLQueryItem(name: "\(queryItemName)", value: \(variableName)))
                    }
                    """)
                } else if queryItemVariable.isOptional {
                    requiredQueryItems.append(
                        #"URLQueryItem(name: "\#(queryItemName)", value: self.\#(variableName).map { "\($0)" })"#
                    )
                } else {
                    requiredQueryItems.append(
                        #"URLQueryItem(name: "\#(queryItemName)", value: self.\#(variableName))"#
                    )
                }
            }

            var queryItemsBuilder: String

            if optionalQueryItems.isEmpty {
                queryItemsBuilder = "let queryItems: [URLQueryItem] = ["
            } else {
                queryItemsBuilder = "var queryItems: [URLQueryItem] = ["
            }

            if !requiredQueryItems.isEmpty {
                queryItemsBuilder += "\n"
                queryItemsBuilder += requiredQueryItems.joined(separator: ",\n")
            }

            queryItemsBuilder += "]"

            if !optionalQueryItems.isEmpty {
                queryItemsBuilder += "\n"
                queryItemsBuilder += optionalQueryItems.joined(separator: "\n")
            }

            urlComponentsBuilder += "\n"
            urlComponentsBuilder += queryItemsBuilder
            urlComponentsBuilder += "\n"
            urlComponentsBuilder += "components.queryItems = queryItems"
        }

        urlComponentsBuilder += "\n"
        urlComponentsBuilder += "return components.url!"
        
        return [
            #"""
            public var url: URL {
                \#(raw: urlComponentsBuilder)
            }
            """#,
        ]
    }
}

private struct QueryItemVariable {
    let token: TokenSyntax

    let isOptional: Bool

    let queryItemName: String?

    let includeWhenNil: Bool
}
