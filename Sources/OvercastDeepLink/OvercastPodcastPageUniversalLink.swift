import DeepLink

/// A universal link to a podcast's page in Overcast, if the app is installed,
/// otherwise this opens the Overcast website for the podcast.
///
/// Reference: https://overcast.fm/podcasterinfo
@DeepLink
public struct OvercastPodcastPageUniversalLink: DeepLink {
    public static let scheme = "https"

    @Host
    public let host = "overcast.fm"

    /// The Apple-provided identifier for the podcast.
    public var iTunesId: Int

    @PathItem
    private var path: String {
        "itunes\(iTunesId)"
    }

    /// The name of the podcast, which is automatically appended to the URL by
    /// the Overcast server if not provided or incorrect.
    ///
    /// Takes the form `podcast.name.replacingOccurrences(of: " ", with: "-").lowercased()`.
    @PathItem
    public var name: String?

    public init(iTunesId: Int, name: String? = nil) {
        self.iTunesId = iTunesId
        self.name = name
    }
}
