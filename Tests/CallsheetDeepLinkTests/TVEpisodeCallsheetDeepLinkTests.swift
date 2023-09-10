import CallsheetDeepLink
import XCTest

final class TVEpisodeCallsheetDeepLinkTests: XCTestCase {
    func testCreatingURL() {
        let deepLink = TVEpisodeCallsheetDeepLink(tmdbId: 15260, season: 6, episode: 7)
        XCTAssertEqual(
            deepLink.url.absoluteString,
            "callsheet://open/tv/15260/season/6/episode/7"
        )
    }
}
