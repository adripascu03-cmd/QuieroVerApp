import Foundation

enum MediaType: String, Codable, CaseIterable, Sendable {
    case movie
    case tv

    var displayName: String {
        switch self {
        case .movie: return "Película"
        case .tv: return "Serie"
        }
    }
}
