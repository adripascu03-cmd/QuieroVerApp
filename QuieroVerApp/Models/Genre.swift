import SwiftData

@Model
final class Genre {
    var tmdbId: Int
    var name: String

    init(tmdbId: Int, name: String) {
        self.tmdbId = tmdbId
        self.name = name
    }
}
