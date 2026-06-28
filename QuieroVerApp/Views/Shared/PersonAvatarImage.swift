import SwiftUI

/// Foto circular atómica de una persona, con iniciales como placeholder
/// si no hay foto o la carga falla. Pieza reusable compartida por
/// `CastPersonChip` y `DirectorBadge` — y, en una fase futura, por la
/// ficha propia de actor/director, sin duplicar la carga de imagen.
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
            .fill(Color(.systemGray4))
            .overlay(
                Text(initials)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            )
    }

    private var initials: String {
        let letters = person.name.split(separator: " ").prefix(2).compactMap { $0.first }
        return String(letters).uppercased()
    }
}
