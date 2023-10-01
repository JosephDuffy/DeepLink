import DeepLink

/// A deep link to open a screen used to compose a new email.
///
/// If no values are provided this will open a blank compose UI.
///
/// Reference: https://datatracker.ietf.org/doc/html/rfc6068
@DeepLink
public struct ComposeEmailDeepLink: MailDeepLink {
    /// The email address(es) the email should be sent to. This can be provide
    /// as the host of the URL, as the `to` query parameter, or as a mixture of
    /// both. It is recommended to only use the host for this purpose.
    ///
    /// To send to multiple email addresses separate each address with a comma.
    @PathItem
    public var to: String?

    @QueryItem
    public var subject: String?

    @QueryItem
    public var body: String?

    public var otherHeaders: [String: String?]

    @QueryItems
    private var _otherHeaders: [URLQueryItem] {
        otherHeaders.map { URLQueryItem(name: $0.key, value: $0.value) }
    }

    public init(
        to: String? = nil,
        subject: String? = nil,
        body: String? = nil,
        otherHeaders: [String: String?] = [:]
    ) {
        self.to = to
        self.subject = subject
        self.body = body
        self.otherHeaders = otherHeaders
    }
}
