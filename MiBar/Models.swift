import SwiftUI

enum AppScreen: Equatable {
    case welcome
    case email
    case login
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

    /// Single gloss matching the UI language chosen at registration.
    func gloss(for language: AppLanguage) -> String {
        switch language {
        case .en: return english
        case .ru: return russian
        case .hy: return "\(english) · \(russian)"
        }
    }

    /// Example sentence translation for the UI language (one language only for en/ru).
    func phraseTranslation(for language: AppLanguage) -> String {
        switch language {
        case .en, .hy: return phraseEnglish
        case .ru: return phraseRussian
        }
    }

    /// First 30 MiBar words (day 1 = today's word).
    static let catalog: [Word] = [
        Word(
            id: 1, armenian: "Ժպիտ", transliteration: "zhpit",
            english: "smile", russian: "улыбка", date: "1",
            phrase: "Քո ժպիտը շատ գեղեցիկ է։", phraseTransliteration: "K'o zhpitə shat geghetsik e.",
            phraseEnglish: "Your smile is very beautiful.", phraseRussian: "Твоя улыбка очень красивая.",
            pos: .noun,
            noteEnglish: "A smile is one of the simplest ways to express warmth without saying a word.",
            noteRussian: "Улыбка — один из самых простых способов выразить тепло без слов.",
            noteArmenian: nil
        ),
        Word(
            id: 2, armenian: "Հույս", transliteration: "huys",
            english: "hope", russian: "надежда", date: "2",
            phrase: "Հույս ունեմ, որ վաղը լավ օր կլինի։", phraseTransliteration: "Huys unem, vor vaghə lav or klini.",
            phraseEnglish: "I hope tomorrow will be a good day.", phraseRussian: "Надеюсь, завтра будет хороший день.",
            pos: .noun,
            noteEnglish: "This word often appears when talking about the future and believing things can turn out well.",
            noteRussian: "Это слово встречается в разговорах о будущем и вере в то, что всё может сложиться хорошо.",
            noteArmenian: nil
        ),
        Word(
            id: 3, armenian: "Անձրև", transliteration: "andzrev",
            english: "rain", russian: "дождь", date: "3",
            phrase: "Այսօր անձրև է գալիս։", phraseTransliteration: "Aysor andzrev e galis.",
            phraseEnglish: "It's raining today.", phraseRussian: "Сегодня идёт дождь.",
            pos: .noun,
            noteEnglish: "“Անձրև է գալիս” is how you say “It’s raining” in Armenian. Literally, the phrase means “The rain is coming.”",
            noteRussian: "«Անձրև է գալիս» — так по-армянски говорят, что идёт дождь. Буквально фраза означает «дождь приходит».",
            noteArmenian: nil
        ),
        Word(
            id: 4, armenian: "Ծիածան", transliteration: "tsiatsan",
            english: "rainbow", russian: "радуга", date: "4",
            phrase: "Անձրևից հետո ծիածան տեսանք։", phraseTransliteration: "Andzrevits heto tsiatsan tesank.",
            phraseEnglish: "We saw a rainbow after the rain.", phraseRussian: "После дождя мы увидели радугу.",
            pos: .noun,
            noteEnglish: "Picture a colorful sky after the rain. Sometimes an image helps you remember a word better than a translation.",
            noteRussian: "Представь цветное небо после дождя. Иногда образ помогает запомнить слово лучше, чем перевод.",
            noteArmenian: nil
        ),
        Word(
            id: 5, armenian: "Գաղտնիք", transliteration: "gaghtnik",
            english: "secret", russian: "секрет", date: "5",
            phrase: "Սա մեր փոքրիկ գաղտնիքն է։", phraseTransliteration: "Sa mer pokrik gaghtnikn e.",
            phraseEnglish: "This is our little secret.", phraseRussian: "Это наш маленький секрет.",
            pos: .noun,
            noteEnglish: "A secret can be something serious, a little surprise, or a story you’re not ready to share yet.",
            noteRussian: "Секретом может быть нечто серьёзное, маленький сюрприз или история, которой пока не хочется делиться.",
            noteArmenian: nil
        ),
        Word(
            id: 6, armenian: "Հեքիաթ", transliteration: "hekiat",
            english: "fairy tale", russian: "сказка", date: "6",
            phrase: "Երեկոյան մայրս ինձ համար հեքիաթ է կարդում։", phraseTransliteration: "Yerekoyan mayrs indz hamar hekiat e kardum.",
            phraseEnglish: "My mother reads me a fairy tale in the evening.", phraseRussian: "Вечером мама читает мне сказку.",
            pos: .noun,
            noteEnglish: "This word is used for more than children's fairy tales. It can also describe something magical or extraordinary.",
            noteRussian: "Это слово подходит не только для детских сказок, но и для описания чего-то удивительного, словно из волшебной истории.",
            noteArmenian: nil
        ),
        Word(
            id: 7, armenian: "Բույր", transliteration: "buyr",
            english: "scent, fragrance", russian: "аромат", date: "7",
            phrase: "Սենյակում թարմ ծաղիկների բույր կա։", phraseTransliteration: "Senyakum tarm tsaghikneri buyr ka.",
            phraseEnglish: "There is a scent of fresh flowers in the room.", phraseRussian: "В комнате стоит аромат свежих цветов.",
            pos: .noun,
            noteEnglish: "Think of the scent of fresh coffee, flowers, or summer apricots. This word comes alive through the senses.",
            noteRussian: "Представь запах свежего кофе, цветов или абрикосов летом. Слово особенно хорошо раскрывается через ощущения.",
            noteArmenian: nil
        ),
        Word(
            id: 8, armenian: "Երազ", transliteration: "eraz",
            english: "dream", russian: "сон, мечта", date: "8",
            phrase: "Երեկ գիշեր մի տարօրինակ երազ տեսա։", phraseTransliteration: "Yerek gisher mi tarorinak eraz tesa.",
            phraseEnglish: "Last night I had a strange dream.", phraseRussian: "Прошлой ночью мне приснился странный сон.",
            pos: .noun,
            noteEnglish: "Context tells you whether it means a dream you have at night or a dream you hope to achieve.",
            noteRussian: "Контекст помогает понять, о чём речь: о сне ночью или о мечте, к которой человек стремится.",
            noteArmenian: nil
        ),
        Word(
            id: 9, armenian: "Կարոտ", transliteration: "karot",
            english: "longing, yearning", russian: "тоска, томление", date: "9",
            phrase: "Ես շատ եմ կարոտում իմ ընտանիքին։", phraseTransliteration: "Yes shat em karotum im yntanik'in.",
            phraseEnglish: "I miss my family very much.", phraseRussian: "Я очень скучаю по своей семье.",
            pos: .noun,
            noteEnglish: "This is the feeling of missing someone or something: a loved one, home, or a place you long to return to.",
            noteRussian: "Это чувство, когда тебе кого-то или чего-то не хватает: близкого человека, дома или места, по которому скучаешь.",
            noteArmenian: nil
        ),
        Word(
            id: 10, armenian: "Հուշ", transliteration: "hush",
            english: "memory, recollection", russian: "воспоминание", date: "10",
            phrase: "Սա մանկությանս ամենաջերմ հուշերից մեկն է։", phraseTransliteration: "Sa mankut'yans amenajerm husherits mekn e.",
            phraseEnglish: "This is one of my warmest childhood memories.", phraseRussian: "Это одно из самых тёплых воспоминаний моего детства.",
            pos: .noun,
            noteEnglish: "Sometimes a memory isn't a whole story, but a scent, a voice, or a fleeting moment that stays with you.",
            noteRussian: "Иногда воспоминание — это не целая история, а запах, голос или мгновение, которое осталось с тобой.",
            noteArmenian: nil
        ),
        Word(
            id: 11, armenian: "Ուրախություն", transliteration: "urakhutyun",
            english: "joy, happiness", russian: "радость", date: "11",
            phrase: "Երեխաների ծիծաղը մեծ ուրախություն է բերում։", phraseTransliteration: "Yerekhaneri tsitsaghe mets urakhutyun e berum.",
            phraseEnglish: "Children's laughter brings great joy.", phraseRussian: "Детский смех приносит большую радость.",
            pos: .noun,
            noteEnglish: "This word is useful not only for describing emotions, but also for congratulations and warm wishes.",
            noteRussian: "Слово пригодится не только для описания эмоций, но и в поздравлениях и тёплых пожеланиях.",
            noteArmenian: nil
        ),
        Word(
            id: 12, armenian: "Սիրուն", transliteration: "sirun",
            english: "pretty, lovely", russian: "красивый, милый", date: "12",
            phrase: "Ի՜նչ սիրուն ծաղիկներ են։", phraseTransliteration: "Inch sirun tsaghikner en!",
            phraseEnglish: "What pretty flowers!", phraseRussian: "Какие красивые цветы!",
            pos: .adjective,
            noteEnglish: "A casual, affectionate way to describe a person, an object, or a place as lovely or pretty.",
            noteRussian: "Подходит для простого, непринуждённого комплимента человеку, вещи или месту.",
            noteArmenian: nil
        ),
        Word(
            id: 13, armenian: "Հաճելի", transliteration: "hacheli",
            english: "pleasant, enjoyable", russian: "приятный", date: "13",
            phrase: "Քեզ հետ շատ հաճելի էր զրուցել։", phraseTransliteration: "K'ez het shat hacheli er zrutsel.",
            phraseEnglish: "It was very nice talking to you.", phraseRussian: "Было очень приятно с тобой поговорить.",
            pos: .adjective,
            noteEnglish: "You can use this word for more than objects — a pleasant atmosphere, conversation, or evening, too.",
            noteRussian: "Можно описать не только предмет, но и атмосферу, разговор или вечер.",
            noteArmenian: nil
        ),
        Word(
            id: 14, armenian: "Խաղաղություն", transliteration: "khaghaghutyun",
            english: "peace, tranquility", russian: "мир, спокойствие", date: "14",
            phrase: "Բոլորին խաղաղություն եմ մաղթում։", phraseTransliteration: "Bolorin khaghaghutyun em maghtum.",
            phraseEnglish: "I wish everyone peace.", phraseRussian: "Желаю всем мира.",
            pos: .noun,
            noteEnglish: "Depending on the context, this word can mean peace without war or a sense of calm and tranquility.",
            noteRussian: "Слово может обозначать и мир без войны, и спокойствие — в зависимости от контекста.",
            noteArmenian: nil
        ),
        Word(
            id: 15, armenian: "Ճանապարհ", transliteration: "chanaparh",
            english: "road, journey", russian: "дорога, путь", date: "15",
            phrase: "Այս ճանապարհը տանում է դեպի լիճ։", phraseTransliteration: "Ays chanaparhə tanum e depi lich.",
            phraseEnglish: "This road leads to the lake.", phraseRussian: "Эта дорога ведёт к озеру.",
            pos: .noun,
            noteEnglish: "“Բարի ճանապարհ” is a way to wish someone a good journey. A road can also symbolize the path through life.",
            noteRussian: "«Բարի ճանապարհ» — пожелание хорошей дороги перед поездкой. Дорога также может стать образом жизненного пути.",
            noteArmenian: nil
        ),
        Word(
            id: 16, armenian: "Պատուհան", transliteration: "patuhan",
            english: "window", russian: "окно", date: "16",
            phrase: "Խնդրում եմ, բացիր պատուհանը։", phraseTransliteration: "Khndrum em, batsir patuhanə.",
            phraseEnglish: "Please open the window.", phraseRussian: "Пожалуйста, открой окно.",
            pos: .noun,
            noteEnglish: "A window connects your own space with the outside world — a place to watch the street, the weather, and the changing seasons.",
            noteRussian: "Окно — граница между своим пространством и внешним миром: через него наблюдают за улицей, погодой и сменой времён года.",
            noteArmenian: nil
        ),
        Word(
            id: 17, armenian: "Անկյուն", transliteration: "ankyun",
            english: "corner, angle", russian: "угол", date: "17",
            phrase: "Կատուն քնած է բազմոցի անկյունում։", phraseTransliteration: "Katun knats e bazmotsi ankyunum.",
            phraseEnglish: "The cat is sleeping in the corner of the sofa.", phraseRussian: "Кошка спит в углу дивана.",
            pos: .noun,
            noteEnglish: "It can mean the corner of a room or an angle in geometry — one word connecting everyday spaces with abstract ideas.",
            noteRussian: "Это может быть угол комнаты или геометрический угол. Одно слово объединяет знакомые предметы и абстрактные понятия.",
            noteArmenian: nil
        ),
        Word(
            id: 18, armenian: "Պահ", transliteration: "pah",
            english: "moment", russian: "мгновение", date: "18",
            phrase: "Մի պահ սպասիր, խնդրում եմ։", phraseTransliteration: "Mi pah spasir, khndrum em.",
            phraseEnglish: "Wait a moment, please.", phraseRussian: "Подожди минутку, пожалуйста.",
            pos: .noun,
            noteEnglish: "“Մի պահ” means “just a moment.” It's a useful phrase when you need someone to wait briefly.",
            noteRussian: "«Մի պահ» означает «на мгновение». Полезное выражение, когда нужно попросить немного подождать.",
            noteArmenian: nil
        ),
        Word(
            id: 19, armenian: "Լուսանկար", transliteration: "lusankar",
            english: "photograph, photo", russian: "фотография", date: "19",
            phrase: "Միասին լուսանկար անենք։", phraseTransliteration: "Miasin lusankar anenk.",
            phraseEnglish: "Let's take a photo together.", phraseRussian: "Давай сфотографируемся вместе.",
            pos: .noun,
            noteEnglish: "A photograph captures one moment, not the whole story. Sometimes a single image brings back so much more.",
            noteRussian: "Фотография сохраняет один момент, но не всю историю. Иногда одного кадра достаточно, чтобы вспомнить гораздо больше.",
            noteArmenian: nil
        ),
        Word(
            id: 20, armenian: "Պատմություն", transliteration: "patmutyun",
            english: "story, history", russian: "рассказ, история", date: "20",
            phrase: "Պապիկս ինձ հետաքրքիր պատմություններ է պատմում։", phraseTransliteration: "Papiks indz hetak'rkir patmut'yunner e patmum.",
            phraseEnglish: "My grandfather tells me interesting stories.", phraseRussian: "Дедушка рассказывает мне интересные истории.",
            pos: .noun,
            noteEnglish: "The same word can mean a story or history as the past. The context tells you which meaning applies.",
            noteRussian: "Одно слово используется и для рассказа, и для истории как прошлого. Точный смысл подсказывает контекст.",
            noteArmenian: nil
        ),
        Word(
            id: 21, armenian: "Հաջողություն", transliteration: "hajoghutyun",
            english: "success, good luck", russian: "успех, удача", date: "21",
            phrase: "Քեզ հաջողություն եմ մաղթում։", phraseTransliteration: "K'ez hajoghutyun em maghtum.",
            phraseEnglish: "I wish you good luck.", phraseRussian: "Желаю тебе удачи.",
            pos: .noun,
            noteEnglish: "“Հաջողություն!” is a way to wish someone good luck before an exam, a meeting, or a new beginning.",
            noteRussian: "«Հաջողություն!» — пожелание удачи перед экзаменом, встречей или новым начинанием.",
            noteArmenian: nil
        ),
        Word(
            id: 22, armenian: "Հիշել", transliteration: "hishel",
            english: "to remember", russian: "помнить, вспоминать", date: "22",
            phrase: "Ես միշտ հիշում եմ այդ օրը։", phraseTransliteration: "Yes misht hisum em ayd orə.",
            phraseEnglish: "I always remember that day.", phraseRussian: "Я всегда помню тот день.",
            pos: .verb,
            noteEnglish: "Remembering isn't just recalling facts. It can also mean keeping a connection to people, places, and moments.",
            noteRussian: "Вспоминать — не только извлекать факты из памяти, но и сохранять связь с людьми, местами и моментами.",
            noteArmenian: nil
        ),
        Word(
            id: 23, armenian: "Մոռանալ", transliteration: "moranal",
            english: "to forget", russian: "забывать", date: "23",
            phrase: "Մի մոռացիր վերցնել բանալիներդ։", phraseTransliteration: "Mi moratsir vertsnel banalinerd.",
            phraseEnglish: "Don't forget to take your keys.", phraseRussian: "Не забудь взять ключи.",
            pos: .verb,
            noteEnglish: "You can forget an item, an appointment, or a promise. This word comes up often in everyday life.",
            noteRussian: "Можно забыть вещь, встречу или обещание. Это слово часто встречается в обычных бытовых ситуациях.",
            noteArmenian: nil
        ),
        Word(
            id: 24, armenian: "Սպասել", transliteration: "spasel",
            english: "to wait, to expect", russian: "ждать, ожидать", date: "24",
            phrase: "Ես քեզ այստեղ կսպասեմ։", phraseTransliteration: "Yes k'ez aystegh k'spasem.",
            phraseEnglish: "I'll wait for you here.", phraseRussian: "Я буду ждать тебя здесь.",
            pos: .verb,
            noteEnglish: "You don't only wait for people — you can also wait for news, an answer, or an important event.",
            noteRussian: "Ждут не только человека, но и новость, ответ или важное событие.",
            noteArmenian: nil
        ),
        Word(
            id: 25, armenian: "Գտնել", transliteration: "gtnel",
            english: "to find", russian: "находить", date: "25",
            phrase: "Ես վերջապես գտա բանալիներս։", phraseTransliteration: "Yes verjapes gta banaliners.",
            phraseEnglish: "I finally found my keys.", phraseRussian: "Наконец-то ключи нашлись.",
            pos: .verb,
            noteEnglish: "You can find a lost item, a solution, or even the right words.",
            noteRussian: "Можно найти потерянную вещь, решение или нужные слова.",
            noteArmenian: nil
        ),
        Word(
            id: 26, armenian: "Փնտրել", transliteration: "pntrel",
            english: "to search for, to look for", russian: "искать", date: "26",
            phrase: "Ես փնտրում եմ իմ հեռախոսը։", phraseTransliteration: "Yes pnt'rum em im herakhosə.",
            phraseEnglish: "I'm looking for my phone.", phraseRussian: "Я ищу свой телефон.",
            pos: .verb,
            noteEnglish: "Searching doesn't mean you've found what you're looking for yet. Compare this word with “գտնել” — “to find.”",
            noteRussian: "Поиск ещё не означает, что ответ уже найден. Сравни это слово с «գտնել» — «находить».",
            noteArmenian: nil
        ),
        Word(
            id: 27, armenian: "Ծիծաղել", transliteration: "tsitsaghel",
            english: "to laugh", russian: "смеяться", date: "27",
            phrase: "Մենք միասին շատ ծիծաղեցինք։", phraseTransliteration: "Menk miasin shat tsitsaghetsink.",
            phraseEnglish: "We laughed a lot together.", phraseRussian: "Мы много смеялись вместе.",
            pos: .verb,
            noteEnglish: "Compare it with “ժպիտ” — “smile”: one word describes laughing, the other a facial expression.",
            noteRussian: "Сравни с «ժպիտ» — «улыбка»: одно слово описывает смех, другое — выражение лица.",
            noteArmenian: nil
        ),
        Word(
            id: 28, armenian: "Կատակ", transliteration: "katak",
            english: "joke", russian: "шутка", date: "28",
            phrase: "Նա միշտ լավ կատակներ է պատմում։", phraseTransliteration: "Na misht lav katakner e patmum.",
            phraseEnglish: "He always tells good jokes.", phraseRussian: "Он всегда рассказывает хорошие шутки.",
            pos: .noun,
            noteEnglish: "“Կատակ եմ անում” means “I'm joking.” It's useful when you want to make sure your words aren't taken too seriously.",
            noteRussian: "«Կատակ եմ անում» означает «я шучу». Такая фраза помогает уточнить намерение, если слова могут прозвучать слишком серьёзно.",
            noteArmenian: nil
        ),
        Word(
            id: 29, armenian: "Գրկել", transliteration: "grkel",
            english: "to hug, to embrace", russian: "обнимать", date: "29",
            phrase: "Ես ուզում եմ քեզ գրկել։", phraseTransliteration: "Yes uzum em k'ez grkel.",
            phraseEnglish: "I want to hug you.", phraseRussian: "Я хочу тебя обнять.",
            pos: .verb,
            noteEnglish: "A hug can express the joy of seeing someone, offer comfort, or show how much you've missed them.",
            noteRussian: "Объятие может передавать радость встречи, поддержку или то, что человек скучал.",
            noteArmenian: nil
        ),
        Word(
            id: 30, armenian: "Ընկերություն", transliteration: "ynkerutyun",
            english: "friendship, company", russian: "дружба, компания", date: "30",
            phrase: "Մեր ընկերությունը ինձ համար շատ թանկ է։", phraseTransliteration: "Mer ynkerutyunə indz hamar shat tank e.",
            phraseEnglish: "Our friendship is very dear to me.", phraseRussian: "Наша дружба мне очень дорога.",
            pos: .noun,
            noteEnglish: "This word can mean friendship or a company as an organization. The context tells you which meaning is intended.",
            noteRussian: "Слово может означать дружбу или компанию как организацию. Значение зависит от контекста.",
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
        case (.clear, .en): return "Frosted glass"
        case (.clear, .ru): return "Матовое стекло"
        case (.clear, .hy): return "Անփայլ ապակի"
        }
    }
}

