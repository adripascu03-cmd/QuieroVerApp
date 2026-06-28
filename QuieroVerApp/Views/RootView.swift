import SwiftUI

struct RootView: View {
    @State private var selectedTab: LibraryTab = .quieroVer

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                QuieroVerView()
            }
            .tag(LibraryTab.quieroVer)

            NavigationStack {
                VistasView()
            }
            .tag(LibraryTab.vistas)
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .safeAreaInset(edge: .bottom) {
            LiquidTabBar(selection: $selectedTab)
        }
    }
}

#Preview {
    RootView()
        .modelContainer(for: MediaItem.self, inMemory: true)
}
