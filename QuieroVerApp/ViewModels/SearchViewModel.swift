import Foundation

enum SearchState {
    case idle
    case loading
    case loaded([SearchResultItem])
    case empty
    case error(String)
}

@MainActor
@Observable
final class SearchViewModel {
    var query: String = ""
    private(set) var state: SearchState = .idle

    private let client: TMDbClient
    private var searchTask: Task<Void, Never>?

    init(client: TMDbClient = .shared) {
        self.client = client
    }

    func search() {
        searchTask?.cancel()

        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            state = .idle
            return
        }

        searchTask = Task {
            try? await Task.sleep(nanoseconds: 300_000_000)
            guard !Task.isCancelled else { return }
            await performSearch(trimmed)
        }
    }

    private func performSearch(_ text: String) async {
        state = .loading
        do {
            let results = try await client.searchMedia(query: text)
            guard !Task.isCancelled else { return }
            state = results.isEmpty ? .empty : .loaded(results)
        } catch {
            guard !Task.isCancelled else { return }
            state = .error((error as? TMDbError)?.errorDescription ?? "Ha ocurrido un error.")
        }
    }
}
