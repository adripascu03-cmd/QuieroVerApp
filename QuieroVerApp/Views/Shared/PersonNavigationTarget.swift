import Foundation

/// Valor mínimo para navegar a la ficha de una persona, sin importar
/// de dónde viene el toque (resultado de búsqueda, favoritos, reparto
/// o dirección de una película/serie). Se usa con
/// `.navigationDestination(item:)`, local a cada vista — no depende de
/// qué NavigationStack ancestro esté activo.
struct PersonNavigationTarget: Identifiable, Hashable {
    let personId: Int
    let name: String
    let profilePath: String?

    var id: Int { personId }
}

extension PersonNavigationTarget {
    init(_ person: PersonDisplayItem) {
        personId = person.id
        name = person.name
        profilePath = person.profilePath
    }

    init(_ person: PersonSearchResult) {
        personId = person.tmdbId
        name = person.name
        profilePath = person.profilePath
    }

    init(_ favorite: FavoritePerson) {
        personId = favorite.tmdbId
        name = favorite.name
        profilePath = favorite.profilePath
    }
}
