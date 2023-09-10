import DeepLink

/// A deep link in to the [Callsheet app](https://apps.apple.com/us/app/callsheet-find-cast-crew/id1672356376).
///
/// Reference: [](https://mastodon.social/@caseyliss/111024103966666334)
public protocol CallsheetDeepLink: DeepLink {}

extension CallsheetDeepLink {
    public static var scheme: String {
        "callsheet"
    }
}
