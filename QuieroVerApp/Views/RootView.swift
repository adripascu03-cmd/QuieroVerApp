import SwiftUI

struct RootView: View {
    var body: some View {
        TabView {
            NavigationStack {
                QuieroVerView()
            }
            .tabItem {
                Label("Quiero ver", systemImage: "bookmark.fill")
            }

            NavigationStack {
                VistasView()
            }
            .tabItem {
                Label("Vistas", systemImage: "checkmark.seal.fill")
            }
        }
    }
}

#Preview {
    RootView()
        .modelContainer(for: MediaItem.self, inMemory: true)
}
