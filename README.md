# DeepLink

The `DeepLink` package enables easily creating type-safe deep links. Deep links for some apps are included with the package. For apps that aren't included custom deep link types can be created using the `@DeepLink` macro.

```swift
@DeepLink(generateInitWithURL: true)
public struct SearchDeepLink: DeepLink {
    public static let scheme = "example"

    @Host
    private let host = "search"

    @PathItem
    public var category = "all"

    @QueryItem(name: "q")
    public var query: String
}

// DeepLink will add `url` property and `init(url:)`

SearchDeepLink.scheme // "example"
SearchDeepLink(query: "hello world").url.absoluteString // "example://search/all?q=hello%20world"

let deepLink = SearchDeepLink(url: URL(string: "example://search/tv?q=still%20up")!)!
deepLink.category // "tv"
deepLink.query // "still up"
```

## Supported Apps

Want to add an app to the project? Please open a pull request!

- Callsheet
- Feedback Assistant
- Ivory
- Mail
- Overcast

## Type Flexibility

Rather than being strict with its typings DeepLink relies on string interpolation to build URLs. This allows properties to be any type that conforms to `CustomStringConvertible`, such as `Int`s, enums, and custom types.

If a property is optional it will only be used to build the URL when it is non-nil. This is particularly useful for optional query items.

This also extends to initialising a deep link with a `URL` -- as long as the type conforms to `LosslessStringConvertible`.

## Why

The idea for this came about when I saw the [URL scheme for Callsheet on Mastodon](https://mastodon.social/@caseyliss/111024103966666334), which made me think about how I added the Ivory URL scheme in to an [unreleased project of mine](https://github.com/JosephDuffy/FediFriend "FediFriend on GitHub").

I then thought this would be an interesting project to use Swift macros with and at that point I had nerd sniped myself. I also think it's useful to have a repository of the URL schemes available for various apps.

## Generating Links

The Swift REPL can be used to generate links in the terminal. This can be useful to test how other apps work, or if you're adding support for a new app to test that the generated strings work (this is not a substitute for unit tests 😉).

```shell
# Assumes you're in the package's root
$ swift run --repl
```

```
Welcome to Apple Swift version 5.9 (swiftlang-5.9.0.128.2 clang-1500.0.40.1).
Type :help for assistance.
  1> import CallsheetDeepLink
  2> ActivateInput().url
$R0: Foundation.URL = "callsheet://activateInput"
```

## Future Direction

- Support for more apps
- Add metadata for external tools to read
  - Could enable creating a tool for generating and testing deep links
