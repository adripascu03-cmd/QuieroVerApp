import SwiftUI
import SwiftData

struct VistasView: View {
    @Binding var path: NavigationPath

    @Query(
        filter: #Predicate<MediaItem> { $0.statusRaw == "watched" },
        sort: [SortDescriptor(\MediaItem.watchedAt, order: .reverse)]
    )
    private var allItems: [MediaItem]

    @State private var filter: LibraryFilter = .recientes

    private var items: [MediaItem] {
        if filter == .impacto {
            return allItems.sorted { ($0.personalImpact ?? -1) > ($1.personalImpact ?? -1) }
        }
        guard let mediaType = filter.mediaType else { return allItems }
        return allItems.filter { $0.mediaType == mediaType }
    }

    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: Spacing.md) {
                LibraryHeader(title: "Vistas", count: allItems.count, noun: "archivada")

                if allItems.isEmpty {
                    Spacer()
                    EmptyStateView(
                        title: "Aún no has archivado ninguna.",
                        subtitle: "Cuando marques algo como visto, aparecerá aquí con tu nota."
                    )
                    Spacer()
                } else {
                    RefinedFilterPillBar(
                        options: [.recientes, .impacto, .peliculas, .series, .directores],
                        selection: $filter
                    )
                    content
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationDestination(for: MediaItem.self) { item in
                SavedDetailView(item: item, path: $path, onJumpToRoot: { path = NavigationPath() })
            }
            .navigationDestination(for: PersonNavigationTarget.self) { target in
                PersonDetailView(
                    personId: target.personId,
                    initialName: target.name,
                    initialProfilePath: target.profilePath,
                    path: $path,
                    onJumpToRoot: { path = NavigationPath() }
                )
            }
            .navigationDestination(for: MediaSearchResult.self) { result in
                RemoteDetailView(result: result, path: $path, onJumpToRoot: { path = NavigationPath() })
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    @ViewBuilder
    private var content: some View {
        Group {
            if filter == .directores {
                ScrollView {
                    DirectorsSection(items: allItems, showImpact: true) { person in
                        path.append(PersonNavigationTarget(person))
                    }
                }
            } else if items.isEmpty {
                EmptyFilterNotice()
            } else {
                // "Vistas" es una galería 2D (no deck): es el archivo ya
                // completado, con jerarquía visual distinta a "Quiero ver".
                PosterGridView(items: items, showImpact: true) { item in
                    path.append(item)
                }
                .id(filter)
                .transition(.opacity)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .animation(.easeInOut(duration: 0.3), value: filter)
    }
}

#Preview {
    VistasView(path: .constant(NavigationPath()))
        .modelContainer(for: [MediaItem.self, FavoritePerson.self], inMemory: true)
}
