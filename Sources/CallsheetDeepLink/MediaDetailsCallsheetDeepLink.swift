import DeepLink

/// Open the details screen displaying the media with the provieded TMDB
/// identifier and media type.
@DeepLink(generateInitWithURL: true)
public struct MediaDetailsCallsheetDeepLink: CallsheetDeepLink {
    @Host
    private let host = "open"

    @PathItem
    public var mediaType: CallsheetMediaType

    @PathItem
    public var tmdbId: Int

    /// - parameter tmdbId: The TMDB identifier of the media to open.
    /// - parameter mediaType: The type of media the item with ``tmdbId`` is.
    public init(mediaType: CallsheetMediaType, tmdbId: Int) {
        self.mediaType = mediaType
        self.tmdbId = tmdbId
    }
}
