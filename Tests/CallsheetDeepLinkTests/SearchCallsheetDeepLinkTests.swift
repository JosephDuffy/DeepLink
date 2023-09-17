import DeepLinkTestSupport
import CallsheetDeepLink
import XCTest

final class SearchCallsheetDeepLinkTests: XCTestCase {
    func testCreatingURL() {
        let deepLink = SearchCallsheetDeepLink(mediaType: .tv, query: "Modern Family")
        AssertEqual(
            deepLink.url,
            "callsheet://search/tv?q=Modern%20Family"
        )
    }
}
