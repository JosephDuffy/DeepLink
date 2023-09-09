import Foundation

public protocol DeepLink: Hashable, Sendable {
    /// The scheme of the
    static var scheme: String { get }

    var url: URL { get }
}
