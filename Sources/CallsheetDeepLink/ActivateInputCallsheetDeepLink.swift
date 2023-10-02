import DeepLink

/// A deep link to the search UI with the keyboard activated.
///
/// This screen also shows recent searches.
@DeepLink(generateInitWithURL: true)
public struct ActivateInputCallsheetDeepLink: CallsheetDeepLink {
    @Host
    private let host = "activateInput"

    /// Create a new deep link that opens the search UI with the keyboard
    /// activated.
    public init() {}
}
