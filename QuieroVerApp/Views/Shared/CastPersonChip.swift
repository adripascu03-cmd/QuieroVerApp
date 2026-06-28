import SwiftUI

/// Foto circular de una persona, con iniciales como placeholder si no
/// hay foto o la carga falla.
struct PersonAvatar: View {
    let person: PersonDisplayItem
    var size: CGFloat = 64

    var body: some View {
        VStack(spacing: 4) {
            avatarImage
                .frame(width: size, height: size)
                .clipShape(Circle())

            Text(person.name)
                .font(.caption2.weight(.medium))
                .lineLimit(1)
                .frame(width: size + 20)

            if let character = person.character, !character.isEmpty {
                Text(character)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .frame(width: size + 20)
            }
        }
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
