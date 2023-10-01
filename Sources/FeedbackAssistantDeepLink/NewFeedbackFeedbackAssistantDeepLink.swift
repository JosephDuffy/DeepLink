import DeepLink

@DeepLink
public struct NewFeedbackFeedbackAssistantDeepLink: FeedbackAssistantDeepLink {
    @Host
    private let host = "new"

    public init() {}
}
