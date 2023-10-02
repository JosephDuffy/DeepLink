import DeepLink

/// A kind of media supported by Callsheet.
public struct CallsheetMediaType: Hashable, LosslessStringConvertible, Sendable {
    /// A TV show.
    public static var tv: CallsheetMediaType {
        CallsheetMediaType("tv")
    }

    /// A movie.
    public static var movie: CallsheetMediaType {
        CallsheetMediaType("movie")
    }

    public let description: String

    public init(_ description: String) {
        self.description = description
    }
}
