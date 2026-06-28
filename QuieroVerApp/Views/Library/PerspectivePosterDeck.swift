import SwiftUI

/// Pila vertical de portadas con profundidad — el corazón de la home.
///
/// La carta activa queda frontal, grande y centrada; las anteriores se
/// abanican hacia arriba y las siguientes hacia abajo, con escala,
/// opacidad, una rotación 3D contenida y solape — como ojear una pila
/// física de carátulas. El movimiento es vertical, con snap a la carta
/// activa.
///
/// Es deliberadamente una *ilusión* de profundidad estable (offset +
/// escala + opacidad + un tilt 3D suave), no una simulación 3D
/// compleja: tiene que ser robusta en dispositivo sin poder probarla
/// aquí. Funciona igual con 1 que con muchos elementos.
struct PerspectivePosterDeck: View {
    let items: [MediaItem]
    var showImpact: Bool = false
    var onSelect: (MediaItem) -> Void

    @State private var activeIndex: Int = 0
    @State private var dragOffset: CGFloat = 0

    private let cardWidth: CGFloat = 240
    private var cardHeight: CGFloat { cardWidth * 1.5 }
    /// Desplazamiento vertical que equivale a pasar una carta.
    private let dragStep: CGFloat = 92
    /// Cuántas cartas se dibujan a cada lado de la activa.
    private let window = 3

    var body: some View {
        VStack(spacing: Spacing.md) {
            ZStack {
                ForEach(visibleIndices, id: \.self) { index in
                    card(for: index)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipped()
            .contentShape(Rectangle())
            .gesture(dragGesture)

            caption
                .frame(height: 52)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onChange(of: items.count) { _, newCount in
            if activeIndex >= newCount { activeIndex = max(0, newCount - 1) }
        }
    }

    // MARK: Cartas

    private var visibleIndices: [Int] {
        guard !items.isEmpty else { return [] }
        let lower = max(0, activeIndex - window - 1)
        let upper = min(items.count - 1, activeIndex + window + 1)
        return Array(lower...upper)
    }

    @ViewBuilder
    private func card(for index: Int) -> some View {
        let relative = CGFloat(index) - CGFloat(activeIndex) - dragOffset / dragStep
        let t = deckTransform(relative)

        PosterDeckCard(item: items[index], showImpact: showImpact, isActive: index == activeIndex)
            .frame(width: cardWidth, height: cardHeight)
            .scaleEffect(t.scale)
            .rotation3DEffect(.degrees(t.rotation), axis: (x: 1, y: 0, z: 0), perspective: 0.45)
            .offset(y: t.y)
            .opacity(t.opacity)
            .zIndex(t.z)
            .allowsHitTesting(t.opacity > 0.15)
            .onTapGesture {
                if index == activeIndex {
                    onSelect(items[index])
                } else {
                    Haptics.light()
                    withAnimation(.spring(response: 0.45, dampingFraction: 0.82)) {
                        activeIndex = index
                    }
                }
            }
    }

    /// Posición visual de una carta según su distancia (continua) a la
    /// activa. El crecimiento sublineal del offset hace que las cartas
    /// lejanas se agolpen — esa compresión es lo que da la perspectiva.
    private func deckTransform(_ relative: CGFloat) -> (y: CGFloat, scale: CGFloat, opacity: Double, rotation: Double, z: Double) {
        let dist = abs(relative)
        let direction: CGFloat = relative < 0 ? -1 : 1
        let yMagnitude = pow(dist, 0.72) * 60
        let y = direction * yMagnitude
        let scale = max(1 - dist * 0.10, 0.62)
        let opacity = Double(max(1 - dist * 0.27, 0))
        // Las de arriba inclinan su canto inferior hacia el usuario y las
        // de abajo su canto superior: un cilindro convexo muy sutil.
        let rotation = Double(-direction * min(dist, 2.5) * 5)
        let z = Double(-dist)
        return (y, scale, opacity, rotation, z)
    }

    // MARK: Caption (item activo)

    @ViewBuilder
    private var caption: some View {
        if items.indices.contains(activeIndex) {
            let item = items[activeIndex]
            VStack(spacing: 2) {
                Text(item.title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                Text(captionSubtitle(item))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .multilineTextAlignment(.center)
            .padding(.horizontal, Spacing.screenMargin)
            .id(activeIndex)
            .transition(.opacity)
        }
    }

    private func captionSubtitle(_ item: MediaItem) -> String {
        var parts: [String] = [item.mediaType.displayName]
        if !item.displayYear.isEmpty { parts.append(item.displayYear) }
        if showImpact, let impact = item.personalImpact {
            let stars = Int((impact / 2).rounded())
            parts.append(String(repeating: "★", count: max(stars, 0)))
        }
        return parts.joined(separator: "  ·  ")
    }

    // MARK: Gesto vertical

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                let raw = -value.translation.height  // arrastrar hacia arriba = avanzar
                // Tope con holgura para que no se desborde más allá de los extremos.
                let minOffset = -CGFloat(activeIndex) * dragStep - 48
                let maxOffset = CGFloat(items.count - 1 - activeIndex) * dragStep + 48
                dragOffset = min(max(raw, minOffset), maxOffset)
            }
            .onEnded { value in
                let predicted = -value.predictedEndTranslation.height
                let steps = (predicted / dragStep).rounded()
                let target = max(0, min(items.count - 1, activeIndex + Int(steps)))
                let changed = target != activeIndex
                withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
                    activeIndex = target
                    dragOffset = 0
                }
                if changed { Haptics.light() }
            }
    }
}

/// Una carta del deck: portada con esquinas redondeadas, borde sutil y
/// sombra. La activa lleva una sombra algo más marcada para reforzar que
/// flota por delante de las demás.
struct PosterDeckCard: View {
    let item: MediaItem
    var showImpact: Bool = false
    var isActive: Bool = false

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            AsyncPosterImage(
                url: ImageURLBuilder.posterURL(path: item.posterPath),
                title: item.title,
                mediaType: item.mediaType
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .strokeBorder(.white.opacity(0.14), lineWidth: 1)
            )

            if showImpact, let impact = item.personalImpact {
                ImpactBadge(value: impact)
                    .padding(12)
            }
        }
        .shadow(color: .black.opacity(isActive ? 0.30 : 0.16), radius: isActive ? 24 : 14, x: 0, y: isActive ? 18 : 10)
    }
}
