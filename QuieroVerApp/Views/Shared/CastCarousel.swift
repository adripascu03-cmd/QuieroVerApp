import SwiftUI

/// Carrusel horizontal de personas (reparto o dirección/creación).
/// Sin título propio: lo aporta el `SectionBlock` que lo envuelve.
struct CastCarousel: View {
    let people: [PersonDisplayItem]
    var onSelect: ((PersonDisplayItem) -> Void)? = nil

    var body: some View {
        if !people.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: Spacing.md) {
                    ForEach(people) { person in
                        if let onSelect {
                            CastPersonChip(person: person) { onSelect(person) }
                        } else {
                            CastPersonChip(person: person)
                        }
                    }
                }
                .padding(.horizontal, Spacing.screenMargin)
            }
            .padding(.horizontal, -Spacing.screenMargin)
        }
    }
}
