import Foundation

func makeRemoteConfigJSON(
    listings: [String: Any]? = nil,
    settings: [String: Any]? = nil,
    tabs: [String]? = nil
) -> Data {
    var json: [String: Any] = [:]
    if let listings { json["listings"] = listings }
    if let settings { json["settings"] = settings }
    if let tabs { json["tabs"] = tabs }
    return try! JSONSerialization.data(withJSONObject: json)
}
