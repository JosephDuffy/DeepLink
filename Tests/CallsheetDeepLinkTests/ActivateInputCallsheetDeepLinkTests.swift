import DeepLinkTestSupport
import CallsheetDeepLink
import XCTest

final class ActivateInputCallsheetDeepLinkTests: XCTestCase {
    func testCreatingURL() {
        let deepLink = ActivateInputCallsheetDeepLink()
        AssertEqual(
            deepLink.url,
            "callsheet://activateInput"
        )
    }
}
