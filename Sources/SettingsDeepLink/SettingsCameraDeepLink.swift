import DeepLink

@DeepLink
public struct SettingsCameraDeepLink: PathedSettingsDeepLink {
    @PathItem
    public let root: SettingsRoot = .camera

    @QueryItem
    public var path: SettingsCameraPath?
    
    public init(path: SettingsCameraPath? = nil) {
        self.path = path
    }
}

extension SettingsRoot {
    public static var camera: SettingsRoot {
        "CAMERA"
    }
}

@TypedStringURLComponent
public struct SettingsCameraPath: TypedStringURLComponent {
    public static var recordVideo: Self {
        "Record Video"
    }
    public static var recordSloMo: Self {
        "Record Slo-mo"
    }
}
