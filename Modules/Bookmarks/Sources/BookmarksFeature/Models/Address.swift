public struct Address: Equatable, Sendable {
    public let street: String?
    public let postalCode: String?
    public let locality: String

    public init(street: String?, postalCode: String?, locality: String) {
        self.street = street
        self.postalCode = postalCode
        self.locality = locality
    }
}
