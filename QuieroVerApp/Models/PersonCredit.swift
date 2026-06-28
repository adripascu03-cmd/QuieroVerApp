import SwiftData

/// Representa a una persona vinculada a un MediaItem: actor/actriz del
/// reparto, director de película o creador/a de serie.
@Model
final class PersonCredit {
    var tmdbId: Int
    var name: String
    var profilePath: String?
    var roleRaw: String

    // Reparto
    var character: String?
    var castOrder: Int?

    // Dirección / creación / equipo técnico
    var job: String?
    var department: String?

    var role: PersonRole {
        get { PersonRole(rawValue: roleRaw) ?? .cast }
        set { roleRaw = newValue.rawValue }
    }

    init(
        tmdbId: Int,
        name: String,
        profilePath: String?,
        role: PersonRole,
        character: String? = nil,
        castOrder: Int? = nil,
        job: String? = nil,
        department: String? = nil
    ) {
        self.tmdbId = tmdbId
        self.name = name
        self.profilePath = profilePath
        self.roleRaw = role.rawValue
        self.character = character
        self.castOrder = castOrder
        self.job = job
        self.department = department
    }
}
