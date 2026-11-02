import SwiftUI

enum AppScreen: Equatable {
    case email
    case otp
    case language
    case loading
    case main
}

enum AppTab: String, Equatable {
    case today
    case archive
    case favorites
}

enum AppLanguage: String, CaseIterable, Identifiable {
    case en
    case ru
    case hy

    var id: String { rawValue }

    var native: String {
        switch self {
        case .en: return "English"
        case .ru: return "Русский"
        case .hy: return "Հայերեն"
        }
    }

    var sample: String {
        switch self {
        case .en: return "One word a day"
        case .ru: return "Одно слово в день"
        case .hy: return "Մեկ բառ ամեն օր"
        }
    }
}

enum PartOfSpeech: String, Hashable {
    case noun
    case verb
    case adjective
    case adverb

    var title: String {
        switch self {
        case .noun: return "գոյական · noun · сущ."
        case .verb: return "բայ · verb · гл."
        case .adjective: return "ածական · adj. · прил."
        case .adverb: return "մակբայ · adv. · нар."
        }
    }

    var background: Color {
        switch self {
        case .noun: return .navy
        case .verb: return .brandBlue
        case .adjective: return .orangeBrand
        case .adverb: return Color(hex: 0xCFCFCF)
        }
    }

    var foreground: Color {
        self == .adverb ? .black : .white
    }
}

struct Word: Identifiable, Hashable {
    let id: Int
    let armenian: String
    let transliteration: String
    let english: String
    let russian: String
    let date: String
    let phrase: String
    let phraseTransliteration: String
    let phraseEnglish: String
    let phraseRussian: String
    let pos: PartOfSpeech
    let noteEnglish: String?
    let noteRussian: String?
    let noteArmenian: String?

    var dayNumber: String {
        date.split(separator: " ").last.map(String.init) ?? date
    }

    var issueNumber: Int { 108 + id }

    func note(for language: AppLanguage) -> String? {
        switch language {
        case .en: return noteEnglish
        case .ru: return noteRussian ?? noteEnglish
        case .hy: return noteArmenian ?? noteEnglish
        }
    }

    static let catalog: [Word] = [
        Word(
            id: 1,
            armenian: "Լույս",
            transliteration: "luys",
            english: "light",
            russian: "свет",
            date: "June 24",
            phrase: "Բարի լույս, Երևա՛ն։",
            phraseTransliteration: "bari luys, Yerevan",
            phraseEnglish: "Good morning, Yerevan!",
            phraseRussian: "Доброе утро, Ереван!",
            pos: .noun,
            noteEnglish: "“Բարի լույս” literally means “good light” — it’s how people wish each other a good morning in Armenia.",
            noteRussian: "«Բարի լույս» буквально значит «хороший свет» — так в Армении желают доброго утра.",
            noteArmenian: "«Բարի լույս» բառացիորեն նշանակում է «լավ լույս» — այսպես են մաղթում բարի լույս Հայաստանում։"
        ),
        Word(
            id: 2,
            armenian: "Ջան",
            transliteration: "jan",
            english: "dear",
            russian: "дорогой, милая",
            date: "June 23",
            phrase: "Անի ջան, ինչպե՞ս ես։",
            phraseTransliteration: "Ani jan, inchpes es?",
            phraseEnglish: "Ani jan, how are you?",
            phraseRussian: "Ани-джан, как ты?",
            pos: .adjective,
            noteEnglish: "A warm term of affection placed after the name of someone dear to you.",
            noteRussian: "Тёплое обращение, которое ставят после имени дорогого человека.",
            noteArmenian: "Ջերմ դիմելաձև, որ դրվում է սիրելի մարդու անվանից հետո։"
        ),
        Word(
            id: 3,
            armenian: "Տուն",
            transliteration: "tun",
            english: "home",
            russian: "дом",
            date: "June 22",
            phrase: "Ես գնում եմ տուն։",
            phraseTransliteration: "yes gnum em tun",
            phraseEnglish: "I am going home.",
            phraseRussian: "Я иду домой.",
            pos: .noun,
            noteEnglish: nil,
            noteRussian: nil,
            noteArmenian: nil
        ),
        Word(
            id: 4,
            armenian: "Արև",
            transliteration: "arev",
            english: "sun",
            russian: "солнце",
            date: "June 21",
            phrase: "Այսօր արև կա։",
            phraseTransliteration: "aysor arev ka",
            phraseEnglish: "There is sun today.",
            phraseRussian: "Сегодня солнечно.",
            pos: .noun,
            noteEnglish: "The sun is one of the oldest and most recognizable symbols in Armenian culture.",
            noteRussian: "Солнце — один из древнейших и самых узнаваемых символов армянской культуры.",
            noteArmenian: "Արևը հայ մշակույթի ամենահին և ճանաչելի խորհրդանիշներից է։"
        ),
        Word(
            id: 5,
            armenian: "Սիրել",
            transliteration: "sirel",
            english: "to love",
            russian: "любить",
            date: "June 20",
            phrase: "Ես սիրում եմ Երևանը։",
            phraseTransliteration: "yes sirum em Yerevany",
            phraseEnglish: "I love Yerevan.",
            phraseRussian: "Я люблю Ереван.",
            pos: .verb,
            noteEnglish: nil,
            noteRussian: nil,
            noteArmenian: nil
        ),
        Word(
            id: 6,
            armenian: "Ընկեր",
            transliteration: "ynker",
            english: "friend",
            russian: "друг",
            date: "June 19",
            phrase: "Նա իմ լավ ընկերն է։",
            phraseTransliteration: "na im lav ynkern e",
            phraseEnglish: "He is my good friend.",
            phraseRussian: "Он мой хороший друг.",
            pos: .noun,
            noteEnglish: nil,
            noteRussian: nil,
            noteArmenian: nil
        ),
        Word(
            id: 7,
            armenian: "Լավ",
            transliteration: "lav",
            english: "well",
            russian: "хорошо",
            date: "June 18",
            phrase: "Ես լավ եմ։",
            phraseTransliteration: "yes lav em",
            phraseEnglish: "I am well.",
            phraseRussian: "У меня всё хорошо.",
            pos: .adverb,
            noteEnglish: nil,
            noteRussian: nil,
            noteArmenian: nil
        ),
    ]
}

