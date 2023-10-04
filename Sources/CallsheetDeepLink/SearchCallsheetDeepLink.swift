import DeepLink

/// A deep link to the the search UI with a prefilled query.
@DeepLink(generateInitWithURL: true)
public struct SearchCallsheetDeepLink: CallsheetDeepLink, ParameterisedDeepLink {
    @Host
    private let host = "search"

    @PathItem
    public var mediaType: CallsheetMediaType

    @QueryItem(name: "q")
    public var query: String

    /// Create a deep link that opens the search UI with the provided query
    /// prefilled.
    ///
    /// - parameter mediaType: The type of media to filter by. As version 2023.3
    ///   this is ignored. See https://mastodon.social/@caseyliss/111028913064766244
    /// - parameter query: The query to prefill.
    @ParametersInitialiser(nameMap: ["mediaType": "Media Type", "query": "Query"])
    public init(mediaType: CallsheetMediaType, query: String) {
        self.mediaType = mediaType
        self.query = query
    }
}
