import Foundation

public protocol DeepLink: Hashable, Sendable {
    /// The scheme of the URL used to open the deep link.
    ///
    /// For web links this will be http(s).
    static var scheme: String { get }

    /// The URL of the deep link.
    ///
    /// Check ``DeepLink.canOpen`` to know if this URL can be opened.
    var url: URL { get }
}

public protocol ParameterisedDeepLink: DeepLink {
    static var deepLinkParameters: [DeepLinkParameter] { get }

    static func makeWithParameters(_ parameters: [String]) throws -> Self
}

public struct DeepLinkParameter: Sendable {
    public let name: String

    public let type: Any.Type

    public init(name: String, type: Any.Type) {
        self.name = name
        self.type = type
    }
}

public struct IncorrectParameterCountError: LocalizedError {
    public let errorDescription: String?

    public init(errorDescription: String?) {
        self.errorDescription = errorDescription
    }
}

public enum DeepLinkParameterFactory<Value: LosslessStringConvertible> {
    public static func makeValue(
        string: String,
        parameterIndex: Int,
        parameterName: String
    ) throws -> Value {
        guard let value = Value(string) else {
            throw DeepLinkParameterError(
                errorDescription: "“\(string)” is not a valid \(valueTypeDescription)",
                string: string,
                parameterIndex: parameterIndex,
                parameterName: parameterName
            )
        }
        return value
    }

    private static var valueTypeDescription: String {
        if Value.self == Int.self {
            "number"
        } else {
            "\(Value.self)"
        }
    }
}

import Foundation

public struct DeepLinkParameterError: LocalizedError {
    public let errorDescription: String?

    public let string: String

    public let parameterIndex: Int

    public let parameterName: String

    public init(errorDescription: String?, string: String, parameterIndex: Int, parameterName: String) {
        self.errorDescription = errorDescription
        self.string = string
        self.parameterIndex = parameterIndex
        self.parameterName = parameterName
    }
}
