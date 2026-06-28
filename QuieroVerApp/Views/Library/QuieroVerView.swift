import SwiftUI
import SwiftData

struct QuieroVerView: View {
    @Binding var isTabBarHidden: Bool

    @Query(
        filter: #Predicate<MediaItem> { $0.statusRaw == "wantToWatch" },
        sort: [SortDescriptor(\MediaItem.addedAt, order: .reverse)]
    )
    private var allItems: [MediaItem]

    @State private var path = NavigationPath()
    @State private var showingSearch = false
    @State private var filter: LibraryFilter = .recientes
    @State private var selectedPerson: PersonNavigationTarget?

    private var items: [MediaItem] {
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
                            title: "Todavía no has guardado nada.",
                            subtitle: "Busca una película o serie y empieza tu archivo."
                        )
                        .padding(.top, Spacing.lg)
                    } else {
                        RefinedFilterPillBar(
                            options: [.recientes, .peliculas, .series, .directores],
                            selection: $filter
                        )

                        Group {
                            if filter == .directores {
                                DirectorsSection(items: allItems) { person in
                                    selectedPerson = PersonNavigationTarget(person)
                                }
                            } else if items.isEmpty {
                                Text("No hay nada con este filtro.")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .padding(.horizontal, Spacing.screenMargin)
                                    .padding(.top, Spacing.lg)
                            } else {
                                ImmersivePosterStack(items: items)
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
            .sheet(isPresented: $showingSearch) {
                SearchView()
            }
        }
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text("Quiero ver")
                    .font(.largeTitle.bold())
                Text(countLabel)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            CompactAddCard {
                showingSearch = true
            }
            .padding(.top, Spacing.xxs)
        }
        .padding(.horizontal, Spacing.screenMargin)
        .padding(.top, Spacing.sm)
    }

    private var countLabel: String {
        allItems.count == 1 ? "1 guardada" : "\(allItems.count) guardadas"
    }
}

#Preview {
    QuieroVerView(isTabBarHidden: .constant(false))
        .modelContainer(for: [MediaItem.self, FavoritePerson.self], inMemory: true)
}
