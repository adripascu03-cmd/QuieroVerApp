import Foundation

/// Lee la API key de TMDb. Primero intenta `Info.plist` (inyectada desde
/// `Secrets.xcconfig` vía el build setting `INFOPLIST_FILE`). Si por lo
/// que sea no llega, recurre a `Secrets.plist`, un recurso local embebido
/// en el bundle (ver `Secrets.example.plist`). Nunca hardcodear la clave.
struct TMDbConfig {
    private static let placeholder = "TU_API_KEY_AQUI"

    static func apiKey() throws -> String {
        logDiagnostics()

        if let key = infoPlistValue(forKey: "TMDBAPIKey"), isValid(key) {
            return key
        }

        if let key = secretsPlistValue(), isValid(key) {
            return key
        }

        throw TMDbError.missingAPIKey
    }

    private static func isValid(_ key: String) -> Bool {
        !key.isEmpty && key != placeholder
    }

    private static func infoPlistValue(forKey key: String) -> String? {
        Bundle.main.object(forInfoDictionaryKey: key) as? String
    }

    private static func secretsPlistValue() -> String? {
        guard
            let url = Bundle.main.url(forResource: "Secrets", withExtension: "plist"),
            let data = try? Data(contentsOf: url),
            let plist = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any]
        else {
            return nil
        }
        return plist["TMDB_API_KEY"] as? String
    }

    /// Diagnóstico seguro para depurar la cadena xcconfig -> Info.plist ->
    /// Bundle: nunca imprime la clave completa, solo si existe, su origen
    /// y su longitud. Solo corre en builds de depuración.
    private static func logDiagnostics() {
        #if DEBUG
        func describe(_ value: String?) -> String {
            guard let value else { return "ausente" }
            if value == placeholder { return "presente pero sigue siendo el placeholder" }
            return "presente (\(value.count) caracteres)"
        }

        print("[TMDbConfig] Info.plist[\"TMDBAPIKey\"]: \(describe(infoPlistValue(forKey: "TMDBAPIKey")))")
        print("[TMDbConfig] Info.plist[\"TMDB_API_KEY\"]: \(describe(infoPlistValue(forKey: "TMDB_API_KEY")))")
        print("[TMDbConfig] Secrets.plist[\"TMDB_API_KEY\"]: \(describe(secretsPlistValue()))")
        #endif
    }
}
