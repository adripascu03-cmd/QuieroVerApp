import Foundation

// MARK: - DTOs crudos de la API (decodificación de JSON)

struct TMDbSearchMultiResponseDTO: Decodable {
    let results: [TMDbSearchResultDTO]
}

struct TMDbSearchResultDTO: Decodable {
    let id: Int
    let mediaType: String?
    let title: String?
    let name: String?
    let originalTitle: String?
    let originalName: String?
    let overview: String?
    let posterPath: String?
    let backdropPath: String?
    let releaseDate: String?
    let firstAirDate: String?

    enum CodingKeys: String, CodingKey {
        case id
        case mediaType = "media_type"
        case title
        case name
        case originalTitle = "original_title"
        case originalName = "original_name"
        case overview
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case releaseDate = "release_date"
        case firstAirDate = "first_air_date"
    }
}

struct TMDbGenreDTO: Decodable {
    let id: Int
    let name: String
}

struct TMDbMovieDetailsDTO: Decodable {
    let id: Int
    let title: String
    let originalTitle: String?
    let overview: String?
    let releaseDate: String?
    let runtime: Int?
    let genres: [TMDbGenreDTO]
    let posterPath: String?
    let backdropPath: String?

    enum CodingKeys: String, CodingKey {
        case id, title, overview, runtime, genres
        case originalTitle = "original_title"
        case releaseDate = "release_date"
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
    }
}

struct TMDbCreatedByDTO: Decodable {
    let id: Int
    let name: String
    let profilePath: String?

    enum CodingKeys: String, CodingKey {
        case id, name
        case profilePath = "profile_path"
    }
}

struct TMDbTVDetailsDTO: Decodable {
    let id: Int
    let name: String
    let originalName: String?
    let overview: String?
    let firstAirDate: String?
    let numberOfSeasons: Int?
    let numberOfEpisodes: Int?
    let genres: [TMDbGenreDTO]
    let posterPath: String?
    let backdropPath: String?
    let createdBy: [TMDbCreatedByDTO]

    enum CodingKeys: String, CodingKey {
        case id, name, overview, genres
        case originalName = "original_name"
        case firstAirDate = "first_air_date"
        case numberOfSeasons = "number_of_seasons"
        case numberOfEpisodes = "number_of_episodes"
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case createdBy = "created_by"
    }
}

struct TMDbCastMemberDTO: Decodable {
    let id: Int
    let name: String
    let profilePath: String?
    let character: String?
    let order: Int?

    enum CodingKeys: String, CodingKey {
        case id, name, character, order
        case profilePath = "profile_path"
    }
}

struct TMDbCrewMemberDTO: Decodable {
    let id: Int
    let name: String
    let profilePath: String?
    let job: String?
    let department: String?

    enum CodingKeys: String, CodingKey {
        case id, name, job, department
        case profilePath = "profile_path"
    }
}

struct TMDbCreditsResponseDTO: Decodable {
    let cast: [TMDbCastMemberDTO]
    let crew: [TMDbCrewMemberDTO]
}

/// `/tv/{id}/aggregate_credits`: el reparto trae `roles` en vez de un
/// único `character`, porque agrega apariciones a lo largo de temporadas.
struct TMDbAggregateCastMemberDTO: Decodable {
    let id: Int
    let name: String
    let profilePath: String?
    let order: Int?
    let roles: [TMDbAggregateRoleDTO]

    enum CodingKeys: String, CodingKey {
        case id, name, order, roles
        case profilePath = "profile_path"
    }
}

struct TMDbAggregateRoleDTO: Decodable {
    let character: String?
}

struct TMDbAggregateCreditsResponseDTO: Decodable {
    let cast: [TMDbAggregateCastMemberDTO]
    let crew: [TMDbCrewMemberDTO]
}

// MARK: - Modelos normalizados internos

struct MediaSearchResult: Identifiable, Hashable {
    let id: String // "movie-123" o "tv-456"
    let tmdbId: Int
    let mediaType: MediaType
    let title: String
    let originalTitle: String?
    let overview: String?
    let posterPath: String?
    let backdropPath: String?
    let releaseDate: String?
    let year: Int?
}

struct PersonDTO: Identifiable, Hashable {
    let tmdbId: Int
    var id: Int { tmdbId }
    let name: String
    let profilePath: String?
    let role: PersonRole
    let character: String?
    let castOrder: Int?
    let job: String?
    let department: String?
}

struct MediaDetails {
    let tmdbId: Int
    let mediaType: MediaType
    let title: String
    let originalTitle: String?
    let overview: String?
    let releaseDate: Date?
    let year: Int?
    let posterPath: String?
    let backdropPath: String?
    let runtimeMinutes: Int?
    let numberOfSeasons: Int?
    let numberOfEpisodes: Int?
    let genres: [TMDbGenreDTO]
    let creatorsOrDirectors: [PersonDTO]
    let cast: [PersonDTO]
}

// MARK: - Helpers de parseo de fecha "yyyy-MM-dd"

enum TMDbDateParsing {
    static func date(from string: String?) -> Date? {
        guard let string, !string.isEmpty else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(identifier: "UTC")
        return formatter.date(from: string)
    }

    static func year(from string: String?) -> Int? {
        guard let date = date(from: string) else { return nil }
        return Calendar.current.component(.year, from: date)
    }
}
