import DeepLink

@DeepLink(generateInitWithURL: true)
public struct TVEpisodeCallsheetDeepLink: CallsheetDeepLink, ParameterisedDeepLink {
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
    private let episodePathItem = "episode"

    @PathItem
    public var episode: Int

    @ParametersInitialiser(nameMap: ["tmdbId": "TMDB ID", "season": "Season", "episode": "Episode"])
    public init(tmdbId: Int, season: Int, episode: Int) {
        self.tmdbId = tmdbId
        self.season = season
        self.episode = episode
    }
}
