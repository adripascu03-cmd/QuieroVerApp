import SwiftUI
import SwiftData

/// Pila vertical de portadas viva — el corazón de "Quiero ver".
///
/// La carta activa queda frontal, grande y centrada; las anteriores se
/// abanican hacia arriba (tops apilados) y las siguientes asoman por
/// abajo, con escala, opacidad, una rotación 3D de perspectiva y solape
/// — como ojear una pila física de carátulas.
///
/// Tiene movimiento automático muy lento y circular (autoplay), control
/// manual con arrastre vertical + snap + háptica de selección, y una
/// interacción de selección en dos pasos: tocar arma la carta; desde ahí
/// se puede deslizar a la derecha (marcar como vista), volver a tocar
/// (entrar al detalle) o tocar fuera (cancelar).
///
/// Es una ilusión de profundidad estable (offset + escala + opacidad +
/// tilt 3D), no una simulación 3D frágil, para que sea robusta en
/// dispositivo.
struct PerspectivePosterDeck: View {
    let items: [MediaItem]
    var onOpenDetail: (MediaItem) -> Void
    var onMarkWatched: (MediaItem) -> Void

    /// Posición continua del deck, en unidades de carta. La parte entera
    /// (redondeada) es la carta activa; la fraccionaria, el desplazamiento.
    @State private var scrollPosition: Double = 0
    @State private var dragStartPosition: Double = 0
    @State private var isDragging = false
    @State private var lastActiveIndex = 0

    @State private var pingPongForward = true
    @State private var autoplayPaused = false
    @State private var resumeWorkItem: DispatchWorkItem?

    @State private var armedID: PersistentIdentifier?
    @State private var swipeX: CGFloat = 0

    private let cardWidth: CGFloat = 236
    private var cardHeight: CGFloat { cardWidth * 1.46 }
    private let dragStep: CGFloat = 80
    private let swipeToWatchThreshold: CGFloat = 78

    // Geometría de EJE/RODILLO: todas las tarjetas están unidas por su
    // ARISTA INFERIOR a un mismo rodillo horizontal. La tarjeta es rígida
    // y gira solidaria con el eje pivotando sobre ese borde inferior
    // (`anchor: .bottom`), así que la arista inferior apenas se mueve
    // (pivote) y la superior describe un arco grande. NO son posters
    // flotantes desplazados: comparten el borde inferior y se abren en
    // abanico al girar. La activa queda vertical y de frente.
    private let anglePerCard: Double = 28    // giro del eje entre tarjetas, en grados
    private let axleY: CGFloat = 134          // posición del rodillo respecto al centro del deck
    private let deckPerspective: CGFloat = 0.5

    private let autoplayTimer = Timer.publish(every: 0.02, on: .main, in: .common).autoconnect()

    private var count: Int { items.count }

