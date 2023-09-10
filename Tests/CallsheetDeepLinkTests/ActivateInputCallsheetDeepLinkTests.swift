import CallsheetDeepLink
import XCTest

final class ActivateInputCallsheetDeepLinkTests: XCTestCase {
    func testCreatingURL() {
        let deepLink = ActivateInputCallsheetDeepLink()
        XCTAssertEqual(
            deepLink.url.absoluteString,
            "callsheet://activateInput"
        )
    }
}
