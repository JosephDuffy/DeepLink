import DeepLink

/// A deep link in to the Overcast app that asks the user to subscribe to the
/// ``rssURL``. After the user cancels the request or adds the podcast Overcast
/// will open the ``callbackURL``, if provided.
///
/// Reference: https://overcast.fm/podcasterinfo
@DeepLink(scheme: "overcast")
public struct OvercastSubscribeDeepLink: DeepLink {
    @Host
    public let host = "x-callback-url"

    @PathItem
    private let addPathItem = "add"

    @QueryItem(name: "url")
    public var rssURL: URL

    @QueryItem(name: "x-success")
    public var callbackURL: URL?

    public init(rssURL: URL, callbackURL: URL? = nil) {
        self.rssURL = rssURL
        self.callbackURL = callbackURL
    }
}
