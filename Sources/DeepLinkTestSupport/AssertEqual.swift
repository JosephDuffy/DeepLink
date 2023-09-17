import Foundation
import XCTest

public func AssertEqual(
    _ url: @autoclosure () -> URL,
    _ expected: @autoclosure () -> String,
    file: StaticString = #filePath,
    line: UInt = #line
) {
    guard let components = URLComponents(url: url(), resolvingAgainstBaseURL: false) else {
        XCTFail("Invalid URL", file: file, line: line)
        return
    }
    guard let expectedComponents = URLComponents(string: expected()) else {
        XCTFail("String is not a valid URL", file: file, line: line)
        return
    }

    XCTAssertEqual(
        components.scheme,
        expectedComponents.scheme,
        "URL schemes do not match",
        file: file,
        line: line
    )

    XCTAssertEqual(
        components.user,
        expectedComponents.user,
        "URL user components do not match",
        file: file,
        line: line
    )

    XCTAssertEqual(
        components.password,
        expectedComponents.password,
        "URL password components do not match",
        file: file,
        line: line
    )

    XCTAssertEqual(
        components.host,
        expectedComponents.host,
        "URL host components do not match",
        file: file,
        line: line
    )

    XCTAssertEqual(
        components.port,
        expectedComponents.port,
        "URL port components do not match",
        file: file,
        line: line
    )

    XCTAssertEqual(
        components.path,
        expectedComponents.path,
        "URL path components do not match",
        file: file,
        line: line
    )

    XCTAssertEqual(
        components.fragment,
        expectedComponents.fragment,
        "URL path components do not match",
        file: file,
        line: line
    )

    XCTAssertEqual(
        components.queryItems?.sorted(by: queryItemsAreInIncreasingOrder(_:_:)),
        expectedComponents.queryItems?.sorted(by: queryItemsAreInIncreasingOrder(_:_:)),
        "URL query items do not match",
        file: file,
        line: line
    )
}
