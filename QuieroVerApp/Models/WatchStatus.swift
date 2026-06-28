import Foundation

enum WatchStatus: String, Codable, CaseIterable, Sendable {
    case wantToWatch
    case watched

    var displayName: String {
        switch self {
        case .wantToWatch: return "Quiero ver"
        case .watched: return "Vista"
        }
    }
}
