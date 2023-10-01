import DeepLink

/// A deep link in to the settings app.
///
/// There is no official reference for the URL scheme, but many people have
/// tried to discover it. The best reference for this has been [MacStories](https://www.macstories.net/ios/a-comprehensive-guide-to-all-120-settings-urls-supported-by-ios-and-ipados-13-1/).
public protocol SettingsDeepLink: DeepLink {
    var root: SettingsRoot { get }
}

extension SettingsDeepLink {
    public static var scheme: String {
        "prefs"
    }
}
