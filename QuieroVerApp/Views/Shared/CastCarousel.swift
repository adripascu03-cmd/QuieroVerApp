import SwiftUI

/// Carrusel horizontal de personas (reparto o dirección/creación).
/// Sin título propio: lo aporta el `SectionBlock` que lo envuelve.
struct CastCarousel: View {
    let people: [PersonDisplayItem]

    var body: some View {
        if !people.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: Spacing.md) {
                    ForEach(people) { person in
                        PersonAvatar(person: person)
                    }
                }
                .padding(.horizontal, Spacing.screenMargin)
            }
            .padding(.horizontal, -Spacing.screenMargin)
        }
    }
}
