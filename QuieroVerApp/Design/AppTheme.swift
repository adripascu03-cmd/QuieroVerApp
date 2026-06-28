import SwiftUI

/// Estilo visual compartido: superficies, esquinas y sombras suaves.
/// La app usa colores y tipografía del sistema; este tema solo afina
/// detalles (radios, opacidades de sombra) para una sensación calmada.
enum AppTheme {
    static let posterCornerRadius: CGFloat = 14
    static let cardCornerRadius: CGFloat = 20
    static let sheetCornerRadius: CGFloat = 28

    static let gridShadowRadius: CGFloat = 6
    static let gridShadowOpacity: Double = 0.12
    static let gridShadowY: CGFloat = 3

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
}
