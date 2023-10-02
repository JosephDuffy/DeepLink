/// A type that can be used as a URL component by converting it to a string.
/// 
/// This enables using a non-string type to reduce the API of a type while
/// retaining the flexibility of using a string to initialise it. For example:
///
/// ```swift
/// @TypedStringURLComponent
/// public struct MediaType: TypedStringURLComponent {
///     public static let tv: Self = "tv"
///     public static let movie: Self = "movie"
///     public static let music: Self = "music"
/// }
/// ```
///
/// The `TypedStringURLComponent` macro can add this conformance automatically.
public protocol TypedStringURLComponent: ExpressibleByStringLiteral, Hashable, LosslessStringConvertible, Sendable {}
