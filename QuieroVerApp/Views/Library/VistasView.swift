import SwiftUI
import SwiftData

struct VistasView: View {
    @Binding var isTabBarHidden: Bool

    @Query(
        filter: #Predicate<MediaItem> { $0.statusRaw == "watched" },
        sort: [SortDescriptor(\MediaItem.watchedAt, order: .reverse)]
    )
    private var allItems: [MediaItem]

    @State private var path = NavigationPath()
    @State private var filter: LibraryFilter = .recientes
    @State private var selectedPerson: PersonNavigationTarget?

    private var items: [MediaItem] {
        if filter == .impacto {
            return allItems.sorted { ($0.personalImpact ?? -1) > ($1.personalImpact ?? -1) }
        }
        guard let mediaType = filter.mediaType else { return allItems }
        return allItems.filter { $0.mediaType == mediaType }
    }

    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.md) {
                    header

                    if allItems.isEmpty {
                        EmptyStateView(
                            title: "Aún no has archivado ninguna.",
                            subtitle: "Cuando marques algo como visto, aparecerá aquí con tu nota."
                        )
                        .padding(.top, Spacing.lg)
                    } else {
                        RefinedFilterPillBar(
                            options: [.recientes, .impacto, .peliculas, .series, .directores],
                            selection: $filter
                        )

                        Group {
                            if filter == .directores {
                                DirectorsSection(items: allItems, showImpact: true) { person in
                                    selectedPerson = PersonNavigationTarget(person)
                                }
                            } else if items.isEmpty {
                                Text("No hay nada con este filtro.")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .padding(.horizontal, Spacing.screenMargin)
                                    .padding(.top, Spacing.lg)
                            } else {
                                ImmersivePosterStack(items: items, showImpact: true)
                            }
                        }
                        .animation(.easeInOut(duration: 0.3), value: filter)
                    }
                }
            }
            .navigationDestination(for: MediaItem.self) { item in
                SavedDetailView(
                    item: item,
                    isTabBarHidden: $isTabBarHidden,
                    onJumpToRoot: { path = NavigationPath() }
                )
            }
            .navigationDestination(item: $selectedPerson) { target in
                PersonDetailView(
                    personId: target.personId,
                    initialName: target.name,
                    initialProfilePath: target.profilePath,
                    onJumpToRoot: { path = NavigationPath() }
                )
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: Spacing.xxs) {
            Text("Vistas")
                .font(.largeTitle.bold())
            Text(countLabel)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, Spacing.screenMargin)
        .padding(.top, Spacing.sm)
    }

    private var countLabel: String {
        allItems.count == 1 ? "1 archivada" : "\(allItems.count) archivadas"
    }
}

#Preview {
    VistasView(isTabBarHidden: .constant(false))
        .modelContainer(for: [MediaItem.self, FavoritePerson.self], inMemory: true)
}
