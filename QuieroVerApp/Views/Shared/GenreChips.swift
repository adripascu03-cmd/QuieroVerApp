import SwiftUI

struct GenreChips: View {
    let names: [String]

    var body: some View {
        if !names.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.xs) {
                    ForEach(names, id: \.self) { name in
                        Text(name)
                            .font(.caption.weight(.semibold))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(.thinMaterial, in: Capsule())
                            .overlay(Capsule().strokeBorder(Color.primary.opacity(0.08), lineWidth: 1))
                    }
                }
            }
        }
    }
}
