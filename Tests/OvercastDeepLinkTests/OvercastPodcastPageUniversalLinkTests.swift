import OvercastDeepLink
import XCTest

final class OvercastPodcastPageUniversalLinkTests: XCTestCase {
    func testWithiTunesIdOnly() {
        let link = OvercastPodcastPageUniversalLink(iTunesId: 1001591287)
        XCTAssertEqual(
            link.url.absoluteString,
            "https://overcast.fm/itunes1001591287"
        )
    }

    func testWithiTunesIdAndName() {
        let link = OvercastPodcastPageUniversalLink(
            iTunesId: 1570503392,
            name: "safety-third"
        )
        XCTAssertEqual(
            link.url.absoluteString,
            "https://overcast.fm/itunes1570503392/safety-third"
        )
    }
}
