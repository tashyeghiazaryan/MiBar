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
    let snapshot: WidgetDataStore.Snapshot
}

struct MiBarProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> MiBarEntry {
        entry(style: .classic)
    }

    func snapshot(for configuration: MiBarWidgetIntent, in context: Context) async -> MiBarEntry {
        entry(style: configuration.style)
    }

    func timeline(for configuration: MiBarWidgetIntent, in context: Context) async -> Timeline<MiBarEntry> {
        let item = entry(style: configuration.style)
        let refresh = Calendar.current.date(byAdding: .hour, value: 1, to: .now) ?? .now.addingTimeInterval(3600)
        return Timeline(entries: [item], policy: .after(refresh))
    }

    /// Prefer the style chosen in the app; fall back to the widget configuration.
    private func entry(style configurationStyle: MiBarWidgetStyle) -> MiBarEntry {
        let snapshot = WidgetDataStore.load()
        let style = MiBarWidgetStyle(rawValue: snapshot.style) ?? configurationStyle
        return MiBarEntry(date: .now, style: style, snapshot: snapshot)
    }
}

struct MiBarWidgetEntryView: View {
    var style: MiBarWidgetStyle
    var snapshot: WidgetDataStore.Snapshot

    private var armenian: String { snapshot.armenian }

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(snapshot.wordOfTheDayTitle)
                .font(.system(size: 11, weight: .bold))
                .tracking(0.8)
                .textCase(.uppercase)
                .foregroundStyle(kicker)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            Spacer(minLength: 0)
            Text(armenian)
                .font(.custom("Noto Serif Armenian", size: wordPointSize).weight(.semibold))
                .tracking(wordTracking)
                .foregroundStyle(primary)
                .lineLimit(1)
                .minimumScaleFactor(0.32)
                .allowsTightening(true)
                .frame(maxWidth: .infinity, alignment: .leading)
                .layoutPriority(1)
            Text("[\(snapshot.transliteration)]")
                .font(.custom("Outfit", size: 16).italic())
                .foregroundStyle(meta)
                .lineLimit(1)
                .minimumScaleFactor(0.55)
                .allowsTightening(true)
            Text(snapshot.gloss)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(translation)
                .lineLimit(2)
                .minimumScaleFactor(0.65)
                .allowsTightening(true)
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }

    private var wordPointSize: CGFloat {
        armenian.count >= 10 ? 34 : (armenian.count >= 7 ? 38 : 42)
    }

    private var wordTracking: CGFloat {
        if armenian.count >= 10 { return -0.4 }
        if armenian.count >= 7 { return -0.8 }
        return -1.2
    }

    private var kicker: Color {
        switch style {
        case .classic: return Color(red: 0.949, green: 0.627, blue: 0.494)
        case .soft: return Color(red: 0.914, green: 0.337, blue: 0.137)
        case .sun: return Color.white.opacity(0.8)
        case .clear: return Color.primary.opacity(0.62)
        }
    }

    private var primary: Color {
        switch style {
        case .classic, .sun: return .white
        case .soft: return Color(red: 0.051, green: 0.094, blue: 0.275)
        case .clear: return .primary
        }
    }

    private var meta: Color {
        switch style {
        case .classic: return Color(red: 0.620, green: 0.753, blue: 0.937)
        case .soft: return Color(red: 0.251, green: 0.431, blue: 0.718)
        case .sun: return Color(red: 1, green: 0.890, blue: 0.831)
        case .clear: return .secondary
        }
    }

    private var translation: Color {
        switch style {
        case .classic: return Color.white.opacity(0.72)
        case .soft: return Color(red: 0.353, green: 0.353, blue: 0.353)
        case .sun: return Color.white.opacity(0.8)
        case .clear: return Color.primary.opacity(0.72)
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
            Rectangle().fill(.ultraThinMaterial)
        }
    }
}

struct MiBarWordWidget: Widget {
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: "MiBarWord", intent: MiBarWidgetIntent.self, provider: MiBarProvider()) { entry in
            MiBarWidgetEntryView(style: entry.style, snapshot: entry.snapshot)
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
