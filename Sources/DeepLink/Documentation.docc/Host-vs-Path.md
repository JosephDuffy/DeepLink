# `Host` vs `Path`

When creating a custom `DeepLink` it's important to understand and account for the difference between the host and path portions of a URL.

The _path_ component is defined by adding the `@Path` macro to 1 or more properties.

The _host_ component is defined by adding the `@Host` macro to a property, which can be added on up to 1 property within a type decorated with `@DeepLink`.

Section 3.2. of [RFC 3986](https://www.ietf.org/rfc/rfc3986.txt) covers the _authority_ component of the URL, which has 3 important things to remember:

1. The authority component requires a _host_
2. The authority component is preceded by a double slash (`//`)
3. When an authority component is present the _path_ must either be empty or begin with a slash (`/`) character

`@DeepLink` will account for these things itself, but when you're creating your own deep links it's necessary to know when you need `@Host` and when it should be omitted. Look at these examples:

```
https://github.com/JosephDuffy/DeepLink
\___/   \________/\___________________/
  |          |              |
scheme      host           path

mailto:test@example.com
\____/ \______________/
  |           |
scheme       path

example:/my/long/path/
\_____/ \____________/
  |           |
scheme       path
```

When `@DeepLink` is building a URL it will account for all these rules.

```swift
@DeepLink
struct ExampleDeepLink: DeepLink {
    static let scheme = "example"

    @Host
    var host: String?

    @Path
    var firstPathPart: String

    @Path
    var secondPathPart: String?
}

ExampleDeepLink(firstPathPath: "path1").url.absoluteString
// example:path1

ExampleDeepLink(host: "test-host", firstPathPath: "path1").url.absoluteString
// example://test-host/path1

ExampleDeepLink(host: "test-host", firstPathPath: "path1", secondPathPart: "path2").url.absoluteString
// example://test-host/path1/path2

ExampleDeepLink(host: "test-host", firstPathPath: "path1").url.absoluteString
// example://test-host/path1

ExampleDeepLink(firstPathPath: "path1", secondPathPart: "path2").url.absoluteString
// example:path1/path2
```
