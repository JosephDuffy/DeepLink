import DeepLinkTestSupport
import CallsheetDeepLink
import XCTest

final class SearchCallsheetDeepLinkTests: XCTestCase {
    func testCreatingURL() {
        let deepLink = SearchCallsheetDeepLink(mediaType: .tv, query: "Modern Family")
        AssertEqual(
            deepLink.url,
            "callsheet://search/tv?q=Modern%20Family"
        )
    }

    func testURLInitialiserWithMovieSearch() throws {
        let url = URL(string: "callsheet://search/movie?q=Subamrine")!
        let deepLink = try XCTUnwrap(SearchCallsheetDeepLink(url: url))
        XCTAssertEqual(deepLink.mediaType, .movie)
        XCTAssertEqual(deepLink.query, "Subamrine")
    }

    func testURLInitialiserWithTVSearch() throws {
        let url = URL(string: "callsheet://search/tv?q=Modern%20Family")!
        let deepLink = try XCTUnwrap(SearchCallsheetDeepLink(url: url))
        XCTAssertEqual(deepLink.mediaType, .tv)
        XCTAssertEqual(deepLink.query, "Modern Family")
    }

    func testURLInitialiserWithCustomSearch() throws {
        let url = URL(string: "callsheet://search/custom?q=Modern%20Family")!
        let deepLink = try XCTUnwrap(SearchCallsheetDeepLink(url: url))
        XCTAssertEqual(deepLink.mediaType, CallsheetMediaType("custom"))
        XCTAssertEqual(deepLink.query, "Modern Family")
    }

    func testURLInitialiserWithEmptyQuery() throws {
        let url = URL(string: "callsheet://search/movie?q=")!
        let deepLink = try XCTUnwrap(SearchCallsheetDeepLink(url: url))
        XCTAssertEqual(deepLink.mediaType, .movie)
        XCTAssertEqual(deepLink.query, "")
    }

    func testURLInitialiserWithInvalidHost() throws {
        let url = URL(string: "callsheet://search-invalid/movie?q=test")!
        XCTAssertNil(SearchCallsheetDeepLink(url: url))
    }

    func testURLInitialiserWithoutMediaType() throws {
        let url = URL(string: "callsheet://search/?q=test")!
        XCTAssertNil(SearchCallsheetDeepLink(url: url))
    }

    func testURLInitialiserWithoutQueryMediaType() throws {
        let url = URL(string: "callsheet://search/tv")!
        XCTAssertNil(SearchCallsheetDeepLink(url: url))
    }
}
