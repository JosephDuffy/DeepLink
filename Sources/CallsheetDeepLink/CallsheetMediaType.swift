import DeepLink

/// A kind of media supported by Callsheet.
@TypedStringURLComponent
public struct CallsheetMediaType: TypedStringURLComponent {
    /// A TV show.
    public static let tv: Self = "tv"

    /// A movie.
    public static let movie: Self = "movie"
}
