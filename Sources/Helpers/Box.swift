/**
 * Generic box to allow sharing of objects of value-types (structs, enums, etc)
 *
 * See https://www.hackingwithswift.com/articles/92/how-to-share-structs-using-boxing
 */
public final class Box<T> {
    public var value: T

    public init(_ value: T) {
        self.value = value
    }
}

extension Box: Equatable where T: Equatable {
    public static func == (lhs: Box, rhs: Box) -> Bool {
        return lhs.value == rhs.value
    }
}

extension Box: Comparable where T: Comparable {
    public static func < (lhs: Box, rhs: Box) -> Bool {
        return lhs.value < rhs.value
    }
}

extension Box: CustomStringConvertible where T: CustomStringConvertible {
    public var description: String {
        "\(value.description)"
    }
}

extension Box: CustomDebugStringConvertible {
    public var debugDescription: String {
        "Box(\(String(reflecting: value)))"
    }
}
