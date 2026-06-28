import Foundation

enum TMDbError: Error, LocalizedError {
    case invalidURL
    case missingAPIKey
    case invalidResponse
    case requestFailed(statusCode: Int)
    case decodingFailed
    case noConnection

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "No se ha podido construir la petición."
        case .missingAPIKey:
            return "Falta configurar la API key de TMDb en Secrets.xcconfig."
        case .invalidResponse:
            return "Respuesta inválida del servidor."
        case .requestFailed:
            return "No se ha podido conectar. Revisa tu conexión e inténtalo de nuevo."
        case .decodingFailed:
            return "No se han podido leer los datos recibidos."
        case .noConnection:
            return "No se ha podido conectar. Revisa tu conexión e inténtalo de nuevo."
        }
    }
}
