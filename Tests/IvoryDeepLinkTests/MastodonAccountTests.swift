import IvoryDeepLink
import XCTest

final class MastodonAccountTests: XCTestCase {
    func testWithSingleAtSign() throws {
        let account = try XCTUnwrap(MastodonAccount("josephduffy@mastodon.com"))
        XCTAssertEqual(account.description, "josephduffy@mastodon.com")
    }

    func testWithoutAtSign() throws {
        XCTAssertNil(MastodonAccount("josephduffy"))
    }

    func testWithMultipleAtSigns() throws {
        XCTAssertNil(MastodonAccount("joseph@duffy@mastodon.social"))
    }

    func testWithEmptyDomain() throws {
        XCTAssertNil(MastodonAccount("josephduffy@"))
    }

    func testWithEmptyUser() throws {
        XCTAssertNil(MastodonAccount("@josephduffy"))
    }
}
