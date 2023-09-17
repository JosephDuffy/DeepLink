import DeepLinkTestSupport
import MailDeepLink
import XCTest

final class ComposeEmailDeepLinkTests: XCTestCase {
    func testLinkWithoutValues() {
        let deepLink = ComposeEmailDeepLink()
        AssertEqual(
            deepLink.url,
            "mailto:"
        )
    }

    func testLinkWithToAddress() {
        let deepLink = ComposeEmailDeepLink(to: "test@example.com")
        AssertEqual(
            deepLink.url,
            "mailto:test@example.com"
        )
    }

    func testLinkWithToAddressAndSubject() {
        let deepLink = ComposeEmailDeepLink(to: "test@example.com", subject: "Test Subject")
        AssertEqual(
            deepLink.url,
            "mailto:test@example.com?subject=Test%20Subject"
        )
    }

    func testLinkWithSubject() {
        let deepLink = ComposeEmailDeepLink(subject: "Test Subject")
        AssertEqual(
            deepLink.url,
            "mailto:?subject=Test%20Subject"
        )
    }

    func testLinkWithToAddressAndSubjectAndExtraHeaders() {
        let deepLink = ComposeEmailDeepLink(
            to: "test@example.com",
            subject: "Test Subject",
            otherHeaders: [
                "cc": "other@example.com",
                "bcc": "secret@example.com",
            ]
        )
        AssertEqual(
            deepLink.url,
            "mailto:test@example.com?subject=Test%20Subject&cc=other@example.com&bcc=secret@example.com"
        )
    }
}
