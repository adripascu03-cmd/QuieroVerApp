import SwiftUI

/// Campo secundario y opcional: "¿Por qué quieres verla?".
/// No es un formulario obligatorio, se guarda en cuanto el usuario escribe.
struct ReasonAddedField: View {
    @Bindable var item: MediaItem

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text("¿Por qué quieres verla?")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)

            TextField(
                "Me la recomendaron, me interesa la dirección…",
                text: Binding(
                    get: { item.reasonAdded ?? "" },
                    set: { item.reasonAdded = $0.isEmpty ? nil : $0 }
                ),
                axis: .vertical
            )
            .textFieldStyle(.roundedBorder)
            .lineLimit(1...3)
        }
    }
}
