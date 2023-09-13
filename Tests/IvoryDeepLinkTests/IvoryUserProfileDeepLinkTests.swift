import IvoryDeepLink
import XCTest

final class IvoryUserProfileDeepLinkTests: XCTestCase {
    func testLinkWithoutLoggedInAccount() {
        let link = IvoryUserProfileDeepLink(
            accountToOpen: MastodonAccount(
                username: "josephduffy",
                domain: "mastodon.social"
            )
        )
        XCTAssertEqual(
            link.url.absoluteString,
            "ivory://josephduffy@mastodon.social/user_profile/josephduffy@mastodon.social"
        )
    }

    func testLinkWithLoggedInAccount() {
        let link = IvoryUserProfileDeepLink(
            loggedInAccount: MastodonAccount(
                username: "ivory",
                domain: "tapbots.social"
            ),
            accountToOpen: MastodonAccount(
                username: "josephduffy",
                domain: "mastodon.social"
            )
        )
        XCTAssertEqual(
            link.url.absoluteString,
            "ivory://ivory@tapbots.social/user_profile/josephduffy@mastodon.social"
        )
    }
}
