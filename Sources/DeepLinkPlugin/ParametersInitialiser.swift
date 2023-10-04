import Foundation
import SwiftSyntax
import SwiftSyntaxMacros

public struct ParametersInitialiser: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let initialiser = declaration.as(InitializerDeclSyntax.self) else {
            throw ErrorDiagnosticMessage(id: "unsupported-declaration-type", message: "@ParametersInitialiser can only be applied to type initialisers.")
        }

        let parameters = initialiser.signature.parameterClause.parameters

        guard !parameters.isEmpty else {
            throw ErrorDiagnosticMessage(id: "empty-parameters", message: "@ParametersInitialiser can only be applied to initialisers with at least 1 parameter.")
        }


        let labeledArguments = node.arguments?.as(LabeledExprListSyntax.self) ?? []

        var nameMap: [String: String] = [:]

        let nameMapArgument = labeledArguments
            .first(where: { $0.label?.trimmed.text == "nameMap" })

        if let nameMapArgument {
            if let dictionary = nameMapArgument.expression.as(DictionaryExprSyntax.self) {
                switch dictionary.content {
                case .elements(let elements):
                    for element in elements {
                        guard let keyLiteral = element.key.as(StringLiteralExprSyntax.self) else { continue }
                        if keyLiteral.segments.count != 1 {
                            fatalError()
                        }
                        let key = keyLiteral.segments.first!.as(StringSegmentSyntax.self)!.content.text

                        guard let valueLiteral = element.value.as(StringLiteralExprSyntax.self) else { continue }
                        if valueLiteral.segments.count != 1 {
                            fatalError()
                        }
                        let value = valueLiteral.segments.first!.as(StringSegmentSyntax.self)!.content.text

                        nameMap[key] = value
                    }
                case .colon:
                    break
                }
            }
        }

        var deepLinkParameters = "public static let deepLinkParameters: [DeepLinkParameter] = ["
        var makeWithParameters = #"""
        public static func makeWithParameters(_ parameters: [String]) throws -> Self {
            guard parameters.count == deepLinkParameters.count else {
                throw IncorrectParameterCountError(errorDescription: "Incorrect number of parameter provided. Requires \(deepLinkParameters.count) but \(parameters.count) were provided.")
            }
            return Self(
        """#

        let enumeratedParameters = parameters.enumerated()

        for (index, parameter) in enumeratedParameters {
            let name: String = {
                if let secondName = parameter.secondName {
                    return nameMap[secondName.trimmed.text] ?? secondName.trimmed.text
                } else {
                    return nameMap[parameter.firstName.trimmed.text] ?? parameter.firstName.trimmed.text
                }
            }()
            deepLinkParameters += "\n"
            deepLinkParameters += #"DeepLinkParameter(name: "\#(name)", type: \#(parameter.type.trimmed).self),"#

            if index != 0 {
                makeWithParameters += ","
            }

            makeWithParameters += "\n"
            makeWithParameters += #"\#(parameter.firstName.trimmed): try DeepLinkParameterFactory.makeValue(string: parameters[\#(index)], parameterIndex: \#(index), parameterName: "\#(name)")"#
        }

        deepLinkParameters += "\n]"
        makeWithParameters += """
            )
        }
        """

        return [
            "\(raw: deepLinkParameters)",
            "\(raw: makeWithParameters)",
        ]
    }
}


