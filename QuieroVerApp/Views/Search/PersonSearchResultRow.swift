import SwiftUI

struct PersonSearchResultRow: View {
    let person: PersonSearchResult

    var body: some View {
        HStack(spacing: Spacing.md) {
            PersonAvatarImage(person: PersonDisplayItem(person), size: 56)

            VStack(alignment: .leading, spacing: 2) {
                Text(person.name)
                    .font(.body.weight(.medium))
                    .lineLimit(1)
                Text(person.roleLabel)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            Text("Persona")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color(.systemGray6), in: Capsule())
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
    }
}
