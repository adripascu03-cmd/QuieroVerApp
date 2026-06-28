import SwiftUI
import SwiftData

struct VistasView: View {
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
                        options: [.recientes, .impacto, .peliculas, .series],
                        selection: $filter
                    )

                    if items.isEmpty {
                        Text("No hay nada con este filtro.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, Spacing.screenMargin)
                            .padding(.top, Spacing.lg)
                    } else {
                        PosterGrid(items: items, showImpact: true)
                    }
                }
            }
        }
        .navigationDestination(for: MediaItem.self) { item in
            SavedDetailView(item: item)
        }
        .navigationBarTitleDisplayMode(.inline)
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
    NavigationStack {
        VistasView()
    }
    .modelContainer(for: MediaItem.self, inMemory: true)
}
