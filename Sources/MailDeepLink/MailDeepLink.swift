import DeepLink

/// A deep link in to the Mail app. This may open a different email app if the
/// user has chosen to change the default email app.
public protocol MailDeepLink: DeepLink {}

extension MailDeepLink {
    public static var scheme: String {
        "mailto"
    }
}
