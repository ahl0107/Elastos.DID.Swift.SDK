import Foundation

public class JsonNode {
    private var node: Any

    init() {
        self.node = Dictionary<String, Any>()
    }

    init(_ node: Any) {
        self.node = node
    }

    init(_ node: Dictionary<String, Any>) {
        self.node = node
    }

    var isEmpty: Bool {
        // TODO:
        return false
    }

    var count: Int {
        // TOD:
        return 0
    }

    public func toString() -> String {
        // TODO:
        return "TODO"
    }

    func deepCopy() -> JsonNode? {
        // TODO:
        return nil
    }

    func get(forKey key: String) -> JsonNode? {
        // TODO:
        return nil
    }

    func put(forKey key: String, value: String) {
        // TODO:
    }

    func put(forKey key: String, value: Bool) {
        // TOD:
    }

    public func asString() -> String? {
        // TODO:
        return nil
    }

    public func asInteger() -> Int? {
        // TODO:
        return 0
    }

    public func asArray() -> Array<JsonNode>? {
        // TODO:
        return nil
    }

    public func asDictionary() -> Dictionary<String, JsonNode>? {
        // TODO:
        return nil
    }
}