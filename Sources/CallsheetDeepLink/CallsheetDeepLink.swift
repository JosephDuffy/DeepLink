import DeepLink
import Foundation

/// A deep link in to the [Callsheet app](https://apps.apple.com/us/app/callsheet-find-cast-crew/id1672356376).
///
/// Reference: https://mastodon.social/@caseyliss/111024103966666334
public enum CallsheetDeepLink {
    public static let scheme = "callsheet"

    /// Open the search UI and activate the keyboard.
    ///
    /// This screen shows recent searches.
    case activateInput

    /// Open the search UI with the provided query prefilled.
    ///
    /// - parameter mediaType: The type of media to filter by. As version 2023.3
    ///   this is ignored. See https://mastodon.social/@caseyliss/111028913064766244
    /// - parameter query: The query to prefill.
    case search(mediaType: String, query: String)

    /// Open the details screen displaying the media with the provieded TMDB
    /// identifier and media type.
    ///
    /// - parameter tmdbId: The TMDB identifier of the media to open.
    /// - parameter mediaType: The type of media the item with ``tmdbId`` is.
    case mediaDetails(tmdbId: Int, mediaType: CallsheetMediaType)

    case tvSeason(tmdbId: Int, season: Int)

    case tvEpisode(tmdbId: Int, season: Int, episode: Int)

    public var url: URL {
        switch self {
        case .activateInput:
            return URL(string: "\(Self.scheme)://activateInput")!
        case .search(let mediaType, let query):
            var components = URLComponents()
            components.scheme = Self.scheme
            components.host = "search"
            components.path = "/\(mediaType)"
            components.queryItems = [
                URLQueryItem(name: "q", value: query)
            ]
            return components.url!
        case .mediaDetails(let tmdbId, let mediaType):
            var components = URLComponents()
            components.scheme = Self.scheme
            components.host = "open"
            components.path = "/\(mediaType)/\(tmdbId)"
            return components.url!
        case .tvSeason(let tmdbId, let season):
            var components = URLComponents()
            components.scheme = Self.scheme
            components.host = "open"
            components.path = "/tv/\(tmdbId)/season/\(season)/"
            return components.url!
        case .tvEpisode(let tmdbId, let season, let episode):
            var components = URLComponents()
            components.scheme = Self.scheme
            components.host = "open"
            components.path = "/tv/\(tmdbId)/season/\(season)/episode/\(episode)"
            return components.url!
        }
    }
}

public struct CallsheetMediaType: CustomStringConvertible, Hashable, Sendable {
    public static var tv: CallsheetMediaType {
        CallsheetMediaType(urlValue: "tv")
    }

    public static var movie: CallsheetMediaType {
        CallsheetMediaType(urlValue: "movie")
    }

    public let urlValue: String

    public var description: String {
        urlValue
    }
}
