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
    // Solo presentes cuando media_type == "person"
    let profilePath: String?
    let knownForDepartment: String?
    let gender: Int?
    let knownFor: [TMDbKnownForDTO]?

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
        case profilePath = "profile_path"
        case knownForDepartment = "known_for_department"
        case gender
        case knownFor = "known_for"
    }
}

/// Una de las obras dentro de `known_for` de un resultado de persona.
struct TMDbKnownForDTO: Decodable {
    let title: String?
    let name: String?

    var displayTitle: String? { title ?? name }
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

// MARK: - DTOs de ficha de persona

struct TMDbPersonDetailsDTO: Decodable {
    let id: Int
    let name: String
    let biography: String?
    let birthday: String?
    let deathday: String?
    let placeOfBirth: String?
    let knownForDepartment: String?
    let profilePath: String?

    enum CodingKeys: String, CodingKey {
        case id, name, biography, birthday, deathday
        case placeOfBirth = "place_of_birth"
        case knownForDepartment = "known_for_department"
        case profilePath = "profile_path"
    }
}

/// Una entrada de `/person/{id}/combined_credits`: una película o
/// serie en la que la persona participó, como reparto o como equipo.
struct TMDbPersonCreditDTO: Decodable {
    let id: Int
    let mediaType: String?
    let title: String?
    let name: String?
    let posterPath: String?
    let character: String?
    let job: String?
    let releaseDate: String?
    let firstAirDate: String?

    enum CodingKeys: String, CodingKey {
        case id, character, job
        case mediaType = "media_type"
        case title, name
        case posterPath = "poster_path"
        case releaseDate = "release_date"
        case firstAirDate = "first_air_date"
    }
}

struct TMDbCombinedCreditsResponseDTO: Decodable {
    let cast: [TMDbPersonCreditDTO]
    let crew: [TMDbPersonCreditDTO]
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

/// Resultado de búsqueda de tipo persona (actor, actriz, director...).
struct PersonSearchResult: Identifiable, Hashable {
    let id: String // "person-123"
    let tmdbId: Int
    let name: String
    let profilePath: String?
    let knownForDepartment: String?
    let gender: Int?
    let knownForTitles: [String]

    /// "Actor" / "Actriz" / "Director" / "Conocido por X", lo más
    /// específico que TMDb nos deje inferir sin pasarnos de listos.
    var roleLabel: String {
        switch knownForDepartment {
        case "Acting":
            return gender == 1 ? "Actriz" : "Actor"
        case "Directing":
            return "Director"
        case "Writing":
            return "Guionista"
        case "Production":
            return "Producción"
        default:
            if let first = knownForTitles.first {
                return "Conocido por \(first)"
            }
            return "Persona"
        }
    }
}

/// Combina resultados de película/serie y de persona en una sola lista
/// para la pantalla de búsqueda.
enum SearchResultItem: Identifiable, Hashable {
    case media(MediaSearchResult)
    case person(PersonSearchResult)

    var id: String {
        switch self {
        case .media(let result): return result.id
        case .person(let person): return person.id
        }
    }
}

/// Una obra en la filmografía de una persona (como reparto o equipo).
struct PersonCreditItem: Identifiable, Hashable {
    let id: String
    let tmdbId: Int
    let mediaType: MediaType
    let title: String
    let posterPath: String?
    let roleDescription: String?
    let year: Int?
}

struct PersonDetails {
    let tmdbId: Int
    let name: String
    let biography: String?
    let birthday: Date?
    let deathday: Date?
    let placeOfBirth: String?
    let knownForDepartment: String?
    let profilePath: String?
    let filmography: [PersonCreditItem]

    var roleLabel: String {
        switch knownForDepartment {
        case "Acting": return "Actor / actriz"
        case "Directing": return "Director"
        case "Writing": return "Guionista"
        case "Production": return "Producción"
        default: return knownForDepartment ?? ""
        }
    }

    var filmographyTitle: String {
        knownForDepartment == "Directing" ? "Dirección" : "Filmografía"
    }
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
