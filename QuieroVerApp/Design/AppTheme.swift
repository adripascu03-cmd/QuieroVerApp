import SwiftUI

/// Estilo visual compartido: superficies, esquinas y sombras suaves.
/// La app usa colores y tipografía del sistema; este tema solo afina
/// detalles (radios, opacidades de sombra) para una sensación calmada.
enum AppTheme {
    static let posterCornerRadius: CGFloat = 16
    static let cardCornerRadius: CGFloat = 20
    static let sheetCornerRadius: CGFloat = 28

    static let gridShadowRadius: CGFloat = 8
    static let gridShadowOpacity: Double = 0.14
    static let gridShadowY: CGFloat = 4

    static let detailShadowRadius: CGFloat = 16
    static let detailShadowOpacity: Double = 0.22
    static let detailShadowY: CGFloat = 10

    static var posterPlaceholderGradient: LinearGradient {
        LinearGradient(
            colors: [Color(.systemGray5), Color(.systemGray4)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    /// Degradado del backdrop hacia el fondo del sistema, para que la
    /// cabecera funda con el contenido en vez de cortar en seco.
    static func backdropFade(into background: Color) -> LinearGradient {
        LinearGradient(
            stops: [
                .init(color: .black.opacity(0.05), location: 0),
                .init(color: .black.opacity(0.25), location: 0.6),
                .init(color: background, location: 1)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

extension View {
    /// Sombra suave para posters en grid: casi planos, profundidad mínima.
    func gridPosterShadow() -> some View {
        shadow(
            color: .black.opacity(AppTheme.gridShadowOpacity),
            radius: AppTheme.gridShadowRadius,
            x: 0,
            y: AppTheme.gridShadowY
        )
    }

    /// Sombra más presente para el poster grande de la ficha de detalle.
    func detailPosterShadow() -> some View {
        shadow(
            color: .black.opacity(AppTheme.detailShadowOpacity),
            radius: AppTheme.detailShadowRadius,
            x: 0,
            y: AppTheme.detailShadowY
        )
    }

    /// Borde sutil tipo "glass" para tarjetas sobre material translúcido.
    func glassBorder(cornerRadius: CGFloat) -> some View {
        overlay(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .strokeBorder(Color.primary.opacity(0.08), lineWidth: 1)
        )
    }
}
