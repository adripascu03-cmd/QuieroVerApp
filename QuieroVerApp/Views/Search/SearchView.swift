import SwiftUI

@MainActor
struct SearchView: View {
    @State private var viewModel = SearchViewModel()
    @State private var path = NavigationPath()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack(path: $path) {
            content
                .navigationTitle("Buscar")
                .navigationBarTitleDisplayMode(.inline)
                .navigationDestination(for: MediaSearchResult.self) { result in
                    // onAdded cierra todo el sheet de búsqueda de una vez,
                    // no solo este paso de la navegación interna.
                    RemoteDetailView(result: result, path: $path, onAdded: { dismiss() })
                }
                .navigationDestination(for: PersonNavigationTarget.self) { target in
                    PersonDetailView(
                        personId: target.personId,
                        initialName: target.name,
                        initialProfilePath: target.profilePath,
                        path: $path
                    )
                }
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Cerrar") { dismiss() }
                    }
                }
                .searchable(text: $viewModel.query, prompt: "Buscar película, serie o persona...")
                .onChange(of: viewModel.query) { _, _ in
                    viewModel.search()
                }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle:
            ScrollView {
                FavoritePersonsSection { person in
                    path.append(person)
                }
            }
        case .loading:
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .loaded(let items):
            List(items) { item in
                switch item {
                case .media(let result):
                    NavigationLink(value: result) {
                        SearchResultRow(result: result)
                    }
                case .person(let person):
                    Button {
                        path.append(PersonNavigationTarget(person))
                    } label: {
                        PersonSearchResultRow(person: person)
                    }
                    .buttonStyle(.plain)
                }
            }
            .listStyle(.plain)
        case .empty:
            ContentUnavailableView(
                "No he encontrado nada con ese nombre.",
                systemImage: "magnifyingglass"
            )
        case .error(let message):
            ContentUnavailableView(
                "No se ha podido conectar.",
                systemImage: "wifi.slash",
                description: Text(message)
            )
        }
    }
}

#Preview {
    SearchView()
        .modelContainer(for: [MediaItem.self, FavoritePerson.self], inMemory: true)
}
