import DeepLink

@DeepLink(generateInitWithURL: true, trailingSlash: true)
public struct TVSeasonCallsheetDeepLink: CallsheetDeepLink, ParameterisedDeepLink {
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

    @ParametersInitialiser(nameMap: ["tmdbId": "TMDB ID", "season": "Season"])
    public init(tmdbId: Int, season: Int) {
        self.tmdbId = tmdbId
        self.season = season
    }
}
