import SwiftUI

enum LibraryTab: Int, CaseIterable, Identifiable, Hashable {
    case quieroVer
    case vistas

    var id: Int { rawValue }

    var label: String {
        switch self {
        case .quieroVer: return "Quiero ver"
        case .vistas: return "Vistas"
        }
    }
}

/// Navegación inferior custom: cápsula flotante translúcida con un
/// "blob" que se desliza tras la opción activa. Sustituye la tab bar
/// estándar — no usa `tabItem`/iconos, solo texto, deliberadamente.
struct LiquidTabBar: View {
    @Binding var selection: LibraryTab
    @Namespace private var blobNamespace

    var body: some View {
        HStack(spacing: 2) {
            ForEach(LibraryTab.allCases) { tab in
                tabButton(tab)
            }
        }
        .padding(4)
        .background(.thinMaterial, in: Capsule())
        .overlay(Capsule().strokeBorder(.white.opacity(0.22), lineWidth: 1))
        .shadow(color: .black.opacity(0.16), radius: 14, x: 0, y: 6)
        .shadow(color: .black.opacity(0.10), radius: 28, x: 0, y: 14)
        .padding(.horizontal, Spacing.xl)
        .padding(.bottom, Spacing.xs)
    }

    @ViewBuilder
    private func tabButton(_ tab: LibraryTab) -> some View {
        let isSelected = selection == tab

        Button {
            selectTab(tab)
        } label: {
            Text(tab.label)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(isSelected ? Color.white : Color.secondary.opacity(0.85))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 11)
                .background {
                    if isSelected {
                        Capsule()
                            .fill(Color.accentColor)
                            .shadow(color: Color.accentColor.opacity(0.5), radius: 8, x: 0, y: 3)
                            .matchedGeometryEffect(id: "liquidTabBlob", in: blobNamespace)
                    }
                }
        }
        .buttonStyle(.plain)
    }

    private func selectTab(_ tab: LibraryTab) {
        guard selection != tab else { return }
        Haptics.light()
        withAnimation(.spring(response: 0.45, dampingFraction: 0.82)) {
            selection = tab
        }
    }
}

private struct LiquidTabBarPreview: View {
    @State private var selection: LibraryTab = .quieroVer

    var body: some View {
        ZStack(alignment: .bottom) {
            Color(.systemGroupedBackground).ignoresSafeArea()
            LiquidTabBar(selection: $selection)
        }
    }
}

#Preview {
    LiquidTabBarPreview()
}
