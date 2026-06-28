import SwiftData

/// Centraliza la escritura en SwiftData al añadir contenido desde TMDb,
/// evitando duplicados por `uniqueKey` (mediaType-tmdbId).
enum LibraryWriter {
    static func addToWantToWatch(details: MediaDetails, context: ModelContext) -> MediaItem {
        let targetKey = "\(details.mediaType.rawValue)-\(details.tmdbId)"
        let descriptor = FetchDescriptor<MediaItem>()

        if let allItems = try? context.fetch(descriptor),
           let existing = allItems.first(where: { $0.uniqueKey == targetKey }) {
            return existing
        }

        let genres = details.genres.map { Genre(tmdbId: $0.id, name: $0.name) }
        let people = (details.creatorsOrDirectors + details.cast).map { person in
            PersonCredit(
                tmdbId: person.tmdbId,
                name: person.name,
                profilePath: person.profilePath,
                role: person.role,
                character: person.character,
                castOrder: person.castOrder,
                job: person.job,
                department: person.department
            )
        }

        let item = MediaItem(
            tmdbId: details.tmdbId,
            mediaType: details.mediaType,
            title: details.title,
            originalTitle: details.originalTitle,
            overview: details.overview,
            releaseDate: details.releaseDate,
            year: details.year,
            posterPath: details.posterPath,
            backdropPath: details.backdropPath,
            runtimeMinutes: details.runtimeMinutes,
            numberOfSeasons: details.numberOfSeasons,
            numberOfEpisodes: details.numberOfEpisodes,
            genres: genres,
            people: people
        )
        context.insert(item)
        return item
    }
}
