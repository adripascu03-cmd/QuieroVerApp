import Foundation
import SwiftData

/// Persona marcada como favorita (actor, actriz, director, creador...).
/// Modelo independiente, sin relación con `MediaItem`: una persona
/// favorita no depende de tener ninguna película/serie guardada.
@Model
final class FavoritePerson {
    @Attribute(.unique) var tmdbId: Int
    var name: String
    var profilePath: String?
    var knownForDepartment: String?
    var biography: String?
    var createdAt: Date

    init(
        tmdbId: Int,
        name: String,
        profilePath: String? = nil,
        knownForDepartment: String? = nil,
        biography: String? = nil
    ) {
        self.tmdbId = tmdbId
        self.name = name
        self.profilePath = profilePath
        self.knownForDepartment = knownForDepartment
        self.biography = biography
        self.createdAt = .now
    }
}
