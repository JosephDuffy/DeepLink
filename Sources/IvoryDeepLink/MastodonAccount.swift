public struct MastodonAccount: CustomStringConvertible, LosslessStringConvertible, Hashable, Sendable {
    public var username: String

    public var domain: String

    public var description: String {
        "\(username)@\(domain)"
    }

    public init(username: String, domain: String) {
        self.username = username
        self.domain = domain
    }

    public init?(_ description: String) {
        let split = description.components(separatedBy: "@")
        guard split.count == 2 else { return nil }
        username = split[0]
        domain = split[1]
    }
}
