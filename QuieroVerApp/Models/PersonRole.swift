import Foundation

/// Rol de una persona dentro de un MediaItem: reparto, dirección (película)
/// o creación (serie). `crew` queda como fallback genérico de equipo técnico.
enum PersonRole: String, Codable, Sendable {
    case cast
    case director
    case creator
    case crew

    /// Label visible para agrupar por "Dirección/Creación".
    var creditLabel: String {
        switch self {
        case .director: return "Dirección"
        case .creator: return "Creación"
        default: return ""
        }
    }
}
