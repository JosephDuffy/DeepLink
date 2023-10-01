import DeepLinkTestSupport
import CallsheetDeepLink
import XCTest

final class MediaDetailsCallsheetDeepLinkTests: XCTestCase {
    func testCreatingURL() {
        let deepLink = MediaDetailsCallsheetDeepLink(mediaType: .movie, tmdbId: 49020)
        AssertEqual(
            deepLink.url,
            "callsheet://open/movie/49020"
        )
    }

    func testURLInitialiserWithMovieURL() throws {
        let url = URL(string: "callsheet://open/movie/49020")!
        let deepLink = try XCTUnwrap(MediaDetailsCallsheetDeepLink(url: url))
        XCTAssertEqual(deepLink.mediaType, .movie)
        XCTAssertEqual(deepLink.tmdbId, 49020)
    }

    func testURLInitialiserWithTVURL() throws {
        let url = URL(string: "callsheet://open/tv/15260")!
        let deepLink = try XCTUnwrap(MediaDetailsCallsheetDeepLink(url: url))
        XCTAssertEqual(deepLink.mediaType, .tv)
        XCTAssertEqual(deepLink.tmdbId, 15260)
    }

    func testURLInitialiserWithCustomTypeURL() throws {
        let url = URL(string: "callsheet://open/custom/123")!
        let deepLink = try XCTUnwrap(MediaDetailsCallsheetDeepLink(url: url))
        XCTAssertEqual(deepLink.mediaType, CallsheetMediaType("custom"))
        XCTAssertEqual(deepLink.tmdbId, 123)
    }

    func testURLInitialiserWithoutTMDBID() throws {
        XCTAssertNil(MediaDetailsCallsheetDeepLink(url: URL(string: "callsheet://open/tv/")!))
        XCTAssertNil(MediaDetailsCallsheetDeepLink(url: URL(string: "callsheet://open/tv")!))
    }

    func testURLInitialiserWithWrongHost() throws {
        XCTAssertNil(MediaDetailsCallsheetDeepLink(url: URL(string: "callsheet://not-open/tv/15260")!))
    }
}