enum SupportTopic: String, CaseIterable, Identifiable, Hashable {
    case problem
    case feedback
    case other

    var id: String { rawValue }

    func title(copy: L10n) -> String {
        switch self {
        case .problem: return copy.supportTopicProblem
        case .feedback: return copy.supportTopicFeedback
        case .other: return copy.supportTopicOther
        }
    }
}

struct SupportChatMessage: Identifiable, Equatable, Hashable {
    enum Role: String, Equatable, Hashable {
        case support
        case user
        case typing
    }

    let id: UUID
    let role: Role
    let text: String

    init(role: Role, text: String = "") {
        self.id = UUID()
        self.role = role
        self.text = text
    }
}

struct FavoriteFolder: Identifiable, Equatable, Hashable {
    let id: UUID
    var name: String
    var wordIDs: [Int]
    var createdAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        wordIDs: [Int] = [],
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.wordIDs = wordIDs
        self.createdAt = createdAt
    }

    var words: [Word] {
        wordIDs.compactMap { id in Word.catalog.first(where: { $0.id == id }) }
    }
}

struct SupportConversation: Identifiable, Equatable, Hashable {
    let id: UUID
    var topic: SupportTopic
    var messages: [SupportChatMessage]
    var didAutoReply: Bool
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        topic: SupportTopic = .problem,
        messages: [SupportChatMessage] = [],
        didAutoReply: Bool = false,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.topic = topic
        self.messages = messages
        self.didAutoReply = didAutoReply
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    var previewText: String {
        messages.last(where: { $0.role == .user || $0.role == .support })?.text ?? ""
    }
}

