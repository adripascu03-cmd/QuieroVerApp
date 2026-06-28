import SwiftUI

/// Selector de valoración de 1 a 5 estrellas. Sustituye el slider 0-10
/// del flujo anterior en la interacción de marcar como vista — el dato
/// guardado (`MediaItem.personalImpact`) sigue siendo 0-10 internamente
/// (×2), así que no hace falta tocar el modelo ni migrar nada.
struct StarRatingPicker: View {
    @Binding var rating: Int
    var onSelect: ((Int) -> Void)? = nil

    var body: some View {
        HStack(spacing: Spacing.sm) {
            ForEach(1...5, id: \.self) { value in
                Button {
                    rating = value
                    Haptics.light()
                    onSelect?(value)
                } label: {
                    Image(systemName: value <= rating ? "star.fill" : "star")
                        .foregroundStyle(value <= rating ? Color.yellow : Color.secondary.opacity(0.5))
                        .font(.title2)
                }
                .buttonStyle(PressableButtonStyle(scale: 0.85))
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Valoración: \(rating) de 5 estrellas")
    }
}
