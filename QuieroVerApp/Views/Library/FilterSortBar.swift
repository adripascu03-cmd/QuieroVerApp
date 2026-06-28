import SwiftUI

enum MediaTypeFilter: String, CaseIterable, Identifiable, Equatable {
    case all
    case movie
    case tv

    var id: String { rawValue }

    var label: String {
        switch self {
        case .all: return "Todo"
        case .movie: return "Película"
        case .tv: return "Serie"
        }
    }

    var mediaType: MediaType? {
        switch self {
        case .all: return nil
        case .movie: return .movie
        case .tv: return .tv
        }
    }
}

/// Chips compactos de filtro por tipo. "Recientes" es el orden por
/// defecto y no necesita control propio en MVP1.
struct TypeFilterChips: View {
    @Binding var selection: MediaTypeFilter

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.xs) {
                ForEach(MediaTypeFilter.allCases) { filter in
                    Button {
                        selection = filter
                    } label: {
                        Text(filter.label)
                            .font(.subheadline.weight(.medium))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(
                                selection == filter ? Color.accentColor.opacity(0.15) : Color(.systemGray6)
                            )
                            .foregroundStyle(selection == filter ? Color.accentColor : Color.primary)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, Spacing.md)
        }
    }
}

/// Orden disponible en Vistas: Recientes (fecha vista) o Impacto.
enum WatchedSortOption: String, CaseIterable, Identifiable, Equatable {
    case recientes
    case impacto

    var id: String { rawValue }

    var label: String {
        switch self {
        case .recientes: return "Recientes"
        case .impacto: return "Impacto"
        }
    }

    var systemImage: String {
        switch self {
        case .recientes: return "clock"
        case .impacto: return "star"
        }
    }
}

struct WatchedSortMenu: View {
    @Binding var selection: WatchedSortOption

    var body: some View {
        Menu {
            ForEach(WatchedSortOption.allCases) { option in
                Button {
                    selection = option
                } label: {
                    if selection == option {
                        Label(option.label, systemImage: "checkmark")
                    } else {
                        Text(option.label)
                    }
                }
            }
        } label: {
            Label(selection.label, systemImage: selection.systemImage)
                .font(.subheadline.weight(.medium))
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(Color(.systemGray6))
                .foregroundStyle(Color.primary)
                .clipShape(Capsule())
        }
    }
}
