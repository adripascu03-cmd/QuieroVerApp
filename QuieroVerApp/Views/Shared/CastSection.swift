import SwiftUI

/// Carrusel horizontal de personas (reparto o dirección/creación).
struct CastSection: View {
    let title: String
    let people: [PersonDisplayItem]

    var body: some View {
        if !people.isEmpty {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text(title)
                    .font(.headline)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .top, spacing: Spacing.md) {
                        ForEach(people) { person in
                            PersonAvatar(person: person)
                        }
                    }
                }
            }
        }
    }
}
