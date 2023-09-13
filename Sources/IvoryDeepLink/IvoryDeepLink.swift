import DeepLink

/// A deep link in to the [Ivory app](https://tapbots.com/ivory/).
///
/// Reference: [](https://tapbots.net/tweetbot3/support/url-schemes/). Note this
/// is the reference for Tweetbot, which Ivory is forked from.
public protocol IvoryDeepLink: DeepLink {}

extension IvoryDeepLink {
    public static var scheme: String {
        "ivory"
    }
}
