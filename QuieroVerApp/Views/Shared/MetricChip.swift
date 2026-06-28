import SwiftUI

/// Chip individual de metadato esencial (tipo, año, duración,
/// valoración...), inspirado en la fila de métricas de Listy.
struct MetricChip: View {
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 2) {
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.primary)
                .lineLimit(1)
        }
        .frame(minWidth: 68)
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

/// Fila horizontal de `MetricChip`. No asume padding ambiental propio
/// salvo el "bleed" estándar, pensado para vivir dentro del contenido
/// con margen de pantalla ya aplicado por el padre (igual que
/// `CastCarousel`).
struct MetricChipsRow: View {
    struct Item: Identifiable {
        let label: String
        let value: String
        var id: String { label }
    }

    let chips: [Item]

    var body: some View {
        if !chips.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.xs) {
                    ForEach(chips) { chip in
                        MetricChip(label: chip.label, value: chip.value)
                    }
                }
                .padding(.horizontal, Spacing.screenMargin)
            }
            .padding(.horizontal, -Spacing.screenMargin)
        }
    }
}
