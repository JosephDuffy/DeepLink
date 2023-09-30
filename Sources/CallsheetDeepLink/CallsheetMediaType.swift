import DeepLink

public struct CallsheetMediaType: Hashable, LosslessStringConvertible, Sendable {
    public static var tv: CallsheetMediaType {
        CallsheetMediaType("tv")
    }

    public static var movie: CallsheetMediaType {
        CallsheetMediaType("movie")
    }

    public let description: String

    public init(_ description: String) {
        self.description = description
    }
}
