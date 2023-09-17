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
        let labeledArguments = node.arguments?.as(LabeledExprListSyntax.self) ?? []

        var addTrailingSlash = false
        var scheme: String?

        for argument in labeledArguments {
            switch argument.label?.trimmed.text {
            case "trailingSlash":
                guard let expression = argument.expression.as(BooleanLiteralExprSyntax.self) else { continue }
                switch expression.literal.tokenKind {
                case .keyword(.true):
                    addTrailingSlash = true
                case .keyword(.false):
                    addTrailingSlash = false
                default:
                    break
                }
            case "scheme":
                guard let expression = argument.expression.as(StringLiteralExprSyntax.self) else { continue }
                switch expression.segments.first?.as(StringSegmentSyntax.self)?.content.tokenKind {
                case .stringSegment(let text):
                    scheme = text
                default:
                    break
                }
            default:
                break
            }
        }

        var userVariables: [(token: TokenSyntax, isOptional: Bool)] = []
        var hostVariables: [(token: TokenSyntax, isOptional: Bool)] = []
        var pathItemVariables: [(token: TokenSyntax, isOptional: Bool)] = []
        var haveOptionalPathItem = false
        var queryItemVariables: [QueryItemVariable] = []
        var queryItemsVariables: [TokenSyntax] = []

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

                lazy var isOptional = variable.bindings.contains { binding in
                    guard let typeAnnotation = binding.typeAnnotation else { return false }
                    if typeAnnotation.type.is(OptionalTypeSyntax.self) {
                        return true
                    } else if let identifierType = typeAnnotation.type.as(IdentifierTypeSyntax.self) {
                        return identifierType.name.trimmed.text == "Optional"
                    }

                    return false
                }

                if attributeName == "PathItem" {
                    if isOptional {
                        haveOptionalPathItem = true
                    }
                    pathItemVariables.append(
                        contentsOf: boundPropertyIdentifiers.map { identifier in
                            (token: identifier, isOptional: isOptional)
                        }
                    )
                } else if attributeName == "User" {
                    userVariables.append(
                        contentsOf: boundPropertyIdentifiers.map { identifier in
                            (token: identifier, isOptional: isOptional)
                        }
                    )
                } else if attributeName == "Host" {
                    hostVariables.append(
                        contentsOf: boundPropertyIdentifiers.map { identifier in
                            (token: identifier, isOptional: isOptional)
                        }
                    )
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

                    let variables = boundPropertyIdentifiers.map { identifier in
                        QueryItemVariable(
                            token: identifier,
                            isOptional: isOptional,
                            queryItemName: queryItemName,
                            includeWhenNil: includeWhenNil
                        )
                    }

                    queryItemVariables.append(contentsOf: variables)
                } else if attributeName == "QueryItems" {
                    queryItemsVariables.append(contentsOf: boundPropertyIdentifiers)
                }
            }
        }

        var urlComponentsBuilder = """
        var components = URLComponents()
        components.scheme = Self.scheme
        """

        if let userVariable = userVariables.first {
            guard userVariables.count == 1 else {
                fatalError()
            }

            urlComponentsBuilder += "\n"

            if userVariable.isOptional {
                urlComponentsBuilder += #"""
                if let \#(userVariable.token.trimmed) = self.\#(userVariable.token.trimmed) {
                    components.user = "\(\#(userVariable.token.trimmed))"
                }
                """#
            } else {
                urlComponentsBuilder += #"components.user = "\(self.\#(userVariable.token.trimmed))""#
            }
        }

        if let hostVariable = hostVariables.first {
            guard hostVariables.count == 1 else {
                fatalError()
            }

            urlComponentsBuilder += "\n"

            if hostVariable.isOptional {
                urlComponentsBuilder += #"""
                if let \#(hostVariable.token.trimmed) = self.\#(hostVariable.token.trimmed) {
                    components.host = "\(\#(hostVariable.token.trimmed))"
                }
                """#
            } else {
                urlComponentsBuilder += #"components.host = "\(self.\#(hostVariable.token.trimmed))""#
            }
        }

        if !pathItemVariables.isEmpty {
            if haveOptionalPathItem {
                urlComponentsBuilder += "\n"
                urlComponentsBuilder += #"var pathComponents: [String] = []"#

                for pathItem in pathItemVariables {
                    urlComponentsBuilder += "\n"

                    if pathItem.isOptional {
                        urlComponentsBuilder += #"""
                        if let \#(pathItem.token.trimmed) = self.\#(pathItem.token.trimmed) {
                            pathComponents.append("\(\#(pathItem.token.trimmed))")
                        }
                        """#
                    } else {
                        urlComponentsBuilder += #"pathComponents.append("\(self.\#(pathItem.token.trimmed))")"#
                    }
                }

                urlComponentsBuilder += "\n"
                urlComponentsBuilder += """
                if !pathComponents.isEmpty {
                    var path = ""
                    if components.host != nil {
                        path = "/"
                    }
                    path += pathComponents.joined(separator: "/")
                    components.path = path
                }
                """
            } else {
                urlComponentsBuilder += "\n"
                urlComponentsBuilder += #"var path = """#

                urlComponentsBuilder += "\n"
                urlComponentsBuilder += #"""
                if components.host != nil {
                    path = "/"
                }
                """#

                urlComponentsBuilder += "\n"
                urlComponentsBuilder += "path += ["

                for pathItem in pathItemVariables {
                    urlComponentsBuilder += "\n"
                    urlComponentsBuilder += #"    "\(self.\#(pathItem.token.trimmed))","#
                }
                urlComponentsBuilder += "\n"
                urlComponentsBuilder += #"].joined(separator: "/")"#

                urlComponentsBuilder += "\n"
                urlComponentsBuilder += "components.path = path"
            }

            if addTrailingSlash {
                urlComponentsBuilder += "\n"
                urlComponentsBuilder += #"""
                if !components.path.isEmpty {
                    components.path += "/"
                }
                """#

            }
        }

        if !queryItemVariables.isEmpty || !queryItemsVariables.isEmpty {
            var requiredQueryItems: [String] = []
            var optionalQueryItems: [String] = []

            for queryItemVariable in queryItemVariables {
                let queryItemName = queryItemVariable.queryItemName ?? queryItemVariable.token.trimmed.text
                let variableName = queryItemVariable.token.trimmed

                if queryItemVariable.isOptional, !queryItemVariable.includeWhenNil {
                    optionalQueryItems.append(#"""
                    if let \#(variableName) = self.\#(variableName) {
                        queryItems.append(URLQueryItem(name: "\#(queryItemName)", value: "\(\#(variableName))"))
                    }
                    """#)
                } else if queryItemVariable.isOptional {
                    requiredQueryItems.append(
                        #"URLQueryItem(name: "\#(queryItemName)", value: self.\#(variableName).map { "\($0)" })"#
                    )
                } else {
                    requiredQueryItems.append(
                        #"URLQueryItem(name: "\#(queryItemName)", value: "\(self.\#(variableName))")"#
                    )
                }
            }

            var queryItemsBuilder: String

            if optionalQueryItems.isEmpty && queryItemsVariables.isEmpty {
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

            for queryItemsVariable in queryItemsVariables {
                queryItemsBuilder += "\n"
                queryItemsBuilder += "queryItems += self.\(queryItemsVariable.trimmed)"
            }

            urlComponentsBuilder += "\n"
            urlComponentsBuilder += queryItemsBuilder
            urlComponentsBuilder += "\n"
            urlComponentsBuilder += """
            if !queryItems.isEmpty {
                components.queryItems = queryItems
            }
            """
        }

        urlComponentsBuilder += "\n"
        urlComponentsBuilder += "return components.url!"
        
        var declarations: [DeclSyntax] = [
            #"""
            public var url: URL {
                \#(raw: urlComponentsBuilder)
            }
            """#,
        ]

        if let scheme {
            declarations.append(#"public static let scheme = "\#(raw: scheme)""#)
        }

        return declarations
    }
}

private struct QueryItemVariable {
    let token: TokenSyntax

    let isOptional: Bool

    let queryItemName: String?

    let includeWhenNil: Bool
}
