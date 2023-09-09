# DeepLinks

The `DeepLinks` package provides various libraries for creating deep links in to apps.

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
  2> CallsheetDeepLink.activateInput.url
$R0: Foundation.URL = "callsheet://activateInput"
```
