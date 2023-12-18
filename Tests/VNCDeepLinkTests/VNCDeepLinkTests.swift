import DeepLinkTestSupport
import VNCDeepLink
import XCTest

final class OvercastSubscribeDeepLinkTests: XCTestCase {
    func testLinkWithDefaultPort() {
        let link = VNCDeepLink(host: "example.com")
        AssertEqual(
            link.url,
            "vnc://example.com"
        )
    }

    func testLinkWithNonDefaultPort() {
        let link = VNCDeepLink(host: "example.com", port: 1234)
        AssertEqual(
            link.url,
            "vnc://example.com:1234"
        )
    }

    func testLinkWithNonDefaultPortAndUser() {
        let link = VNCDeepLink(host: "example.com", user: "test-user", port: 1234)
        AssertEqual(
            link.url,
            "vnc://test-user@example.com:1234"
        )
    }

    func testLinkWithNonDefaultPortAndUserAndConnectionName() {
        let link = VNCDeepLink(
            host: "example.com",
            user: "test-user",
            port: 1234,
            connectionName: "my connection name"
        )
        AssertEqual(
            link.url,
            "vnc://test-user@example.com:1234?ConnectionName=my%20connection%20name"
        )
    }

    func testLinkWithNonDefaultPortAndUserAndConnectionNameAndCustomParameters() {
        let link = VNCDeepLink(
            host: "example.com",
            user: "test-user",
            port: 1234,
            connectionName: "my connection name",
            otherURIParameters: [
                "custom": "custom-value",
                "other-custom": "value2",
            ]
        )
        AssertEqual(
            link.url,
            "vnc://test-user@example.com:1234?ConnectionName=my%20connection%20name&custom=custom-value&other-custom=value2"
        )
    }

    func testParsingURLWithNonDefaultPortAndUserAndConnectionNameAndCustomParameters() throws {
        let url = URL(string: "vnc://test-user@example.com:1234?ConnectionName=my%20connection%20name&custom=custom-value&other-custom=value2")!
        let link = try XCTUnwrap(VNCDeepLink(url: url))
        XCTAssertEqual(
            link.user,
            "test-user"
        )
        XCTAssertEqual(link.host, "example.com")
        XCTAssertEqual(link.port, 1234)
        XCTAssertEqual(link.connectionName, "my connection name")
        XCTAssertEqual(
            link.uriParameters,
            [
                "custom": "custom-value",
                "other-custom": "value2",
            ]
        )
    }
}
