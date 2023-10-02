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
