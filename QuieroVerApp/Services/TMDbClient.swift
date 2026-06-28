import Foundation

/// Cliente de TMDb: búsqueda multi y detalle (con créditos) de
/// películas y series. `language=es-ES` por defecto, con fallback a
/// `en-US` solo para la sinopsis si llega vacía.
final class TMDbClient {
    static let shared = TMDbClient()

    private let baseURL = "https://api.themoviedb.org/3"
    private let session: URLSession
    private let decoder: JSONDecoder

    init(session: URLSession = .shared) {
        self.session = session
        self.decoder = JSONDecoder()
    }

    // MARK: - Búsqueda

    func searchMedia(query: String) async throws -> [MediaSearchResult] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }

        let response: TMDbSearchMultiResponseDTO = try await get(
            path: "/search/multi",
            query: [URLQueryItem(name: "query", value: trimmed)]
        )

        return response.results.compactMap(normalize)
    }

    private func normalize(_ dto: TMDbSearchResultDTO) -> MediaSearchResult? {
        guard let mediaTypeRaw = dto.mediaType, let mediaType = MediaType(rawValue: mediaTypeRaw) else {
            return nil // ignora "person" y otros tipos no soportados
        }

        let title = mediaType == .movie ? (dto.title ?? "") : (dto.name ?? "")
        guard !title.isEmpty else { return nil }

        let originalTitle = mediaType == .movie ? dto.originalTitle : dto.originalName
        let releaseDate = mediaType == .movie ? dto.releaseDate : dto.firstAirDate

        return MediaSearchResult(
            id: "\(mediaType.rawValue)-\(dto.id)",
            tmdbId: dto.id,
            mediaType: mediaType,
            title: title,
            originalTitle: originalTitle,
            overview: dto.overview,
            posterPath: dto.posterPath,
            backdropPath: dto.backdropPath,
            releaseDate: releaseDate,
            year: TMDbDateParsing.year(from: releaseDate)
        )
    }

    // MARK: - Detalle

    func fetchDetails(for result: MediaSearchResult) async throws -> MediaDetails {
        try await fetchDetails(tmdbId: result.tmdbId, mediaType: result.mediaType)
    }

    func fetchDetails(tmdbId: Int, mediaType: MediaType) async throws -> MediaDetails {
        switch mediaType {
        case .movie: return try await fetchMovieDetails(id: tmdbId)
        case .tv: return try await fetchTVDetails(id: tmdbId)
        }
    }

    func fetchMovieDetails(id: Int) async throws -> MediaDetails {
        async let detailsTask: TMDbMovieDetailsDTO = get(path: "/movie/\(id)")
        async let creditsTask: TMDbCreditsResponseDTO = get(path: "/movie/\(id)/credits")

        let details = try await detailsTask
        let credits = try await creditsTask

        var overview = (details.overview?.isEmpty == false) ? details.overview : nil
        if overview == nil {
            overview = await overviewFallback(path: "/movie/\(id)")
        }

        let directors: [PersonDTO] = credits.crew
            .filter { $0.job == "Director" }
            .map {
                PersonDTO(
                    tmdbId: $0.id, name: $0.name, profilePath: $0.profilePath,
                    role: .director, character: nil, castOrder: nil,
                    job: $0.job, department: $0.department
                )
            }

        let cast: [PersonDTO] = credits.cast
            .sorted { ($0.order ?? .max) < ($1.order ?? .max) }
            .prefix(12)
            .map {
                PersonDTO(
                    tmdbId: $0.id, name: $0.name, profilePath: $0.profilePath,
                    role: .cast, character: $0.character, castOrder: $0.order,
                    job: nil, department: nil
                )
            }

        return MediaDetails(
            tmdbId: details.id,
            mediaType: .movie,
            title: details.title,
            originalTitle: details.originalTitle,
            overview: overview,
            releaseDate: TMDbDateParsing.date(from: details.releaseDate),
            year: TMDbDateParsing.year(from: details.releaseDate),
            posterPath: details.posterPath,
            backdropPath: details.backdropPath,
            runtimeMinutes: details.runtime,
            numberOfSeasons: nil,
            numberOfEpisodes: nil,
            genres: details.genres,
            creatorsOrDirectors: directors,
            cast: cast
        )
    }

    func fetchTVDetails(id: Int) async throws -> MediaDetails {
        async let detailsTask: TMDbTVDetailsDTO = get(path: "/tv/\(id)")
        async let creditsTask: TMDbAggregateCreditsResponseDTO = get(path: "/tv/\(id)/aggregate_credits")

        let details = try await detailsTask
        let credits = try await creditsTask

        var overview = (details.overview?.isEmpty == false) ? details.overview : nil
        if overview == nil {
            overview = await overviewFallback(path: "/tv/\(id)")
        }

        var creators: [PersonDTO] = details.createdBy.map {
            PersonDTO(
                tmdbId: $0.id, name: $0.name, profilePath: $0.profilePath,
                role: .creator, character: nil, castOrder: nil,
                job: nil, department: nil
            )
        }

        if creators.isEmpty {
            // Fallback si `created_by` viene vacío: equipo de producción relevante.
            creators = credits.crew
                .filter { $0.job == "Executive Producer" }
                .prefix(3)
                .map {
                    PersonDTO(
                        tmdbId: $0.id, name: $0.name, profilePath: $0.profilePath,
                        role: .creator, character: nil, castOrder: nil,
                        job: $0.job, department: $0.department
                    )
                }
        }

        let cast: [PersonDTO] = credits.cast
            .sorted { ($0.order ?? .max) < ($1.order ?? .max) }
            .prefix(12)
            .map {
                PersonDTO(
                    tmdbId: $0.id, name: $0.name, profilePath: $0.profilePath,
                    role: .cast, character: $0.roles.first?.character, castOrder: $0.order,
                    job: nil, department: nil
                )
            }

        return MediaDetails(
            tmdbId: details.id,
            mediaType: .tv,
            title: details.name,
            originalTitle: details.originalName,
            overview: overview,
            releaseDate: TMDbDateParsing.date(from: details.firstAirDate),
            year: TMDbDateParsing.year(from: details.firstAirDate),
            posterPath: details.posterPath,
            backdropPath: details.backdropPath,
            runtimeMinutes: nil,
            numberOfSeasons: details.numberOfSeasons,
            numberOfEpisodes: details.numberOfEpisodes,
            genres: details.genres,
            creatorsOrDirectors: creators,
            cast: cast
        )
    }

    /// Reintenta solo la sinopsis en inglés si la versión es-ES llegó vacía.
    private func overviewFallback(path: String) async -> String? {
        struct OverviewDTO: Decodable { let overview: String? }
        guard let dto: OverviewDTO = try? await get(path: path, query: [], language: "en-US") else {
            return nil
        }
        return (dto.overview?.isEmpty == false) ? dto.overview : nil
    }

    // MARK: - Red

    private func get<T: Decodable>(path: String, query: [URLQueryItem] = [], language: String = "es-ES") async throws -> T {
        let apiKey = try TMDbConfig.apiKey()

        guard var components = URLComponents(string: baseURL + path) else {
            throw TMDbError.invalidURL
        }
        components.queryItems = [
            URLQueryItem(name: "api_key", value: apiKey),
            URLQueryItem(name: "language", value: language)
        ] + query

        guard let url = components.url else {
            throw TMDbError.invalidURL
        }

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(from: url)
        } catch let urlError as URLError {
            if urlError.code == .notConnectedToInternet
                || urlError.code == .networkConnectionLost
                || urlError.code == .timedOut
                || urlError.code == .cannotConnectToHost
                || urlError.code == .dataNotAllowed {
                throw TMDbError.noConnection
            }
            throw TMDbError.requestFailed(statusCode: urlError.errorCode)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw TMDbError.invalidResponse
        }
        guard (200..<300).contains(httpResponse.statusCode) else {
            throw TMDbError.requestFailed(statusCode: httpResponse.statusCode)
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw TMDbError.decodingFailed
        }
    }
}