enum HomeWidgetStyle: String, CaseIterable, Identifiable, Hashable {
    case classic
    case soft
    case sun
    case clear

    var id: String { rawValue }

    var name: String { localizedName(for: .en) }

    var hint: String { localizedHint(for: .en) }

    func localizedName(for language: AppLanguage) -> String {
        switch (self, language) {
        case (.classic, .en): return "Classic"
        case (.classic, .ru): return "Классика"
        case (.classic, .hy): return "Դասական"
        case (.soft, .en): return "Soft"
        case (.soft, .ru): return "Мягкий"
        case (.soft, .hy): return "Փափուկ"
        case (.sun, .en): return "Sun"
        case (.sun, .ru): return "Солнце"
        case (.sun, .hy): return "Արև"
        case (.clear, .en): return "Clear"
        case (.clear, .ru): return "Прозрачный"
        case (.clear, .hy): return "Թափանցիկ"
        }
    }

    func localizedHint(for language: AppLanguage) -> String {
        switch (self, language) {
        case (.classic, .en): return "Deep navy"
        case (.classic, .ru): return "Глубокий navy"
        case (.classic, .hy): return "Խորը navy"
        case (.soft, .en): return "Light paper"
        case (.soft, .ru): return "Светлая бумага"
        case (.soft, .hy): return "Բաց թուղթ"
        case (.sun, .en): return "Warm orange"
        case (.sun, .ru): return "Тёплый оранжевый"
        case (.sun, .hy): return "Տաք նարնջագույն"
        case (.clear, .en): return "Wallpaper shows"
        case (.clear, .ru): return "Видны обои"
        case (.clear, .hy): return "Երևում է պաստառը"
        }
    }
}

@MainActor
final class AppModel: ObservableObject {
    @Published var screen: AppScreen = .email
    @Published var language: AppLanguage = .en
    @Published var email = ""
    @Published var savedIDs: [Int] = [1, 5, 2, 7]
    @Published var tab: AppTab = .today
    @Published var detail: Word?
    @Published var openWidgetOnLaunch = false

    var savedWords: [Word] {
        Word.catalog.filter { savedIDs.contains($0.id) }
    }

    func enterMain() {
        savedIDs = [1, 5, 2, 7]
        tab = .today
        detail = nil
        screen = .main
    }

    func logout() {
        email = ""
        detail = nil
        screen = .email
    }

    func toggleSaved(_ id: Int) {
        if let index = savedIDs.firstIndex(of: id) {
            savedIDs.remove(at: index)
        } else {
            savedIDs.append(id)
        }
    }

    func open(_ word: Word) {
        detail = word
    }

    func changeTab(_ next: AppTab) {
        detail = nil
        tab = next
    }

    static func make() -> AppModel {
        let model = AppModel()
        let args = ProcessInfo.processInfo.arguments
        guard let index = args.firstIndex(of: "-startScreen"), args.indices.contains(index + 1) else {
            return model
        }
        switch args[index + 1] {
        case "otp":
            model.email = "name@example.com"
            model.screen = .otp
        case "language":
            model.screen = .language
        case "loading":
            model.screen = .loading
        case "today":
            model.screen = .main
        case "archive":
            model.screen = .main
            model.tab = .archive
        case "favorites":
            model.screen = .main
            model.tab = .favorites
        case "empty":
            model.screen = .main
            model.tab = .favorites
            model.savedIDs = []
        case "widget":
            model.screen = .main
            model.openWidgetOnLaunch = true
        default:
            break
        }
        return model
    }
}
