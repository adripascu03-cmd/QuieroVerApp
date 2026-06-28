import SwiftUI

@main
struct QuieroVerApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(for: MediaItem.self)
    }
}
