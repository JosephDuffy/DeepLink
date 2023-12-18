import DeepLink

@DeepLink(generateInitWithURL: true)
public struct NewFeedbackFeedbackAssistantDeepLink: FeedbackAssistantDeepLink {
    @Host
    private let host = "new"

    public init() {}
}
