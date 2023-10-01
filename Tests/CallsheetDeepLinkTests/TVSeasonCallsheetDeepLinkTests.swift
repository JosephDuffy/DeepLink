import DeepLinkTestSupport
import CallsheetDeepLink
import XCTest

final class TVSeasonCallsheetDeepLinkTests: XCTestCase {
    func testCreatingURL() {
        let deepLink = TVSeasonCallsheetDeepLink(tmdbId: 3108, season: 1)
        AssertEqual(
            deepLink.url,
            "callsheet://open/tv/3108/season/1/"
        )
    }

    func testURLInitialiserWithURL() throws {
        let url = URL(string: "callsheet://open/tv/3108/season/1/")!
        let deepLink = try XCTUnwrap(TVSeasonCallsheetDeepLink(url: url))
        XCTAssertEqual(deepLink.tmdbId, 3108)
        XCTAssertEqual(deepLink.season, 1)
    }

    func testURLInitialiserWithURLWithoutTrailingSlash() {
        let url = URL(string: "callsheet://open/tv/3108/season/1")!
        XCTAssertNil(TVSeasonCallsheetDeepLink(url: url))
    }
}
