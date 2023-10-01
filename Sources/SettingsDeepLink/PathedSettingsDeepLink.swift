import DeepLink

public protocol PathedSettingsDeepLink<Path>: SettingsDeepLink {
    associatedtype Path: TypedStringURLComponent

    var path: Path? { get }
}
