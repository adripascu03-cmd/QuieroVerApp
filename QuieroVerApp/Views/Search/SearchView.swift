import SwiftUI

@MainActor
struct SearchView: View {
    @State private var viewModel = SearchViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Buscar")
                .navigationBarTitleDisplayMode(.inline)
                .navigationDestination(for: MediaSearchResult.self) { result in
                    RemoteDetailView(result: result)
                }
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Cerrar") { dismiss() }
                    }
                }
                .searchable(text: $viewModel.query, prompt: "Buscar película o serie...")
                .onChange(of: viewModel.query) { _, _ in
                    viewModel.search()
                }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle:
            Color.clear
        case .loading:
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .loaded(let results):
            List(results) { result in
                NavigationLink(value: result) {
                    SearchResultRow(result: result)
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
}
