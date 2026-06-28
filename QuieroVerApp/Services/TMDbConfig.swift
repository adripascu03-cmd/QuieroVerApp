import Foundation

/// Lee la API key de TMDb inyectada vía Secrets.xcconfig -> Info.plist.
/// Nunca hardcodear la clave en el código fuente.
struct TMDbConfig {
    static func apiKey() throws -> String {
        guard
            let key = Bundle.main.object(forInfoDictionaryKey: "TMDBAPIKey") as? String,
            !key.isEmpty,
            key != "TU_API_KEY_AQUI"
        else {
            throw TMDbError.missingAPIKey
        }
        return key
    }
}
