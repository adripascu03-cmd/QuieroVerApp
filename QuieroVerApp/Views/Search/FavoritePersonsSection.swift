import SwiftUI
import SwiftData

/// Acceso rápido a personas favoritas, visible solo en el estado idle
/// de la búsqueda (antes de escribir nada). Discreto a propósito: si no
/// hay favoritos, no ocupa ningún espacio.
struct FavoritePersonsSection: View {
    var onSelect: (PersonNavigationTarget) -> Void

    @Query(sort: [SortDescriptor(\FavoritePerson.createdAt, order: .reverse)])
    private var favorites: [FavoritePerson]

    var body: some View {
        if !favorites.isEmpty {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text("Personas favoritas")
                    .font(.headline)
                    .padding(.horizontal, Spacing.screenMargin)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: Spacing.md) {
                        ForEach(favorites) { favorite in
                            Button {
                                onSelect(PersonNavigationTarget(favorite))
                            } label: {
                                VStack(spacing: 6) {
                                    PersonAvatarImage(person: PersonDisplayItem(favorite), size: 64)
                                    Text(favorite.name)
                                        .font(.caption2.weight(.medium))
                                        .foregroundStyle(.primary)
                                        .lineLimit(1)
                                        .frame(width: 84)
                                }
                            }
                            .buttonStyle(PressableButtonStyle(scale: 0.95))
                        }
                    }
                    .padding(.horizontal, Spacing.screenMargin)
                }
            }
            .padding(.top, Spacing.lg)
        }
    }
}
