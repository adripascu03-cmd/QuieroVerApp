import Foundation

enum DetailLoadState {
    case loading
    case loaded(MediaDetails)
    case error(String)
}

@MainActor
@Observable
final class RemoteDetailViewModel {
    private(set) var state: DetailLoadState = .loading

    private let client: TMDbClient

    init(client: TMDbClient = .shared) {
        self.client = client
    }

    func load(_ result: MediaSearchResult) async {
        state = .loading
        do {
            let details = try await client.fetchDetails(for: result)
            state = .loaded(details)
        } catch {
            state = .error((error as? TMDbError)?.errorDescription ?? "Ha ocurrido un error.")
        }
    }
}
