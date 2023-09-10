import DeepLink

public struct CallsheetMediaType: CustomStringConvertible, Hashable, Sendable {
    public static var tv: CallsheetMediaType {
        CallsheetMediaType(urlValue: "tv")
    }

    public static var movie: CallsheetMediaType {
        CallsheetMediaType(urlValue: "movie")
    }

    public let urlValue: String

    public var description: String {
        urlValue
    }

    public init(urlValue: String) {
        self.urlValue = urlValue
    }
}