@MainActor
final class AppModel: ObservableObject {
    @Published var screen: AppScreen = .welcome
    @Published var language: AppLanguage = .en {
        didSet { syncWidget() }
    }
    @Published var widgetStyle: HomeWidgetStyle = .classic {
        didSet { syncWidget() }
    }
    @Published var email = ""
    /// True when the user chose “I already have an account” on the email screen.
    @Published var isReturningUser = false
    /// Preference for “new word” push when the word of the day changes (no fixed clock time).
    @Published var dailyReminderEnabled = true
    /// Words saved to the default “General” collection.
    @Published var savedIDs: [Int] = [1, 5, 2, 7]
    @Published var favoriteFolders: [FavoriteFolder] = []
    @Published var tab: AppTab = .today
    @Published var detail: Word?
    @Published var openWidgetOnLaunch = false

    /// Support inbox — each request is its own conversation.
    @Published var supportConversations: [SupportConversation] = []

    var sortedSupportConversations: [SupportConversation] {
        supportConversations
            .filter { conversation in
                conversation.messages.contains { $0.role == .user || $0.role == .support }
            }
            .sorted { $0.updatedAt > $1.updatedAt }
    }

    var sortedFavoriteFolders: [FavoriteFolder] {
        favoriteFolders.sorted { $0.createdAt > $1.createdAt }
    }

