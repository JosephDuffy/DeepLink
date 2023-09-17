import Foundation

func queryItemsAreInIncreasingOrder(_ lhs: URLQueryItem, _ rhs: URLQueryItem) -> Bool {
    if lhs.name == rhs.name {
        switch (lhs.value, rhs.value) {
        case (.some(let lhsValue), .some(let rhsValue)):
            return lhsValue < rhsValue
        case (nil, .some), (nil, nil):
            return true
        case (.some, nil):
            return false
        }
    } else {
        return lhs.name < rhs.name
    }
}
