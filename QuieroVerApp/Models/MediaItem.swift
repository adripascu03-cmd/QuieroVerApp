import Foundation
import SwiftData

/// Item de la biblioteca: una película o serie, con sus datos objetivos
/// (TMDb) y sus datos personales (estado, nota, impacto).
@Model
final class MediaItem {
    @Attribute(.unique) var uniqueKey: String

    var tmdbId: Int
    var mediaTypeRaw: String

    var title: String
    var originalTitle: String?
    var overview: String?
    var releaseDate: Date?
    var year: Int?

    var posterPath: String?
    var backdropPath: String?

    var runtimeMinutes: Int?
    var numberOfSeasons: Int?
    var numberOfEpisodes: Int?
    var voteAverage: Double?

    var statusRaw: String
    var addedAt: Date
    var watchedAt: Date?

    var personalImpact: Double?
    var personalNote: String?
    var reasonAdded: String?

    var createdAt: Date
    var updatedAt: Date

    @Relationship(deleteRule: .cascade)
    var genres: [Genre] = []

    @Relationship(deleteRule: .cascade)
    var people: [PersonCredit] = []

    init(
        tmdbId: Int,
        mediaType: MediaType,
        title: String,
        originalTitle: String? = nil,
        overview: String? = nil,
        releaseDate: Date? = nil,
        year: Int? = nil,
        posterPath: String? = nil,
        backdropPath: String? = nil,
        runtimeMinutes: Int? = nil,
        numberOfSeasons: Int? = nil,
        numberOfEpisodes: Int? = nil,
        voteAverage: Double? = nil,
        status: WatchStatus = .wantToWatch,
        reasonAdded: String? = nil,
        genres: [Genre] = [],
        people: [PersonCredit] = []
    ) {
        self.uniqueKey = "\(mediaType.rawValue)-\(tmdbId)"
        self.tmdbId = tmdbId
        self.mediaTypeRaw = mediaType.rawValue
        self.title = title
        self.originalTitle = originalTitle
        self.overview = overview
        self.releaseDate = releaseDate
        self.year = year
        self.posterPath = posterPath
        self.backdropPath = backdropPath
        self.runtimeMinutes = runtimeMinutes
        self.numberOfSeasons = numberOfSeasons
        self.numberOfEpisodes = numberOfEpisodes
        self.voteAverage = voteAverage
        self.statusRaw = status.rawValue
        self.addedAt = .now
        self.watchedAt = nil
        self.personalImpact = nil
        self.personalNote = nil
        self.reasonAdded = reasonAdded
        self.createdAt = .now
        self.updatedAt = .now
        self.genres = genres
        self.people = people
    }

    var mediaType: MediaType {
        get { MediaType(rawValue: mediaTypeRaw) ?? .movie }
        set { mediaTypeRaw = newValue.rawValue }
    }

    var status: WatchStatus {
        get { WatchStatus(rawValue: statusRaw) ?? .wantToWatch }
        set { statusRaw = newValue.rawValue }
    }

    var displayTitle: String { title }

    var displayYear: String {
        if let year { return String(year) }
        return ""
    }

    /// Director (película) o creadores (serie), ordenados por aparición.
    var directorsOrCreators: [PersonCredit] {
        let role: PersonRole = mediaType == .movie ? .director : .creator
        return people.filter { $0.role == role }
    }

    /// Reparto principal ordenado por `castOrder`.
    var cast: [PersonCredit] {
        people
            .filter { $0.role == .cast }
            .sorted { ($0.castOrder ?? .max) < ($1.castOrder ?? .max) }
    }

    /// Label visible para la sección de dirección/creación.
    var creditSectionLabel: String {
        mediaType == .movie ? "Dirección" : "Creación"
    }

    func markAsWatched(impact: Double?, note: String?, watchedAt: Date) {
        self.status = .watched
        self.watchedAt = watchedAt
        self.personalImpact = impact
        self.personalNote = note
        self.updatedAt = .now
    }

    func moveBackToWantToWatch() {
        self.status = .wantToWatch
        self.watchedAt = nil
        self.personalImpact = nil
        self.personalNote = nil
        self.updatedAt = .now
    }
}
