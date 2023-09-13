import DeepLink

@DeepLink
public struct IvoryUserProfileDeepLink: IvoryDeepLink {
    /// The account logged in to the Ivory app. If this is provided and the user
    /// is logged in to this account the app will switch to using this account.
    ///
    /// If the user is not logged in to this account no account switch occurs.
    ///
    /// If this is not provied the ``accountToOpen`` will be used.
    public var loggedInAccount: MastodonAccount?

    @User
    private var accountToSwitchToUsername: String {
        _accountToSwitchTo.username
    }

    @Host
    private var accountToSwitchToDomain: String {
        _accountToSwitchTo.domain
    }

    private var _accountToSwitchTo: MastodonAccount {
        loggedInAccount ?? accountToOpen
    }

    @PathItem
    private let profile = "user_profile"

    /// The account to open the profile of.
    @PathItem
    public var accountToOpen: MastodonAccount

    public init(
        loggedInAccount: MastodonAccount? = nil,
        accountToOpen: MastodonAccount
    ) {
        self.loggedInAccount = loggedInAccount
        self.accountToOpen = accountToOpen
    }
}
