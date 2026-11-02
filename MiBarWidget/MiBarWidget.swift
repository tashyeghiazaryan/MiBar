import AppIntents
import CoreText
import SwiftUI
import WidgetKit

private enum WidgetFonts {
    static func register() {
        for name in ["Outfit", "NotoSansArmenian", "NotoSerifArmenian"] {
            guard let url = Bundle.main.url(forResource: name, withExtension: "ttf") else { continue }
            CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
        }
    }
}

enum MiBarWidgetStyle: String, AppEnum {
    case classic
    case soft
    case sun
    case clear

    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Style")
    static var caseDisplayRepresentations: [MiBarWidgetStyle: DisplayRepresentation] = [
        .classic: "Classic",
        .soft: "Soft",
        .sun: "Sun",
        .clear: "Clear",
    ]
}

struct MiBarWidgetIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Word of the Day"
    static var description = IntentDescription("Choose a MiBar widget style.")

    @Parameter(title: "Style", default: .classic)
    var style: MiBarWidgetStyle

    func perform() async throws -> some IntentResult {
        .result()
    }
}

struct MiBarEntry: TimelineEntry {
    let date: Date
    let style: MiBarWidgetStyle
}

struct MiBarProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> MiBarEntry {
        MiBarEntry(date: .now, style: .classic)
    }

    func snapshot(for configuration: MiBarWidgetIntent, in context: Context) async -> MiBarEntry {
        MiBarEntry(date: .now, style: configuration.style)
    }

    func timeline(for configuration: MiBarWidgetIntent, in context: Context) async -> Timeline<MiBarEntry> {
        let entry = MiBarEntry(date: .now, style: configuration.style)
        let refresh = Calendar.current.date(byAdding: .hour, value: 1, to: .now) ?? .now.addingTimeInterval(3600)
        return Timeline(entries: [entry], policy: .after(refresh))
    }
}

struct MiBarWidgetEntryView: View {
    var style: MiBarWidgetStyle

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Word of the day")
                .font(.system(size: 11, weight: .bold))
                .tracking(0.8)
                .textCase(.uppercase)
                .foregroundStyle(kicker)
            Spacer(minLength: 0)
            Text("Լույս")
                .font(.custom("Noto Serif Armenian", size: 42).weight(.semibold))
                .foregroundStyle(primary)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
            Text("[luys]")
                .font(.custom("Outfit", size: 16).italic())
                .foregroundStyle(meta)
            Text("light · свет")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(translation)
                .lineLimit(2)
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }

    private var kicker: Color {
        switch style {
        case .classic: return Color(red: 0.949, green: 0.627, blue: 0.494)
        case .soft: return Color(red: 0.914, green: 0.337, blue: 0.137)
        case .sun: return Color.white.opacity(0.8)
        case .clear: return Color(red: 0.051, green: 0.094, blue: 0.275).opacity(0.7)
        }
    }

    private var primary: Color {
        switch style {
        case .classic, .sun: return .white
        case .soft, .clear: return Color(red: 0.051, green: 0.094, blue: 0.275)
        }
    }

    private var meta: Color {
        switch style {
        case .classic: return Color(red: 0.620, green: 0.753, blue: 0.937)
        case .soft, .clear: return Color(red: 0.251, green: 0.431, blue: 0.718)
        case .sun: return Color(red: 1, green: 0.890, blue: 0.831)
        }
    }

    private var translation: Color {
        switch style {
        case .classic: return Color.white.opacity(0.72)
        case .soft: return Color(red: 0.353, green: 0.353, blue: 0.353)
        case .sun: return Color.white.opacity(0.8)
        case .clear: return Color(red: 0.051, green: 0.094, blue: 0.275).opacity(0.78)
        }
    }

    @ViewBuilder
    static func background(for style: MiBarWidgetStyle) -> some View {
        switch style {
        case .classic:
            Color(red: 0.051, green: 0.094, blue: 0.275)
        case .soft:
            Color(red: 0.957, green: 0.945, blue: 0.918)
        case .sun:
            Color(red: 0.914, green: 0.337, blue: 0.137)
        case .clear:
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.565, green: 0.706, blue: 0.847),
                        Color(red: 0.851, green: 0.769, blue: 0.659),
                        Color(red: 0.780, green: 0.627, blue: 0.478),
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                LinearGradient(
                    colors: [Color.white.opacity(0.34), Color.white.opacity(0.14)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
        }
    }
}

struct MiBarWordWidget: Widget {
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: "MiBarWord", intent: MiBarWidgetIntent.self, provider: MiBarProvider()) { entry in
            MiBarWidgetEntryView(style: entry.style)
                .containerBackground(for: .widget) {
                    MiBarWidgetEntryView.background(for: entry.style)
                }
        }
        .configurationDisplayName("MiBar")
        .description("One Armenian word, every day.")
        .supportedFamilies([.systemSmall])
        .contentMarginsDisabled()
    }
}

@main
struct MiBarWidgetBundle: WidgetBundle {
    init() {
        WidgetFonts.register()
    }

    var body: some Widget {
        MiBarWordWidget()
    }
}