    var body: some View {
        VStack(spacing: Spacing.md) {
            ZStack {
                // Fondo para cancelar la selección al tocar fuera de la carta.
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture { cancelSelection() }
                    .allowsHitTesting(armedID != nil)

                // Rodillo/eje: la barra horizontal a la que están unidas
                // las aristas inferiores de todas las tarjetas. Se asoma
                // bajo el abanico para hacer legible el mecanismo.
                axle

                ForEach(Array(items.enumerated()), id: \.element.persistentModelID) { index, item in
                    cardView(index: index, item: item)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipped()
            .contentShape(Rectangle())
            // Drag vertical SIMULTÁNEO: se reconoce a la vez que los taps
            // de las tarjetas, así arrastrar en CUALQUIER punto del área
            // (también encima de una película) mueve el carrusel — ya no
            // hace falta deslizar por el lateral. Un tap (sin movimiento)
            // sigue armando la tarjeta. Cuando hay una seleccionada, la
            // máscara `.subviews` cede el gesto al swipe horizontal propio.
            .simultaneousGesture(verticalDrag, including: armedID == nil ? .all : .subviews)

            caption
                .frame(height: 50)
                .opacity(armedID == nil ? 1 : 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onReceive(autoplayTimer) { _ in autoplayTick() }
        .onChange(of: count) { oldCount, newCount in
            handleCountChange(old: oldCount, new: newCount)
        }
    }

    // MARK: - Rodillo / eje

    private var axle: some View {
        Capsule(style: .continuous)
            .fill(
                LinearGradient(
                    colors: [Color(.systemGray2), Color(.systemGray4)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .frame(width: cardWidth + 26, height: 13)
            .overlay(Capsule().strokeBorder(.white.opacity(0.18), lineWidth: 0.5))
            .shadow(color: .black.opacity(0.18), radius: 5, x: 0, y: 3)
            .offset(y: axleY)
            .zIndex(-1000)
            .allowsHitTesting(false)
    }

    // MARK: - Cartas

    @ViewBuilder
    private func cardView(index: Int, item: MediaItem) -> some View {
        let relative = wrappedRelative(of: index)
        let t = deckTransform(relative)
        let isArmed = armedID == item.persistentModelID
        let dimmed = armedID != nil && !isArmed

        ZStack(alignment: .top) {
            PosterDeckCard(item: item, isActive: index == activeIndex || isArmed)
                .frame(width: cardWidth, height: cardHeight)

            if isArmed {
                swipeHint
                    .offset(y: -34)
                    .transition(.opacity)
            }
        }
        .scaleEffect(t.scale * (isArmed ? 1.08 : 1))
        // Pivota sobre su ARISTA INFERIOR (anchor .bottom): el borde de
        // abajo queda fijo en el rodillo y la carta gira solidaria con el
        // eje. Armada -> recta (0°) y separada del eje, para destacar.
        .rotation3DEffect(
            .degrees(isArmed ? 0 : t.rotation),
            axis: (x: 1, y: 0, z: 0),
            anchor: .bottom,
            perspective: deckPerspective
        )
        .offset(x: isArmed ? swipeX : 0, y: t.y + (isArmed ? -26 : 0))
        .opacity(dimmed ? t.opacity * 0.28 : t.opacity)
        .zIndex(isArmed ? 1000 : t.z)
        .allowsHitTesting(armedID == nil ? t.opacity > 0.2 : isArmed)
        .onTapGesture { handleTap(on: item) }
        // Estando armada, su swipe horizontal tiene PRIORIDAD sobre el
        // pager de pantalla y el drag del deck (antes competían y la
        // tarjeta no acompañaba al dedo).
        .highPriorityGesture(swipeToWatch(item: item), including: isArmed ? .all : .subviews)
    }

    private var swipeHint: some View {
        SwipeHintLabel()
    }

    // MARK: - Geometría del deck

    /// Distancia (continua, con signo) de la carta `index` a la activa,
    /// envuelta circularmente al rango más corto. Para 1–2 cartas no se
    /// envuelve (el autoplay las trata de forma acotada).
    private func wrappedRelative(of index: Int) -> Double {
        let raw = Double(index) - scrollPosition
        guard count >= 3 else { return raw }
        let c = Double(count)
        var r = raw.truncatingRemainder(dividingBy: c)
        if r > c / 2 { r -= c }
        if r < -c / 2 { r += c }
        return r
    }

    /// Mitad visible del abanico. Se ajusta al número de cartas para que
    /// la opacidad llegue a 0 justo en la carta "opuesta" del círculo, y
    /// así el salto del loop sea invisible.
    private var span: Double {
        count <= 2 ? 1.7 : min(2.6, Double(count) / 2.0)
    }

    private func deckTransform(_ relative: Double) -> (y: CGFloat, scale: CGFloat, opacity: Double, rotation: Double, z: Double) {
        let dist = abs(relative)
        let angleDeg = relative * anglePerCard
        let angleRad = angleDeg * .pi / 180

        // TODAS las tarjetas comparten el mismo borde inferior sobre el
        // rodillo: `y` coloca ese borde en el eje (centro de la carta a
        // media altura por encima). El abanico NO nace de desplazar cada
        // carta, sino de la rotación alrededor de ese borde inferior
        // (anchor .bottom en la vista) -> mecanismo de eje, no posters
        // sueltos.
        let y = axleY - cardHeight / 2

        // Pizca de profundidad: cuanto más gira (más se aleja la arista
        // superior), un poco más pequeña.
        let depth = (1 - cos(angleRad)) / 2
        let scale = CGFloat(max(1 - depth * 0.4, 0.66))

        // Tarjetas TOTALMENTE OPACAS: nada de "fantasmas". Solo la que
        // entra/sale del recorrido se desvanece en el último tramo junto
        // al borde, lo justo para que el giro continuo no dé un salto.
        let fadeStart = max(span - 0.6, 0.1)
        let opacity: Double
        if dist <= fadeStart {
            opacity = 1
        } else {
            opacity = Double(max(0, 1 - (dist - fadeStart) / (span - fadeStart)))
        }

        // La inclinación de la tarjeta ES su ángulo en el eje.
        let rotation = angleDeg

        // SOBREPOSICIÓN (corregida): las tarjetas nacen detrás (en la
        // posición más tumbada) y se mantienen detrás; las que TERMINAN el
        // recorrido tapan al resto. `relative` decrece según avanza una
        // tarjeta, así que un z monótono con -relative deja delante a las
        // que van más avanzadas y detrás a las recién nacidas (5 tapa 4 …
        // 2 tapa 1, no al revés).
        let z = -relative
        return (y, scale, opacity, rotation, z)
    }

    private var activeIndex: Int {
        guard count > 0 else { return 0 }
        return ((Int(scrollPosition.rounded()) % count) + count) % count
    }

    // MARK: - Caption (item activo)

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
        return parts.joined(separator: "  ·  ")
    }

    // MARK: - Autoplay

    private func autoplayTick() {
        guard count >= 2, !isDragging, armedID == nil, !autoplayPaused else { return }
        let drift = 0.003
        if count == 2 {
            // Vaivén suave entre las dos cartas (el círculo degenera con 2).
            scrollPosition += pingPongForward ? drift : -drift
            if scrollPosition >= 1 { scrollPosition = 1; pingPongForward = false }
            if scrollPosition <= 0 { scrollPosition = 0; pingPongForward = true }
        } else {
            scrollPosition += drift
            let c = Double(count)
            // Reencaja a [0, count) sin animación: como el render es
            // modular (`wrappedRelative`), el salto es invisible. Esto
            // también reabsorbe sin ruido cualquier posición grande que
            // haya dejado un flick previo.
            if scrollPosition >= c { scrollPosition = scrollPosition.truncatingRemainder(dividingBy: c) }
        }
    }

    private func pauseAutoplay() {
        autoplayPaused = true
        resumeWorkItem?.cancel()
    }

    private func scheduleResume(after delay: TimeInterval = 2.5) {
        resumeWorkItem?.cancel()
        let work = DispatchWorkItem {
            if armedID == nil { autoplayPaused = false }
        }
        resumeWorkItem = work
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: work)
    }

    // MARK: - Arrastre vertical

    private var verticalDrag: some Gesture {
        DragGesture(minimumDistance: 6)
            .onChanged { value in
                if !isDragging {
                    isDragging = true
                    dragStartPosition = scrollPosition
                    pauseAutoplay()
                }
                let delta = -value.translation.height / dragStep
                var newPos = dragStartPosition + delta
                if count <= 2 { newPos = min(max(newPos, 0), Double(max(count - 1, 0))) }
                scrollPosition = newPos
                fireSelectionHapticIfNeeded()
            }
            .onEnded { value in
                let predicted = -value.predictedEndTranslation.height / dragStep
                var target = (dragStartPosition + predicted).rounded()
                if count <= 2 { target = min(max(target, 0), Double(max(count - 1, 0))) }
                withAnimation(.spring(response: 0.45, dampingFraction: 0.82)) {
                    scrollPosition = target
                }
                isDragging = false
                scheduleResume()
            }
    }

    private func fireSelectionHapticIfNeeded() {
        let idx = activeIndex
        if idx != lastActiveIndex {
            lastActiveIndex = idx
            Haptics.selection()
        }
    }

    // MARK: - Selección en dos pasos

    private func handleTap(on item: MediaItem) {
        if armedID == item.persistentModelID {
            // Segundo toque -> entrar al detalle.
            onOpenDetail(item)
            return
        }
        // Primer toque -> centrar la carta y armarla.
        guard let index = items.firstIndex(where: { $0.persistentModelID == item.persistentModelID }) else { return }
        pauseAutoplay()
        Haptics.light()
        withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) {
            scrollPosition += wrappedRelative(of: index)
            armedID = item.persistentModelID
            swipeX = 0
        }
    }

    private func cancelSelection() {
        // Al deseleccionar (tap fuera), el carrusel se reanuda DE
        // INMEDIATO, sin la espera anterior.
        resumeWorkItem?.cancel()
        withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
            armedID = nil
            swipeX = 0
        }
        autoplayPaused = false
    }

    private func swipeToWatch(item: MediaItem) -> some Gesture {
        DragGesture(minimumDistance: 8)
            .onChanged { value in
                swipeX = max(0, value.translation.width)
            }
            .onEnded { value in
                // Fácil de disparar: basta un deslizamiento corto a la
                // derecha O un flick (la velocidad/predicción lo cuenta).
                if value.translation.width > swipeToWatchThreshold
                    || value.predictedEndTranslation.width > 150 {
                    // Sale por la derecha y se marca como vista.
                    withAnimation(.easeIn(duration: 0.25)) {
                        swipeX = 600
                    }
                    Haptics.success()
                    let watched = item
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        armedID = nil
                        swipeX = 0
                        onMarkWatched(watched)
                    }
                } else {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        swipeX = 0
                    }
                }
            }
    }

    // MARK: - Reacción a cambios en la colección

    private func handleCountChange(old: Int, new: Int) {
        armedID = nil
        swipeX = 0
        if new == 0 { return }

        if new > old {
            // Se ha añadido una película: enfoca la más reciente (índice 0
            // en "Recientes") con una pequeña animación de entrada.
            withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
                scrollPosition = 0
            }
            lastActiveIndex = 0
        } else if scrollPosition >= Double(new) || scrollPosition < 0 {
            // Se ha quitado una película fuera de rango: reencaja.
            scrollPosition = 0
            lastActiveIndex = 0
        }

        if new >= 2 {
            autoplayPaused = false
            scheduleResume()
        }
    }
}

