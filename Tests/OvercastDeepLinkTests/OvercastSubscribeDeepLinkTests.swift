import DeepLinkTestSupport
import OvercastDeepLink
import XCTest

final class OvercastSubscribeDeepLinkTests: XCTestCase {
    func testLinkWithOnlyRSSURL() {
        let link = OvercastSubscribeDeepLink(
            rssURL: URL(string: "https://www.relay.fm/cortex/feed")!
        )
        AssertEqual(
            link.url,
            "overcast://x-callback-url/add?url=https://www.relay.fm/cortex/feed"
        )
    }

    func testLinkWithCallbackURL() {
        let link = OvercastSubscribeDeepLink(
            rssURL: URL(string: "https://atp.fm/rss")!,
            callbackURL: URL(string: "https://example.com?query=value")!
        )
        AssertEqual(
            link.url,
            "overcast://x-callback-url/add?url=https://atp.fm/rss&x-success=https://example.com?query%3Dvalue"
        )
    }
}
