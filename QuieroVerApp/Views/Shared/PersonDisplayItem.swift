import Foundation

/// Forma mínima compartida para mostrar una persona (reparto/dirección)
/// venga de TMDb en vivo (`PersonDTO`) o ya persistida (`PersonCredit`).
struct PersonDisplayItem: Identifiable, Hashable {
    let id: Int
    let name: String
    let profilePath: String?
    let character: String?
}

extension PersonDisplayItem {
    init(_ dto: PersonDTO) {
        self.id = dto.tmdbId
        self.name = dto.name
        self.profilePath = dto.profilePath
        self.character = dto.character
    }

    init(_ credit: PersonCredit) {
        self.id = credit.tmdbId
        self.name = credit.name
        self.profilePath = credit.profilePath
        self.character = credit.character
    }
}
