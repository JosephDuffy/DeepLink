import DeepLink

@DeepLink(generateInitWithURL: true, trailingSlash: true)
public struct TVSeasonCallsheetDeepLink: CallsheetDeepLink {
    @Host
    private let host = "open"

    @PathItem
    private let mediaType: CallsheetMediaType = .tv

    @PathItem
    public var tmdbId: Int

    @PathItem
    private let seasonPathItem = "season"

    @PathItem
    public var season: Int

    public init(tmdbId: Int, season: Int) {
        self.tmdbId = tmdbId
        self.season = season
    }
}
