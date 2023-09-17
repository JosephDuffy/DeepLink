import DeepLinkTestSupport
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
        AssertEqual(
            link.url,
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
        AssertEqual(
            link.url,
            "ivory://ivory@tapbots.social/user_profile/josephduffy@mastodon.social"
        )
    }
}
