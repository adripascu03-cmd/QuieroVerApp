import UIKit

/// Hápticos suaves y puntuales: añadir a Quiero ver, marcar como vista,
/// y el "tic" de selección al recorrer el deck.
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

    /// "Tic" de selección tipo rueda del reloj de iOS, para cuando el
    /// deck cambia de película activa al desplazarlo. El generador es
    /// estático y persistente (no uno nuevo por evento) para que el
    /// motor háptico responda con precisión.
    private static let selectionGenerator = UISelectionFeedbackGenerator()

    static func selection() {
        selectionGenerator.selectionChanged()
        selectionGenerator.prepare()
    }
}
