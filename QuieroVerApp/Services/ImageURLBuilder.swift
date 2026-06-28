import Foundation

/// Construye URLs de imágenes de TMDb a partir de paths relativos.
/// TMDb no devuelve URLs completas: hay que componerlas con un tamaño.
struct ImageURLBuilder {
    static let baseURL = "https://image.tmdb.org/t/p/"

    static func posterURL(path: String?, size: String = "w500") -> URL? {
        url(path: path, size: size)
    }

    static func backdropURL(path: String?, size: String = "w1280") -> URL? {
        url(path: path, size: size)
    }

    static func profileURL(path: String?, size: String = "w185") -> URL? {
        url(path: path, size: size)
    }

    private static func url(path: String?, size: String) -> URL? {
        guard let path, !path.isEmpty else { return nil }
        return URL(string: baseURL + size + path)
    }
}
