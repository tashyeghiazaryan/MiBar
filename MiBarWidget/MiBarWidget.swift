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

private enum MiBarTimeline {
    static func entry(style configurationStyle: MiBarWidgetStyle = .classic) -> MiBarEntry {
        let snapshot = WidgetDataStore.load()
        let style = MiBarWidgetStyle(rawValue: snapshot.style) ?? configurationStyle
        return MiBarEntry(date: .now, style: style, snapshot: snapshot)
    }

    static func nextRefresh() -> Date {
        Calendar.current.date(byAdding: .hour, value: 1, to: .now) ?? .now.addingTimeInterval(3600)
    }
}

struct MiBarProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> MiBarEntry {
        MiBarTimeline.entry(style: .classic)
    }

    func snapshot(for configuration: MiBarWidgetIntent, in context: Context) async -> MiBarEntry {
        MiBarTimeline.entry(style: configuration.style)
    }

    func timeline(for configuration: MiBarWidgetIntent, in context: Context) async -> Timeline<MiBarEntry> {
        Timeline(entries: [MiBarTimeline.entry(style: configuration.style)], policy: .after(MiBarTimeline.nextRefresh()))
    }
}

/// Lock Screen widgets use StaticConfiguration — AppIntent widgets often fail to appear in the Lock Screen gallery.
struct MiBarLockProvider: TimelineProvider {
    func placeholder(in context: Context) -> MiBarEntry {
        MiBarTimeline.entry()
    }

    func getSnapshot(in context: Context, completion: @escaping (MiBarEntry) -> Void) {
        completion(MiBarTimeline.entry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<MiBarEntry>) -> Void) {
        completion(Timeline(entries: [MiBarTimeline.entry()], policy: .after(MiBarTimeline.nextRefresh())))
    }
}

struct MiBarWidgetEntryView: View {
    @Environment(\.widgetFamily) private var family

    var style: MiBarWidgetStyle
    var snapshot: WidgetDataStore.Snapshot

    private var armenian: String { snapshot.armenian }

    var body: some View {
        switch family {
        case .accessoryCircular:
            circularAccessory
        case .accessoryRectangular:
            rectangularAccessory
        case .accessoryInline:
            inlineAccessory
        default:
            homeSmall
        }
    }

    private var circularAccessory: some View {
        Text(armenian)
            .font(.custom("Noto Serif Armenian", size: 18).weight(.semibold))
            .minimumScaleFactor(0.35)
            .lineLimit(2)
            .multilineTextAlignment(.center)
            .widgetAccentable()
            .containerBackground(for: .widget) {
                AccessoryWidgetBackground()
            }
    }

    private var rectangularAccessory: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(snapshot.wordOfTheDayTitle)
                .font(.system(size: 10, weight: .bold))
                .textCase(.uppercase)
                .widgetAccentable()
                .lineLimit(1)
            Text(armenian)
                .font(.custom("Noto Serif Armenian", size: 20).weight(.semibold))
                .minimumScaleFactor(0.45)
                .lineLimit(1)
            Text("[\(snapshot.transliteration)] · \(snapshot.gloss)")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.secondary)
                .minimumScaleFactor(0.6)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .containerBackground(for: .widget) {
            AccessoryWidgetBackground()
        }
    }

    private var inlineAccessory: some View {
        ViewThatFits(in: .horizontal) {
            Text("\(armenian) · \(snapshot.gloss)")
            Text(armenian)
        }
        .font(.system(size: 14, weight: .semibold))
        .minimumScaleFactor(0.7)
        .lineLimit(1)
        .widgetAccentable()
        .containerBackground(for: .widget) {
            Color.clear
        }
    }

    private var homeSmall: some View {
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
        .containerBackground(for: .widget) {
            MiBarWidgetEntryView.background(for: style)
        }
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
        }
        .configurationDisplayName("MiBar")
        .description("One Armenian word, every day.")
        .supportedFamilies([.systemSmall])
        .contentMarginsDisabled()
    }
}

struct MiBarLockScreenWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "MiBarLockScreen", provider: MiBarLockProvider()) { entry in
            MiBarWidgetEntryView(style: entry.style, snapshot: entry.snapshot)
        }
        .configurationDisplayName("MiBar")
        .description("Today’s Armenian word on the Lock Screen.")
        .supportedFamilies([.accessoryCircular, .accessoryRectangular, .accessoryInline])
    }
}

@main
struct MiBarWidgetBundle: WidgetBundle {
    init() {
        WidgetFonts.register()
    }

    var body: some Widget {
        MiBarWordWidget()
        MiBarLockScreenWidget()
    }
}
