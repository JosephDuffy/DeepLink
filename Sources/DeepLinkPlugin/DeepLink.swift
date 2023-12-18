import Foundation
@preconcurrency import SwiftDiagnostics
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
        var generateInit = false

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
            case "generateInitWithURL":
                guard let expression = argument.expression.as(BooleanLiteralExprSyntax.self) else { continue }
                switch expression.literal.tokenKind {
                case .keyword(.true):
                    generateInit = true
                case .keyword(.false):
                    generateInit = false
                default:
                    break
                }
            default:
                break
            }
        }

        var userVariables: [Property] = []
        var hostVariables: [Property] = []
        var portVariables: [Property] = []
        var pathItemVariables: [Property] = []
        var haveOptionalPathItem = false
        var queryItemVariables: [QueryItemVariable] = []
        var queryItemsVariables: [Property] = []

        for member in declaration.memberBlock.members {
            // is a property
            guard let variable = member.decl.as(VariableDeclSyntax.self) else {
                continue
            }

            lazy var boundPropertyIdentifiers = variable.bindings.compactMap({ binding in
                binding
                    .pattern
                    .as(IdentifierPatternSyntax.self)
            })

            lazy var declaredProperties = variable.bindings.compactMap({ binding -> Property? in
                // This cast should never actually fail, unless I don't
                // understand this as well as I do (which is probably the case).
                // In theory this would only fail for tuples, e.g.
                // `var (prop1, prop2) = (123, "abc")`.
                guard
                    let identifier = binding
                        .pattern
                        .as(IdentifierPatternSyntax.self)
                else { return nil }
                return Property(
                    variable: variable,
                    binding: binding,
                    identifier: identifier
                )
            })

            for attribute in variable.attributes {
                guard let attribute = attribute.as(AttributeSyntax.self) else { continue }
                guard let attributeName = attribute.attributeName.as(IdentifierTypeSyntax.self)?.name.text else { continue }

                if attributeName == "PathItem" {
                    if declaredProperties.contains(where: \.isOptional) {
                        haveOptionalPathItem = true
                    }
                    pathItemVariables.append(contentsOf: declaredProperties)
                } else if attributeName == "User" {
                    userVariables.append(contentsOf: declaredProperties)
                } else if attributeName == "Host" {
                    hostVariables.append(contentsOf: declaredProperties)
                } else if attributeName == "Port" {
                    portVariables.append(contentsOf: declaredProperties)

                    for property in declaredProperties {
                        if property.typeAnnotation?.type.trimmed.description != "Int" {
                            throw ErrorDiagnosticMessage(id: "unsupported-port-type", message: "@Port can only be applied to Int properties")
                        }
                    }
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

                    let variables = declaredProperties.map { property in
                        QueryItemVariable(
                            property: property,
                            explicitQueryItemName: queryItemName,
                            includeWhenNil: includeWhenNil
                        )
                    }

                    queryItemVariables.append(contentsOf: variables)
                } else if attributeName == "QueryItems" {
                    queryItemsVariables.append(contentsOf: declaredProperties)
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
                if let \#(userVariable.identifier.identifier.trimmed) = self.\#(userVariable.identifier.identifier.trimmed) {
                    components.user = "\(\#(userVariable.identifier.identifier.trimmed))"
                }
                """#
            } else {
                urlComponentsBuilder += #"components.user = "\(self.\#(userVariable.identifier.identifier.trimmed))""#
            }
        }

        if let hostVariable = hostVariables.first {
            guard hostVariables.count == 1 else {
                fatalError()
            }

            urlComponentsBuilder += "\n"

            if hostVariable.isOptional {
                urlComponentsBuilder += #"""
                if let \#(hostVariable.identifier.identifier.trimmed) = self.\#(hostVariable.identifier.identifier.trimmed) {
                    components.host = "\(\#(hostVariable.identifier.trimmed))"
                }
                """#
            } else {
                urlComponentsBuilder += #"components.host = "\(self.\#(hostVariable.identifier.identifier.trimmed))""#
            }
        }

        if let portVariable = portVariables.first {
            guard hostVariables.count == 1 else {
                fatalError()
            }

            urlComponentsBuilder += "\n"

            if let defaultValue = portVariable.defaultValue {
                urlComponentsBuilder += #"""
                if self.\#(portVariable.identifier.identifier.trimmed) != \#(defaultValue) {
                """#
            }

            if portVariable.isOptional {
                urlComponentsBuilder += #"""
                if let \#(portVariable.identifier.identifier.trimmed) = self.\#(portVariable.identifier.identifier.trimmed) {
                    if \#(portVariable.identifier.trimmed) !=
                    components.port = \#(portVariable.identifier.trimmed)
                }
                """#
            } else {
                urlComponentsBuilder += #"components.port = self.\#(portVariable.identifier.identifier.trimmed)"#
            }

            if portVariable.defaultValue != nil {
                urlComponentsBuilder += "}"
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
                        if let \#(pathItem.identifier.identifier.trimmed) = self.\#(pathItem.identifier.identifier.trimmed) {
                            pathComponents.append("\(\#(pathItem.identifier.identifier.trimmed))")
                        }
                        """#
                    } else {
                        urlComponentsBuilder += #"pathComponents.append("\(self.\#(pathItem.identifier.identifier.trimmed))")"#
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
                    urlComponentsBuilder += #"    "\(self.\#(pathItem.identifier.identifier.trimmed))","#
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
                let variableName = queryItemVariable.property.identifier.identifier.trimmed
                let queryItemName = queryItemVariable.queryItemName

                if queryItemVariable.property.isOptional, !queryItemVariable.includeWhenNil {
                    optionalQueryItems.append(#"""
                    if let \#(variableName) = self.\#(variableName) {
                        queryItems.append(URLQueryItem(name: "\#(queryItemName)", value: "\(\#(variableName))"))
                    }
                    """#)
                } else if queryItemVariable.property.isOptional {
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
                if queryItemsVariable.typeAnnotation?.type.trimmed.description == "[URLQueryItem]" {
                    queryItemsBuilder += "queryItems += self.\(queryItemsVariable.identifier.trimmed)"
                } else {
                    let uniqueName = context.makeUniqueName("queryItem")
                    queryItemsBuilder += #"""
                    for \#(uniqueName) in self.\#(queryItemsVariable.identifier) {
                        queryItems.append(
                            URLQueryItem(
                                name: "\(\#(uniqueName).key)",
                                value: \#(uniqueName).value
                            )
                        )
                    }
                    """#
                }
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

        if generateInit {
            var didGenerateValidInit = true

            var initialiser = """
            public init?(url: URL) {
                guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else { return nil }

                /// An error thrown when a type conforming to `LosslessStringConvertible` return `nil`.
                struct UnwrapFailure: Error {}

                /// Attempt to create a new instance of `Unwrapped` by initialising it with a `String`.
                ///
                /// This function will cause a compilation error if one of the properties does not
                /// conform to `LosslessStringConvertible`. If you are seeing a compiler error caused by
                /// this function disable the generation of the `init` function or add
                /// `LosslessStringConvertible` conformance to the type in the error.
                func unwrapLosslessStringConvertible<Unwrapped: LosslessStringConvertible>(_ string: String) throws -> Unwrapped {
                    guard let unwrapped = Unwrapped(string) else {
                        throw UnwrapFailure()
                    }
                    return unwrapped
                }

                func unwrapOptionalLosslessStringConvertible<Unwrapped: LosslessStringConvertible>(_ string: String) -> Unwrapped? {
                    try? unwrapLosslessStringConvertible(string)
                }
            """

            if let hostVariable = hostVariables.first {
                if hostVariable.mustBeInitialised {
                    if hostVariable.isOptional {
                        initialiser += #"""
                            self.\#(hostVariable.identifier.identifier.trimmed) = components.host.flatMap(unwrapOptionalLosslessStringConvertible(_:))
                        """#
                    } else {
                        initialiser += #"""
                            guard let host = components.host else { return nil }
                            do {
                                self.\#(hostVariable.identifier.identifier.trimmed) = try unwrapLosslessStringConvertible(host)
                            } catch {
                                return nil
                            }
                        """#
                    }
                } else {
                    if hostVariable.isOptional {
                        initialiser += #"""
                            guard self.\#(hostVariable.identifier.identifier.trimmed) == components.host.flatMap(unwrapOptionalLosslessStringConvertible(_:)) else { return nil }
                        """#
                    } else {
                        initialiser += #"""
                            guard let host = components.host else { return nil }
                            do {
                                guard try unwrapLosslessStringConvertible(host) == self.\#(hostVariable.identifier.identifier.trimmed) else { return nil }
                            } catch {
                                return nil
                            }
                        """#
                    }
                }
            } else {
                initialiser += #"""
                    guard components.host == nil || components.host == "" else { return nil }
                """#
            }

            if let portVariable = portVariables.first {
                if portVariable.mustBeInitialised {
                    if portVariable.isOptional {
                        initialiser += #"""
                            self.\#(portVariable.identifier.identifier.trimmed) = components.port
                        """#
                    } else {
                        initialiser += #"""
                            guard let port = components.port else { return nil }
                            self.port = port
                        """#
                    }
                } else {
                    if portVariable.isOptional {
                        initialiser += #"""
                            guard self.\#(portVariable.identifier.identifier.trimmed) == components.port else { return nil }
                        """#
                    } else {
                        initialiser += #"""
                            guard let port = components.port else { return nil }
                            guard port == self.\#(portVariable.identifier.identifier.trimmed) else { return nil }
                        """#
                    }
                }
            } else {
                initialiser += #"""
                    guard components.port == nil  else { return nil }
                """#
            }

            if let userVariable = userVariables.first {
                if userVariable.mustBeInitialised {
                    if userVariable.isOptional {
                        initialiser += #"""
                            self.\#(userVariable.identifier.identifier.trimmed) = components.user.flatMap(unwrapOptionalLosslessStringConvertible(_:))
                        """#
                    } else {
                        initialiser += #"""
                            guard let user = components.user else { return nil }
                            do {
                                self.\#(userVariable.identifier.identifier.trimmed) = try unwrapLosslessStringConvertible(host)
                            } catch {
                                return nil
                            }
                        """#
                    }
                } else {
                    if userVariable.isOptional {
                        initialiser += #"""
                            guard self.\#(userVariable.identifier.identifier.trimmed) == components.user.flatMap(unwrapOptionalLosslessStringConvertible(_:)) else { return nil }
                        """#
                    } else {
                        initialiser += #"""
                            guard let user = components.user else { return nil }
                            do {
                                guard try unwrapLosslessStringConvertible(host) == self.\#(userVariable.identifier.identifier.trimmed) else { return nil }
                            } catch {
                                return nil
                            }
                        """#
                    }
                }
            } else {
                initialiser += #"""
                    guard components.user == nil || components.user == "" else { return nil }
                """#
            }

            if pathItemVariables.isEmpty {
                initialiser += #"""
                    guard components.path.isEmpty else { return nil }
                """#
            } else {
                initialiser += #"""
                    var componentsPath = components.path
                    if components.host != nil, components.host != "" {
                        // Remove leading slash before splitting
                        componentsPath = String(componentsPath.dropFirst())
                    }
                """#


                if addTrailingSlash {
                    initialiser += #"""
                        guard componentsPath.last == "/" else { return nil }
                        componentsPath = String(componentsPath.dropLast())
                    """#
                }

                initialiser += #"""
                    let pathComponents = componentsPath.split(separator: "/", omittingEmptySubsequences: false)
                    guard pathComponents.count == \#(pathItemVariables.count) else { return nil }
                """#

                for (index, pathItemVariable) in pathItemVariables.enumerated() {
                    let variableName = pathItemVariable.identifier.identifier.trimmed.text + "String"
                    initialiser += #"""
                        let \#(variableName) = String(pathComponents[\#(index)])
                        guard !\#(variableName).isEmpty else { return nil }
                    """#

                    if pathItemVariable.isOptional {
                        // TODO: This could be support for the last path item variable
                        didGenerateValidInit = false

                        let error = ErrorDiagnosticMessage(id: "unsupported-path-item", message: "Optional properties cannot be decorated @PathItem when generating `init(url:)`")
                        context.addDiagnostics(from: error, node: pathItemVariable.binding)
                    }

                    if pathItemVariable.mustBeInitialised {
                        initialiser += #"""
                            do {
                                self.\#(pathItemVariable.identifier.identifier.trimmed) = try unwrapLosslessStringConvertible(\#(variableName))
                            } catch {
                                return nil
                            }
                        """#
                    } else {
                        initialiser += #"""
                            do {
                                guard try unwrapLosslessStringConvertible(\#(variableName)) == self.\#(pathItemVariable.identifier.identifier.trimmed) else { return nil }
                            } catch {
                                return nil
                            }
                        """#
                    }
                }
            }

            if queryItemVariables.isEmpty, queryItemsVariables.isEmpty {
                initialiser += #"""
                    guard components.queryItems == nil || components.queryItems == [] else { return nil }
                """#
            } else {
                initialiser += #"""
                    guard var queryItems = components.queryItems else { return nil }
                """#

                for queryItemVariable in queryItemVariables {
                    let variableName = queryItemVariable.property.identifier.identifier.trimmed.text + "String"
                    initialiser += #"""
                        guard let queryItemIndex = queryItems.firstIndex(where: { $0.name == "\#(queryItemVariable.queryItemName)" }) else { return nil }
                        guard let \#(variableName) = queryItems.remove(at: queryItemIndex).value else { return nil }
                    """#

                    if queryItemVariable.property.mustBeInitialised {
                        initialiser += #"""
                            do {
                                self.\#(queryItemVariable.property.identifier.identifier.trimmed) = try unwrapLosslessStringConvertible(\#(variableName))
                            } catch {
                                return nil
                            }
                        """#
                    } else {
                        initialiser += #"""
                            do {
                                guard try unwrapLosslessStringConvertible(\#(variableName)) == self.\#(queryItemVariable.property.identifier.identifier.trimmed) else { return nil }
                            } catch {
                                return nil
                            }
                        """#
                    }
                }

                for (index, queryItemsVariable) in queryItemsVariables.enumerated() {
                    if index == 0 {
                        if queryItemsVariable.typeAnnotation?.type.trimmed.description == "[URLQueryItem]" {
                            initialiser += #"""
                                self.\#(queryItemsVariable.identifier.identifier.trimmed.text) = queryItems
                            """#
                        } else if let type = queryItemsVariable.typeAnnotation?.type {
                            if let queryItemsDictionaryType = type.as(DictionaryTypeSyntax.self) {
                                if queryItemsDictionaryType.value.trimmed.description == "String?" {
                                    initialiser += #"""
                                        self.\#(queryItemsVariable.identifier.identifier.trimmed.text) = Dictionary<\#(queryItemsDictionaryType.key), String?>(
                                            uniqueKeysWithValues: queryItems.map { queryItem -> (\#(queryItemsDictionaryType.key), String?) in
                                                (
                                                    \#(queryItemsDictionaryType.key)(rawValue: queryItem.name),
                                                    queryItem.value
                                                )
                                            }
                                        )
                                    """#
                                } else {
                                    didGenerateValidInit = false
                                    let error = ErrorDiagnosticMessage(id: "unsupported-query-items-value-type", message: "@QueryItems macro can only be applied to a [URLQueryItem] type, or a dictionary with the String? value type, not \(queryItemsDictionaryType.value.trimmed.description).")
                                    context.addDiagnostics(from: error, node: queryItemsVariable.identifier)
                                }
                            } else {
                                didGenerateValidInit = false
                                let error = ErrorDiagnosticMessage(id: "unsupported-query-items-type", message: "@QueryItems macro can only be applied to a [URLQueryItem] type, or a dictionary.")
                                context.addDiagnostics(from: error, node: queryItemsVariable.identifier)
                            }
                        }
                    } else {
                        didGenerateValidInit = false
                        let error = ErrorDiagnosticMessage(id: "unsupported-query-items", message: "Only one @QueryItems macro is supported when generating `init(url:)`")
                        context.addDiagnostics(from: error, node: queryItemsVariable.identifier)
                    }
                }
            }

            if didGenerateValidInit {
                initialiser += "}"

                declarations.append("\(raw: initialiser)")
            }
        }

        return declarations
    }
}

private struct QueryItemVariable {
    let property: Property

    var queryItemName: String {
        explicitQueryItemName ?? property.identifier.identifier.trimmed.text
    }

    let explicitQueryItemName: String?

    let includeWhenNil: Bool
}

private struct ErrorDiagnosticMessage: DiagnosticMessage, Error {
    let message: String
    let diagnosticID: MessageID
    let severity: DiagnosticSeverity

    init(id: String, message: String) {
        self.message = message
        diagnosticID = MessageID(domain: "uk.josephduffy.DeepLink", id: id)
        severity = .error
    }
}
