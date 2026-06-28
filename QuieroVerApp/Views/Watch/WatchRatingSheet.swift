import SwiftUI

/// Modal de cierre reflexivo, tras marcar como vista (o al editar más
/// adelante). No es un formulario: nada es obligatorio salvo la fecha,
/// que ya viene rellenada por defecto. Cada bloque vive en su propia
/// tarjeta de material translúcido, consistente con el resto de la app.
struct RefinedCompletionSheet: View {
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
                VStack(alignment: .leading, spacing: Spacing.xl) {
                    impactCard
                    noteCard
                    dateRow

                    PrimaryGlassButton(title: "Guardar en Vistas", systemImage: "checkmark") {
                        save()
                    }
                    .padding(.top, Spacing.xs)
                }
                .padding(Spacing.screenMargin)
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

    private var impactCard: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack {
                Text("Impacto personal")
                    .font(.headline)
                Spacer()
                ImpactBadge(value: impact)
            }
            Slider(value: $impact, in: 0...10, step: 0.5)
                .tint(Color.accentColor)
        }
        .padding(Spacing.md)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius, style: .continuous))
        .glassBorder(cornerRadius: AppTheme.cardCornerRadius)
    }

    private var noteCard: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Tu nota")
                .font(.headline)
            TextField(
                "Escribe una impresión, una frase, una idea o lo que quieras recordar.",
                text: $note,
                axis: .vertical
            )
            .lineLimit(4...8)
        }
        .padding(Spacing.md)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius, style: .continuous))
        .glassBorder(cornerRadius: AppTheme.cardCornerRadius)
    }

    private var dateRow: some View {
        HStack {
            Text("Fecha vista")
                .font(.subheadline.weight(.medium))
            Spacer()
            DatePicker("Fecha vista", selection: $watchedAt, in: ...Date.now, displayedComponents: .date)
                .labelsHidden()
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.sm)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius, style: .continuous))
        .glassBorder(cornerRadius: AppTheme.cardCornerRadius)
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
