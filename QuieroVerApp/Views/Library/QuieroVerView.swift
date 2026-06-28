import SwiftUI
import SwiftData

struct QuieroVerView: View {
    @Binding var path: NavigationPath

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
        NavigationStack(path: $path) {
            ZStack(alignment: .bottomTrailing) {
                VStack(spacing: Spacing.md) {
                    LibraryHeader(title: "Quiero ver", count: allItems.count, noun: "guardada")

                    if allItems.isEmpty {
                        Spacer()
                        EmptyStateView(
                            title: "Todavía no has guardado nada.",
                            subtitle: "Toca + para buscar una película, serie o persona."
                        )
                        Spacer()
                    } else {
                        RefinedFilterPillBar(
                            options: [.recientes, .peliculas, .series, .directores],
                            selection: $filter
                        )
                        content
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                FloatingAddButton { showingSearch = true }
                    .padding(.trailing, Spacing.screenMargin)
                    .padding(.bottom, Spacing.lg)
            }
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
            .sheet(isPresented: $showingSearch) {
                SearchView()
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        Group {
            if filter == .directores {
                ScrollView {
                    DirectorsSection(items: allItems) { person in
                        path.append(PersonNavigationTarget(person))
                    }
                }
            } else if items.isEmpty {
                EmptyFilterNotice()
            } else {
                PerspectivePosterDeck(items: items) { item in
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

/// Cabecera de biblioteca: título grande + contador. Compartida por
/// "Quiero ver" y "Vistas" para un lenguaje visual idéntico.
struct LibraryHeader: View {
    let title: String
    let count: Int
    /// Singular del sustantivo ("guardada" / "archivada"); el plural
    /// añade una "s".
    let noun: String

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xxs) {
            Text(title)
                .font(.largeTitle.bold())
            Text(countLabel)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, Spacing.screenMargin)
        .padding(.top, Spacing.sm)
    }

    private var countLabel: String {
        count == 1 ? "1 \(noun)" : "\(count) \(noun)s"
    }
}

/// Aviso centrado cuando un filtro no tiene resultados. Vista única
/// (no varios hijos sueltos) para rellenar el espacio del deck sin que
/// los modificadores del contenedor se apliquen a cada elemento.
struct EmptyFilterNotice: View {
    var body: some View {
        VStack {
            Spacer()
            Text("No hay nada con este filtro.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    QuieroVerView(path: .constant(NavigationPath()))
        .modelContainer(for: [MediaItem.self, FavoritePerson.self], inMemory: true)
}
