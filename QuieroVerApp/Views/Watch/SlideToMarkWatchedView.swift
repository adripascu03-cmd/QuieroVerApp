import SwiftUI

/// Interacción "slide to confirm" horizontal. El gesto vive solo en el
/// círculo, así nunca se confunde con el scroll vertical de la ficha.
struct SlideToMarkWatchedView: View {
    var onCompleted: () -> Void

    @State private var dragOffset: CGFloat = 0
    @State private var isCompleting = false

    private let knobSize: CGFloat = 52
    private let horizontalPadding: CGFloat = 4

    var body: some View {
        GeometryReader { geometry in
            let maxOffset = max(geometry.size.width - knobSize - horizontalPadding * 2, 0)

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(.thinMaterial)

                Text("Desliza para marcar como vista")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .opacity(1 - min(dragOffset / max(maxOffset, 1), 1))

                Circle()
                    .fill(Color.accentColor)
                    .frame(width: knobSize, height: knobSize)
                    .overlay(
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.white)
                            .font(.headline)
                    )
                    .offset(x: horizontalPadding + dragOffset)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                guard !isCompleting else { return }
                                dragOffset = min(max(value.translation.width, 0), maxOffset)
                            }
                            .onEnded { _ in
                                guard !isCompleting else { return }
                                if dragOffset >= maxOffset * 0.85 {
                                    complete(maxOffset: maxOffset)
                                } else {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        dragOffset = 0
                                    }
                                }
                            }
                    )
            }
        }
        .frame(height: knobSize + 8)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Marcar como vista")
        .accessibilityAction {
            onCompleted()
        }
    }

    private func complete(maxOffset: CGFloat) {
        isCompleting = true
        Haptics.success()
        withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
            dragOffset = maxOffset
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            onCompleted()
            dragOffset = 0
            isCompleting = false
        }
    }
}

#Preview {
    SlideToMarkWatchedView { }
        .padding()
}
