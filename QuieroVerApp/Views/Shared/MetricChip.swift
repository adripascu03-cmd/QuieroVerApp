import SwiftUI

/// Chip individual de metadato esencial (tipo, año, duración,
/// valoración...), inspirado en la fila de métricas de Listy. Compacto
/// y de altura uniforme.
struct MetricChip: View {
    struct Item: Identifiable {
        let label: String
        let value: String
        var id: String { label }
    }

    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 3) {
            Text(label.uppercased())
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .padding(.horizontal, 6)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

/// Fila de métricas de ancho fijo: reparte el ancho disponible entre
/// los chips (hasta 4) en lugar de hacer scroll horizontal. Así nunca
/// se corta el último chip contra el borde — el bug de "márgenes rotos"
/// de la versión anterior. El padre aplica el margen de pantalla.
struct MetricChipsRow: View {
    let chips: [MetricChip.Item]

    var body: some View {
        if !chips.isEmpty {
            HStack(spacing: Spacing.xs) {
                ForEach(chips) { chip in
                    MetricChip(label: chip.label, value: chip.value)
                }
            }
        }
    }
}
