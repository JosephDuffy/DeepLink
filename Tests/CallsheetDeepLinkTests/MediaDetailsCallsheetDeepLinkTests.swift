import CallsheetDeepLink
import XCTest

final class MediaDetailsCallsheetDeepLinkTests: XCTestCase {
    func testCreatingURL() {
        let deepLink = MediaDetailsCallsheetDeepLink(mediaType: .movie, tmdbId: 49020)
        XCTAssertEqual(
            deepLink.url.absoluteString,
            "callsheet://open/movie/49020"
        )
    }
}
