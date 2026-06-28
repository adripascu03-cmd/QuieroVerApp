import SwiftUI

/// Galería principal como carrusel paginado con sensación de
/// profundidad: la tarjeta centrada queda nítida, las vecinas se
/// atenúan y encogen ligeramente al alejarse del centro.
///
/// Usa `scrollTransition` (iOS 17 nativo) en vez de un gesto 3D hecho a
/// mano: Apple interpola la fase de cada tarjeta según su posición, así
/// que no hay matemática de perspectiva propia que pueda fallar sin
/// poder probarla en un dispositivo real. Encaja con "robusto, no
/// experimental frágil".
struct ImmersivePosterStack: View {
    let items: [MediaItem]
    var showImpact: Bool = false

    private let cardWidth: CGFloat = 208
    private var cardHeight: CGFloat { cardWidth * 1.5 }
    private var totalHeight: CGFloat { cardHeight + 64 }

    var body: some View {
        GeometryReader { proxy in
            let sidePadding = max((proxy.size.width - cardWidth) / 2, Spacing.screenMargin)

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: Spacing.lg) {
                    ForEach(items) { item in
                        NavigationLink(value: item) {
                            EditorialPosterCard(item: item, showImpact: showImpact)
                                .frame(width: cardWidth)
                        }
                        .buttonStyle(PressableButtonStyle())
                        .scrollTransition(axis: .horizontal) { content, phase in
                            content
                                .scaleEffect(1 - abs(phase.value) * 0.12)
                                .opacity(1 - abs(phase.value) * 0.45)
                        }
                    }
                }
                .scrollTargetLayout()
                .padding(.horizontal, sidePadding)
            }
            .scrollTargetBehavior(.viewAligned)
        }
        .frame(height: totalHeight)
        .transition(.opacity.combined(with: .scale(scale: 0.96)))
    }
}
