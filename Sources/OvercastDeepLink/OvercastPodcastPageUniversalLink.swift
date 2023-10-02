import DeepLink

/// A universal link to a podcast's page in Overcast, if the app is installed,
/// otherwise this opens the Overcast website for the podcast.
///
/// Reference: https://overcast.fm/podcasterinfo
@DeepLink(scheme: "https")
public struct OvercastPodcastPageUniversalLink: DeepLink {
    @Host
    public let host = "overcast.fm"

    /// The Apple-provided identifier for the podcast.
    public var iTunesId: Int {
        get {
            path.iTunesId
        }
        set {
            path.iTunesId = newValue
        }
    }

    @PathItem
    private var path: OvercastiTunesID

    /// The name of the podcast, which is automatically appended to the URL by
    /// the Overcast server if not provided or incorrect.
    ///
    /// Takes the form `podcast.name.replacingOccurrences(of: " ", with: "-").lowercased()`.
    @PathItem
    public var name: String?

    public init(iTunesId: Int, name: String? = nil) {
        self.path = OvercastiTunesID(iTunesId: iTunesId)
        self.name = name
    }
}

/// An iTunes ID as used by Overcast.
///
/// The conforms to `LosslessStringConvertible` which will allow
/// `generateInitWithURL` to be set to `true` once support for optional
/// `@PathItem`s is support when it's the last path item.
private struct OvercastiTunesID: Hashable, LosslessStringConvertible, Sendable {
    private static let prefix = "itunes"

    public var iTunesId: Int

    public var description: String {
        "\(Self.prefix)\(iTunesId)"
    }

    public init(iTunesId: Int) {
        self.iTunesId = iTunesId
    }

    public init?(_ description: String) {
        guard description.hasPrefix(Self.prefix) else { return nil }
        let possibleId = description.dropFirst(Self.prefix.count)
        guard let iTunesId = Int(possibleId) else { return nil }
        self.iTunesId = iTunesId
    }
}
