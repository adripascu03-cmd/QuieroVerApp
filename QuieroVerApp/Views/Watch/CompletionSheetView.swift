import SwiftUI

/// Modal de cierre reflexivo, tras marcar como vista (o al editar más
/// adelante). No es un formulario: nada es obligatorio salvo la fecha,
/// que ya viene rellenada por defecto.
struct CompletionSheetView: View {
    @Bindable var item: MediaItem
    @Environment(\.dismiss) private var dismiss

    @State private var impact: Double
    @State private var note: String
    @State private var watchedAt: Date

    init(item: MediaItem) {
        self.item = item
        _impact = State(initialValue: item.personalImpact ?? 5)
        _note = State(initialValue: item.personalNote ?? "")
        _watchedAt = State(initialValue: item.watchedAt ?? .now)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.lg) {
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text("Impacto personal")
                            .font(.headline)
                        HStack(spacing: Spacing.sm) {
                            Slider(value: $impact, in: 0...10, step: 0.5)
                            Text(formattedImpact)
                                .font(.subheadline.weight(.semibold))
                                .frame(width: 36, alignment: .trailing)
                                .monospacedDigit()
                        }
                    }

                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text("Tu nota")
                            .font(.headline)
                        TextField(
                            "Escribe una impresión, una frase, una idea o lo que quieras recordar.",
                            text: $note,
                            axis: .vertical
                        )
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(4...8)
                    }

                    DatePicker("Fecha vista", selection: $watchedAt, in: ...Date.now, displayedComponents: .date)

                    Button {
                        save()
                    } label: {
                        Text("Guardar en Vistas")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, Spacing.xs)
                    }
                    .buttonStyle(.borderedProminent)
                    .clipShape(Capsule())
                    .padding(.top, Spacing.sm)
                }
                .padding(Spacing.md)
            }
            .navigationTitle("¿Qué te ha dejado?")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancelar") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    private var formattedImpact: String {
        impact.rounded() == impact ? String(format: "%.0f", impact) : String(format: "%.1f", impact)
    }

    private func save() {
        item.markAsWatched(
            impact: impact,
            note: note.isEmpty ? nil : note,
            watchedAt: watchedAt
        )
        Haptics.success()
        dismiss()
    }
}
