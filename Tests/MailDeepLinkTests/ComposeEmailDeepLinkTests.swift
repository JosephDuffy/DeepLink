import MailDeepLink
import XCTest

final class ComposeEmailDeepLinkTests: XCTestCase {
    func testLinkWithoutValues() {
        let deepLink = ComposeEmailDeepLink()
        XCTAssertEqual(
            deepLink.url.absoluteString,
            "mailto:"
        )
    }

    func testLinkWithToAddress() {
        let deepLink = ComposeEmailDeepLink(to: "test@example.com")
        XCTAssertEqual(
            deepLink.url.absoluteString,
            "mailto:test@example.com"
        )
    }

    func testLinkWithToAddressAndSubject() {
        let deepLink = ComposeEmailDeepLink(to: "test@example.com", subject: "Test Subject")
        XCTAssertEqual(
            deepLink.url.absoluteString,
            "mailto:test@example.com?subject=Test%20Subject"
        )
    }

    func testLinkWithSubject() {
        let deepLink = ComposeEmailDeepLink(subject: "Test Subject")
        XCTAssertEqual(
            deepLink.url.absoluteString,
            "mailto:?subject=Test%20Subject"
        )
    }
}
