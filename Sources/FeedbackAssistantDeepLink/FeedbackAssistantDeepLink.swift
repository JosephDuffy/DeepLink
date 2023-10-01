import DeepLink

/// A deep link in to the [Feedback Assitant app](https://apps.apple.com/us/app/callsheet-find-cast-crew/id1672356376).
///
/// Reference: [](https://mastodon.social/@caseyliss/111024103966666334)
public protocol FeedbackAssistantDeepLink: DeepLink {}

extension FeedbackAssistantDeepLink {
    public static var scheme: String {
        "applefeedback"
    }
}
