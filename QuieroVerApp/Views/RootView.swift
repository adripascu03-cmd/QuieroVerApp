import SwiftUI

/// Raíz de la app: pager horizontal entre "Quiero ver" y "Vistas" con
/// una tab bar flotante que SOLO aparece en las pantallas raíz.
///
/// La visibilidad de la tab bar no la decide cada pantalla de detalle a
/// mano (eso provocaba que, p. ej., abrir una ficha de persona desde la
/// categoría Directores dejara la barra visible). Aquí se DERIVA del
/// estado de navegación: los `NavigationPath` de cada pestaña viven en
/// este nivel, y la barra se muestra solo cuando el path de la pestaña
/// activa está vacío (= estás en la raíz). Cualquier push la oculta,
/// cualquier vuelta a raíz la recupera, sin tocar nada en las fichas.
struct RootView: View {
    @State private var selectedTab: LibraryTab = .quieroVer
    @State private var quieroVerPath = NavigationPath()
    @State private var vistasPath = NavigationPath()
    @State private var dragOffset: CGFloat = 0

    private var isAtRoot: Bool {
        selectedTab == .quieroVer ? quieroVerPath.isEmpty : vistasPath.isEmpty
    }

    var body: some View {
        GeometryReader { proxy in
            let pageWidth = proxy.size.width

            HStack(spacing: 0) {
                QuieroVerView(path: $quieroVerPath)
                    .frame(width: pageWidth)
                VistasView(path: $vistasPath)
                    .frame(width: pageWidth)
            }
            .offset(x: -CGFloat(selectedTab.rawValue) * pageWidth + dragOffset)
            .frame(width: pageWidth, alignment: .leading)
            .clipped()
            // En detalle (no-raíz) el pager se desactiva vía GestureMask
            // (no un if/else estructural, que recrearía las pestañas y
            // perdería su NavigationPath) para no competir con el gesto
            // nativo de "atrás".
            .gesture(
                dragGesture(pageWidth: pageWidth),
                including: isAtRoot ? .all : .subviews
            )
        }
        .safeAreaInset(edge: .bottom) {
            if isAtRoot {
                LiquidTabBar(selection: $selectedTab)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.28), value: isAtRoot)
    }

    private func dragGesture(pageWidth: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 24)
            .onChanged { value in
                // Solo gestos predominantemente horizontales mueven el pager.
                guard abs(value.translation.width) > abs(value.translation.height) else { return }
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
