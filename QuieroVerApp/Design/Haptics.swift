import UIKit

/// Hápticos suaves y puntuales: añadir a Quiero ver, completar el slide,
/// guardar en Vistas. No se usan en ningún otro punto de la app.
enum Haptics {
    static func light() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    static func soft() {
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
    }

    static func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
}
