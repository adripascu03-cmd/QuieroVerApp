import SwiftUI

/// CTA principal: cápsula de acento sólido con un sutil brillo "glass"
/// en el borde. Claro y legible por delante de cualquier efecto visual.
struct PrimaryGlassButton: View {
    let title: String
    var systemImage: String? = nil
    var isDisabled: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.xs) {
                if let systemImage {
                    Image(systemName: systemImage)
                }
                Text(title)
            }
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .foregroundStyle(.white)
            .background(isDisabled ? Color.secondary : Color.accentColor, in: Capsule())
            .overlay(Capsule().strokeBorder(.white.opacity(0.22), lineWidth: 1))
        }
        .buttonStyle(PressableButtonStyle())
        .disabled(isDisabled)
    }
}
