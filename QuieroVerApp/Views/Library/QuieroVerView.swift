import SwiftUI
import SwiftData

struct QuieroVerView: View {
    @Query(
        filter: #Predicate<MediaItem> { $0.statusRaw == "wantToWatch" },
        sort: [SortDescriptor(\MediaItem.addedAt, order: .reverse)]
    )
    private var allItems: [MediaItem]

    @State private var showingSearch = false
    @State private var typeFilter: MediaTypeFilter = .all

    private var items: [MediaItem] {
        guard let mediaType = typeFilter.mediaType else { return allItems }
        return allItems.filter { $0.mediaType == mediaType }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.md) {
                header

                if allItems.isEmpty {
                    EmptyStateView(
                        title: "Todavía no has guardado nada.",
                        subtitle: "Busca una película o serie y empieza tu archivo.",
                        actionTitle: "Buscar"
                    ) {
                        showingSearch = true
                    }
                    .padding(.top, Spacing.xxl)
                } else {
                    TypeFilterChips(selection: $typeFilter)

                    if items.isEmpty {
                        Text("No hay nada con este filtro.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, Spacing.md)
                            .padding(.top, Spacing.lg)
                    } else {
                        MediaGrid(items: items)
                    }
                }
            }
        }
        .navigationDestination(for: MediaItem.self) { item in
            SavedDetailView(item: item)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingSearch = true
                } label: {
                    Image(systemName: "magnifyingglass")
                }
                .accessibilityLabel("Buscar película o serie")
            }
        }
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
        .padding(.horizontal, Spacing.md)
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
