import DeepLinkTestSupport
import FeedbackAssistantDeepLink
import XCTest

final class NewFeedbackFeedbackAssistantDeepLinkTests: XCTestCase {
    func testCreatingURL() {
        let deepLink = NewFeedbackFeedbackAssistantDeepLink()
        AssertEqual(
            deepLink.url,
            "applefeedback://new"
        )
    }
}