    /// All words that live only in the General collection.
    var savedWords: [Word] {
        Word.catalog.filter { savedIDs.contains($0.id) }
    }

    var allFavoriteWordIDs: Set<Int> {
        var ids = Set(savedIDs)
        for folder in favoriteFolders {
            ids.formUnion(folder.wordIDs)
        }
        return ids
    }

    var allFavoriteCount: Int { allFavoriteWordIDs.count }

    var todayWord: Word { Word.catalog[0] }

    func isSaved(_ id: Int) -> Bool {
        allFavoriteWordIDs.contains(id)
    }

    func enterMain() {
        savedIDs = [1, 5, 2, 7]
        favoriteFolders = []
        tab = .today
        detail = nil
        screen = .main
        syncWidget()
    }

    func logout() {
        email = ""
        isReturningUser = false
        detail = nil
        favoriteFolders = []
        clearSupportChat()
        screen = .welcome
    }

    @discardableResult
    func createFavoriteFolder(name: String) -> UUID? {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        let folder = FavoriteFolder(name: trimmed)
        favoriteFolders.insert(folder, at: 0)
        return folder.id
    }

    func saveWord(_ id: Int, toFolder folderID: UUID?) {
        removeWordFromAllFavorites(id)
        if let folderID, let index = favoriteFolders.firstIndex(where: { $0.id == folderID }) {
            if !favoriteFolders[index].wordIDs.contains(id) {
                favoriteFolders[index].wordIDs.append(id)
            }
        } else if !savedIDs.contains(id) {
            savedIDs.append(id)
        }
    }

