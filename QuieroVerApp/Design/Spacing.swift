import Foundation

/// Escala de espaciado consistente para toda la app.
enum Spacing {
    static let xxs: CGFloat = 4
    static let xs: CGFloat = 8
    static let sm: CGFloat = 12
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48

    /// Margen horizontal estándar de pantalla completa (fichas, listas).
    static let screenMargin: CGFloat = 20

    /// Espacio entre columnas del grid de posters. Deliberadamente más
    /// ajustado que `screenMargin` para que el margen exterior se lea
    /// como el borde "contenedor" y el hueco entre tarjetas como algo
    /// más íntimo — la retícula se siente más intencional así.
    static let gridGutter: CGFloat = 14
}
