import SwiftUI

/// Foto circular atómica de una persona, con iniciales como placeholder
/// si no hay foto o la carga falla. Pieza reusable compartida por
/// `CastPersonChip`, `DirectorSection` y `DirectorsSection`, sin
/// duplicar la carga de imagen.
struct PersonAvatarImage: View {
    let person: PersonDisplayItem
    var size: CGFloat = 64

    var body: some View {
        avatarImage
            .frame(width: size, height: size)
            .clipShape(Circle())
    }

    @ViewBuilder
    private var avatarImage: some View {
        if let url = ImageURLBuilder.profileURL(path: person.profilePath) {
            AsyncImage(url: url) { phase in
                if case .success(let image) = phase {
                    image.resizable().aspectRatio(contentMode: .fill)
                } else {
                    initialsCircle
                }
            }
        } else {
            initialsCircle
        }
    }

    private var initialsCircle: some View {
        Circle()
            .fill(
                LinearGradient(
                    colors: [Color(.systemGray4), Color(.systemGray5)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(Circle().strokeBorder(.white.opacity(0.25), lineWidth: 1))
            .overlay {
                if initials.isEmpty {
                    Image(systemName: "person.fill")
                        .foregroundStyle(.secondary)
                        .font(.system(size: size * 0.42))
                } else {
                    Text(initials)
                        .font(.system(size: size * 0.34, weight: .semibold))
                        .foregroundStyle(.secondary)
                }
            }
    }

    private var initials: String {
        let letters = person.name.split(separator: " ").prefix(2).compactMap { $0.first }
        return String(letters).uppercased()
    }
}
