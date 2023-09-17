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
}