/// Indicación sutil sobre la carta armada: fina, pequeña, con opacidad
/// que late suavemente — sin parecer un botón.
private struct SwipeHintLabel: View {
    @State private var pulse = false

    var body: some View {
        Text("Desliza para marcar como vista  »")
            .font(.caption2.weight(.semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(.ultraThinMaterial, in: Capsule())
            .overlay(Capsule().strokeBorder(.white.opacity(0.25), lineWidth: 0.5))
            .opacity(pulse ? 1 : 0.55)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true)) {
                pulse = true
            }
        }
    }
}

/// Una carta del deck: portada con esquinas redondeadas, borde sutil y
/// sombra. La activa lleva una sombra algo más marcada para reforzar que
/// flota por delante.
struct PosterDeckCard: View {
    let item: MediaItem
    var isActive: Bool = false

    var body: some View {
        AsyncPosterImage(
            url: ImageURLBuilder.posterURL(path: item.posterPath),
            title: item.title,
            mediaType: item.mediaType
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(.white.opacity(0.16), lineWidth: 1)
        )
        // Doble sombra: una de contacto (corta, marca la separación entre
        // cartas del mazo) y una ambiental (amplia, da volumen). Más fuerte
        // en la activa para que flote por delante de la pila.
        .shadow(color: .black.opacity(isActive ? 0.26 : 0.22), radius: isActive ? 10 : 7, x: 0, y: 5)
        .shadow(color: .black.opacity(isActive ? 0.30 : 0.12), radius: isActive ? 30 : 16, x: 0, y: isActive ? 20 : 11)
    }
}
