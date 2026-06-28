import SwiftUI

/// Filtro de un solo eje: cada pantalla decide qué subconjunto de casos
/// mostrar. Sustituye los filtros compuestos (tipo + orden + género/
/// dirección) por una elección simple y predecible.
enum LibraryFilter: String, CaseIterable, Identifiable, Equatable {
    case recientes
    case impacto
    case peliculas
    case series
    case directores

    var id: String { rawValue }

    var label: String {
        switch self {
        case .recientes: return "Recientes"
        case .impacto: return "Impacto"
        case .peliculas: return "Películas"
        case .series: return "Series"
        case .directores: return "Directores"
        }
    }

    var mediaType: MediaType? {
        switch self {
        case .peliculas: return .movie
        case .series: return .tv
        case .recientes, .impacto, .directores: return nil
        }
    }
}

/// Barra de píldoras de filtro: fina, con aire lateral real (sin
/// truco de "bleed" — este componente no asume un padding ambiental
/// del padre, así que el margen que declara es el margen real).
struct RefinedFilterPillBar: View {
    let options: [LibraryFilter]
    @Binding var selection: LibraryFilter

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.xs) {
                ForEach(options) { option in
                    Button {
                        selection = option
                    } label: {
                        Text(option.label)
                            .font(.footnote.weight(.semibold))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 7)
                            .background(
                                selection == option ? Color.accentColor : Color(.systemGray6)
                            )
                            .foregroundStyle(selection == option ? Color.white : Color.primary)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(PressableButtonStyle(scale: 0.94))
                }
            }
            .padding(.horizontal, Spacing.screenMargin)
        }
    }
}
