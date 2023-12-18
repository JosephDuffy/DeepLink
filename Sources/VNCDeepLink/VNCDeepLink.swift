import DeepLink

/// A deep link to open a VNC client.
///
/// Reference: https://www.rfc-editor.org/rfc/rfc7869.html
@DeepLink(generateInitWithURL: true)
public struct VNCDeepLink: DeepLink {
    public static let scheme = "vnc"

    @Host
    public var host: String

    @User
    public var user: String?

    @Port
    public var port: Int = 5900

    @QueryItem(name: "ConnectionName")
    public var connectionName: String?

    @QueryItems
    public var uriParameters: [VNCParameter: String?]

    public init(
        host: String,
        user: String? = nil,
        port: Int = 5900,
        connectionName: String? = nil,
        otherURIParameters: [VNCParameter: String?] = [:]
    ) {
        self.host = host
        self.user = user
        self.port = port
        var uriParameters = otherURIParameters
        if let connectionName {
            uriParameters[.connectionName] = connectionName
        }
        self.uriParameters = uriParameters
    }
}
