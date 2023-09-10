import DeepLink

@DeepLink
public struct TVEpisodeCallsheetDeepLink: CallsheetDeepLink {
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

    @PathItem
    private let epsisodePathItem = "episode"

    @PathItem
    public var epiosde: Int

    public init(tmdbId: Int, season: Int, episode: Int) {
        self.tmdbId = tmdbId
        self.season = season
        self.epiosde = episode
    }
}
