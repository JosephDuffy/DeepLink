import DeepLinkPlugin
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

private let testMacros: [String: Macro.Type] = [
    "DeepLink": DeepLink.self,
    "Host": Host.self,
    "PathItem": PathItem.self,
    "QueryItem": QueryItem.self,
]

final class DeepLinkTests: XCTestCase {
    func testDeepLinkWithHostOnly() {
        assertMacroExpansion(
            """
            @DeepLink
            struct TestDeepLink {
                @Host
                let hostProperty = "host"
            }
            """,
            expandedSource: #"""

            struct TestDeepLink {
                let hostProperty = "host"

                public var url: URL {
                    var components = URLComponents()
                    components.scheme = Self.scheme
                    components.host = "\(self.hostProperty)"
                    return components.url!
                }
            }
            """#,
            macros: testMacros
        )
    }

    func testDeepLinkWithHostAndPathItems() {
        assertMacroExpansion(
            """
            @DeepLink
            struct TestDeepLink {
                @Host
                let hostProperty = "host"

                @PathItem
                private let path1 = "first-path"

                @PathItem
                var path2 = 123
            }
            """,
            expandedSource: #"""

            struct TestDeepLink {
                let hostProperty = "host"
                private let path1 = "first-path"
                var path2 = 123

                public var url: URL {
                    var components = URLComponents()
                    components.scheme = Self.scheme
                    components.host = "\(self.hostProperty)"
                    var path = ""
                    if components.host != nil {
                        path = "/"
                    }
                    path += [
                        "\(path1)",
                        "\(path2)",
                    ].joined(separator: "/")
                    components.path = path
                    return components.url!
                }
            }
            """#,
            macros: testMacros
        )
    }

    func testDeepLinkWithHostAndTrailingSlash() {
        assertMacroExpansion(
            """
            @DeepLink(trailingSlash: true)
            struct TestDeepLink {
                @Host
                let hostProperty = "host"

                @PathItem
                private let path1 = "first-path"

                @PathItem
                var path2 = 123
            }
            """,
            expandedSource: #"""

            struct TestDeepLink {
                let hostProperty = "host"
                private let path1 = "first-path"
                var path2 = 123

                public var url: URL {
                    var components = URLComponents()
                    components.scheme = Self.scheme
                    components.host = "\(self.hostProperty)"
                    var path = ""
                    if components.host != nil {
                        path = "/"
                    }
                    path += [
                        "\(path1)",
                        "\(path2)",
                    ].joined(separator: "/")
                    components.path = path
                    if !components.path.isEmpty {
                        components.path += "/"
                    }
                    return components.url!
                }
            }
            """#,
            macros: testMacros
        )
    }

    func testDeepLinkWithHostAndQueryItems() {
        assertMacroExpansion(
            """
            @DeepLink(trailingSlash: true)
            struct TestDeepLink {
                @Host
                let hostProperty = "host"

                @PathItem
                private let path1 = "first-path"

                @PathItem
                var path2 = 123

                @QueryItem(name: "query1")
                var q1 = "default"

                @QueryItem
                var q2: Int? = 7

                @QueryItem(includeWhenNil: true)
                var q3: Optional<Int> = 7
            }
            """,
            expandedSource: #"""

            struct TestDeepLink {
                let hostProperty = "host"
                private let path1 = "first-path"
                var path2 = 123
                var q1 = "default"
                var q2: Int? = 7
                var q3: Optional<Int> = 7

                public var url: URL {
                    var components = URLComponents()
                    components.scheme = Self.scheme
                    components.host = "\(self.hostProperty)"
                    var path = ""
                    if components.host != nil {
                        path = "/"
                    }
                    path += [
                        "\(path1)",
                        "\(path2)",
                    ].joined(separator: "/")
                    components.path = path
                    if !components.path.isEmpty {
                        components.path += "/"
                    }
                    var queryItems: [URLQueryItem] = [
                        URLQueryItem(name: "query1", value: self.q1),
                        URLQueryItem(name: "q3", value: self.q3.map {
                                "\($0)"
                            })]
                    if let q2 = self.q2 {
                        queryItems.append(URLQueryItem(name: "q2", value: q2))
                    }
                    if !queryItems.isEmpty {
                        components.queryItems = queryItems
                    }
                    return components.url!
                }
            }
            """#,
            macros: testMacros
        )
    }
}
