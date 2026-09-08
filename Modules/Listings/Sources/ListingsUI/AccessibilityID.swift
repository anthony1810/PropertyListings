public enum AccessibilityID {
    public static let list = "listings.list"

    public static func row(_ id: String) -> String {
        "listing.row.\(id)"
    }

    public static func like(_ id: String, isOn: Bool) -> String {
        "listing.like.\(id).\(isOn ? "on" : "off")"
    }
}
