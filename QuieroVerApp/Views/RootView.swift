import SwiftUI

/// Pager custom entre "Quiero ver" y "Vistas". Sustituye
/// `TabView(.page)`: ese estilo tiene un problema conocido de
/// "tragarse" toques sobre botones hijos por cómo instala su gesture
/// recognizer de paginado. Un `DragGesture` propio con distancia mínima
/// no se activa con un simple tap, así que nunca compite con botones.
struct RootView: View {
    @State private var selectedTab: LibraryTab = .quieroVer
    @State private var isTabBarHidden = false
    @State private var dragOffset: CGFloat = 0

    var body: some View {
        GeometryReader { proxy in
            let pageWidth = proxy.size.width

            HStack(spacing: 0) {
                QuieroVerView(isTabBarHidden: $isTabBarHidden)
                    .frame(width: pageWidth)
                VistasView(isTabBarHidden: $isTabBarHidden)
                    .frame(width: pageWidth)
            }
            .offset(x: -CGFloat(selectedTab.rawValue) * pageWidth + dragOffset)
            .frame(width: pageWidth, alignment: .leading)
            .clipped()
            // `including:` cambia solo el valor de la máscara, nunca el
            // tipo de la vista — a diferencia de un if/else estructural,
            // esto no destruye ni recrea QuieroVerView/VistasView (con
            // su NavigationPath interno) al ocultar la tab bar.
            .gesture(
                dragGesture(pageWidth: pageWidth),
                including: isTabBarHidden ? .subviews : .all
            )
        }
        .safeAreaInset(edge: .bottom) {
            if !isTabBarHidden {
                LiquidTabBar(selection: $selectedTab)
            }
        }
    }

    private func dragGesture(pageWidth: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 24)
            .onChanged { value in
                dragOffset = value.translation.width
            }
            .onEnded { value in
                let threshold = pageWidth * 0.22
                var newTab = selectedTab
                if value.translation.width < -threshold, selectedTab == .quieroVer {
                    newTab = .vistas
                } else if value.translation.width > threshold, selectedTab == .vistas {
                    newTab = .quieroVer
                }
                let didChange = newTab != selectedTab
                withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                    selectedTab = newTab
                    dragOffset = 0
                }
                if didChange { Haptics.light() }
            }
    }
}

#Preview {
    RootView()
        .modelContainer(for: [MediaItem.self, FavoritePerson.self], inMemory: true)
}
