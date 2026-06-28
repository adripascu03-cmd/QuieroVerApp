import SwiftUI

/// Bottom sheet de cierre tras marcar como vista (o al editar más
/// adelante): valoración por estrellas + nota + fecha. Nada obligatorio
/// salvo la fecha, que ya viene rellenada por defecto.
///
/// `personalImpact` sigue siendo 0-10 en el modelo; aquí solo se
/// presenta como 1-5 estrellas (×2 al guardar) para no tocar el dato
/// persistido ni migrar nada.
struct WatchRatingSheet: View {
    @Bindable var item: MediaItem
    @Environment(\.dismiss) private var dismiss

    @State private var rating: Int
    @State private var note: String
    @State private var watchedAt: Date

    /// `initialRating` ya viene elegido si se llega desde el flujo de
    /// "marcar como vista" (selector de estrellas en la propia ficha).
    /// Si se omite (p. ej. al editar un item ya visto), se deriva del
    /// impacto ya guardado.
    init(item: MediaItem, initialRating: Int? = nil) {
        self.item = item
        let derived = initialRating ?? Int(((item.personalImpact ?? 6) / 2).rounded())
        _rating = State(initialValue: min(max(derived, 1), 5))
        _note = State(initialValue: item.personalNote ?? "")
        _watchedAt = State(initialValue: item.watchedAt ?? .now)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.xl) {
                    ratingCard
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

    private var ratingCard: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Impacto personal")
                .font(.headline)
            StarRatingPicker(rating: $rating)
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
            impact: Double(rating) * 2,
            note: note.isEmpty ? nil : note,
            watchedAt: watchedAt
        )
        Haptics.success()
        dismiss()
    }
}
