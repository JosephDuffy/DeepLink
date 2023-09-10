import DeepLink

/// A deep link to the search UI with the keyboard activated.
///
/// This screen also shows recent searches.
@StaticDeepLink("activateInput")
public struct ActivateInputCallsheetDeepLink: CallsheetDeepLink {
    public init() {}
}
