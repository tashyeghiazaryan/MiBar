import Foundation
import WidgetKit

/// Shared snapshot for the Home Screen widget (app + extension via App Group).
enum WidgetDataStore {
    static let suiteName = "group.com.artashesyeghiazaryan.mibar"

    /// Must use the App Group suite — `.standard` is not shared with the widget.
    private static var defaults: UserDefaults {
        guard let suite = UserDefaults(suiteName: suiteName) else {
            assertionFailure("App Group UserDefaults unavailable — check entitlements")
            return .standard
        }
        return suite
    }

    struct Snapshot: Equatable {
        var language: String
        var style: String
        var armenian: String
        var transliteration: String
        var english: String
        var russian: String

        var gloss: String {
            switch language {
            case "ru": return russian
            case "hy": return "\(english) · \(russian)"
            default: return english
            }
        }

        var wordOfTheDayTitle: String {
            switch language {
            case "ru": return "Слово дня"
            case "hy": return "Օրվա բառը"
            default: return "Word of the day"
            }
        }
    }

    static func publish(
        languageCode: String,
        style: String,
        armenian: String,
        transliteration: String,
        english: String,
        russian: String
    ) {
        let store = defaults
        store.set(languageCode, forKey: "language")
        store.set(style, forKey: "style")
        store.set(armenian, forKey: "armenian")
        store.set(transliteration, forKey: "transliteration")
        store.set(english, forKey: "english")
        store.set(russian, forKey: "russian")
        store.synchronize()
        WidgetCenter.shared.reloadAllTimelines()
    }

    static func load() -> Snapshot {
        let store = defaults
        return Snapshot(
            language: store.string(forKey: "language") ?? "en",
            style: store.string(forKey: "style") ?? "classic",
            armenian: store.string(forKey: "armenian") ?? "Սեր",
            transliteration: store.string(forKey: "transliteration") ?? "ser",
            english: store.string(forKey: "english") ?? "love",
            russian: store.string(forKey: "russian") ?? "любовь"
        )
    }
}
