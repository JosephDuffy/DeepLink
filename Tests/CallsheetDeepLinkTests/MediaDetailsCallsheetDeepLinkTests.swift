import DeepLinkTestSupport
import CallsheetDeepLink
import XCTest

final class MediaDetailsCallsheetDeepLinkTests: XCTestCase {
    func testCreatingURL() {
        let deepLink = MediaDetailsCallsheetDeepLink(mediaType: .movie, tmdbId: 49020)
        AssertEqual(
            deepLink.url,
            "callsheet://open/movie/49020"
        )
    }
}
