import Foundation

enum PersonDetailLoadState {
    case loading
    case loaded(PersonDetails)
    case error(String)
}

@MainActor
@Observable
final class PersonDetailViewModel {
    private(set) var state: PersonDetailLoadState = .loading

    private let client: TMDbClient

    init(client: TMDbClient = .shared) {
        self.client = client
    }

    func load(personId: Int) async {
        state = .loading
        do {
            let details = try await client.fetchPersonDetails(id: personId)
            state = .loaded(details)
        } catch {
            state = .error((error as? TMDbError)?.errorDescription ?? "Ha ocurrido un error.")
        }
    }
}
