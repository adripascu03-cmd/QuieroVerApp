import SwiftUI
import SwiftData

struct QuieroVerView: View {
    @Query(
        filter: #Predicate<MediaItem> { $0.statusRaw == "wantToWatch" },
        sort: [SortDescriptor(\MediaItem.addedAt, order: .reverse)]
    )
    private var allItems: [MediaItem]

    @State private var showingSearch = false
    @State private var filter: LibraryFilter = .recientes

    private var items: [MediaItem] {
        guard let mediaType = filter.mediaType else { return allItems }
        return allItems.filter { $0.mediaType == mediaType }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.lg) {
                header

                AddMediaCard { showingSearch = true }
                    .padding(.horizontal, Spacing.screenMargin)

                if allItems.isEmpty {
                    EmptyStateView(
                        title: "Todavía no has guardado nada.",
                        subtitle: "Busca una película o serie y empieza tu archivo."
                    )
                    .padding(.top, Spacing.lg)
                } else {
                    FilterPillBar(options: [.recientes, .peliculas, .series], selection: $filter)

                    if items.isEmpty {
                        Text("No hay nada con este filtro.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, Spacing.screenMargin)
                            .padding(.top, Spacing.lg)
                    } else {
                        PosterGrid(items: items)
                    }
                }
            }
        }
        .navigationDestination(for: MediaItem.self) { item in
            SavedDetailView(item: item)
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingSearch) {
            SearchView()
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: Spacing.xxs) {
            Text("Quiero ver")
                .font(.largeTitle.bold())
            Text(countLabel)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, Spacing.screenMargin)
        .padding(.top, Spacing.sm)
    }

    private var countLabel: String {
        allItems.count == 1 ? "1 guardada" : "\(allItems.count) guardadas"
    }
}

#Preview {
    NavigationStack {
        QuieroVerView()
    }
    .modelContainer(for: MediaItem.self, inMemory: true)
}