    func removeWordFromAllFavorites(_ id: Int) {
        savedIDs.removeAll { $0 == id }
        for index in favoriteFolders.indices {
            favoriteFolders[index].wordIDs.removeAll { $0 == id }
        }
    }

    func removeWord(_ id: Int, fromFolder folderID: UUID?) {
        if let folderID, let index = favoriteFolders.firstIndex(where: { $0.id == folderID }) {
            favoriteFolders[index].wordIDs.removeAll { $0 == id }
        } else {
            savedIDs.removeAll { $0 == id }
        }
    }

    /// Legacy toggle used by demos: unsaves everywhere, or saves to General.
    func toggleSaved(_ id: Int) {
        if isSaved(id) {
            removeWordFromAllFavorites(id)
        } else {
            saveWord(id, toFolder: nil)
        }
    }

    func clearSupportChat() {
        supportConversations = []
    }

    @discardableResult
    func createSupportConversation(topic: SupportTopic = .problem) -> UUID {
        let conversation = SupportConversation(topic: topic)
        supportConversations.insert(conversation, at: 0)
        return conversation.id
    }

    func supportConversationIndex(id: UUID) -> Int? {
        supportConversations.firstIndex(where: { $0.id == id })
    }

    func trimSupportTyping(in id: UUID) {
        guard let index = supportConversationIndex(id: id) else { return }
        supportConversations[index].messages.removeAll { $0.role == .typing }
    }

    func touchSupportConversation(id: UUID) {
        guard let index = supportConversationIndex(id: id) else { return }
        supportConversations[index].updatedAt = Date()
    }

    func syncWidget() {
        let word = todayWord
        WidgetDataStore.publish(
            languageCode: language.rawValue,
            style: widgetStyle.rawValue,
            armenian: word.armenian,
            transliteration: word.transliteration,
            english: word.english,
            russian: word.russian
        )
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
        case "welcome":
            model.screen = .welcome
        case "email", "signup":
            model.screen = .email
        case "login":
            model.isReturningUser = true
            model.screen = .login
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
            model.favoriteFolders = []
        case "widget":
            model.screen = .main
            model.openWidgetOnLaunch = true
        default:
            break
        }
        return model
    }
}
