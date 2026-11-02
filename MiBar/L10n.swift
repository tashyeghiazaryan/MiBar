import Foundation

/// UI copy for Home / All words / Favorites, keyed by onboarding language.
struct L10n {
    let language: AppLanguage

    // MARK: - Tabs

    var tabToday: String {
        switch language {
        case .en: return "Today"
        case .ru: return "Сегодня"
        case .hy: return "Այսօր"
        }
    }

    var tabAllWords: String {
        switch language {
        case .en: return "All words"
        case .ru: return "Все слова"
        case .hy: return "Բոլոր բառերը"
        }
    }

    var tabFavorites: String {
        switch language {
        case .en: return "Favorites"
        case .ru: return "Избранное"
        case .hy: return "Ընտրյալներ"
        }
    }

    // MARK: - Home

    var wordOfTheDay: String {
        switch language {
        case .en: return "Word of the day"
        case .ru: return "Слово дня"
        case .hy: return "Օրվա բառը"
        }
    }

    var fromTheArchive: String {
        switch language {
        case .en: return "From the archive"
        case .ru: return "Из архива"
        case .hy: return "Արխիվից"
        }
    }

    /// Live top-bar date, e.g. "TUESDAY · JUNE 24" / "ВТОРНИК · 24 ИЮНЯ"
    var todayHeader: String {
        Self.formattedTodayHeader(for: language, date: Date())
    }

    static func formattedTodayHeader(for language: AppLanguage, date: Date = Date()) -> String {
        let locale: Locale
        switch language {
        case .en: locale = Locale(identifier: "en_US")
        case .ru: locale = Locale(identifier: "ru_RU")
        case .hy: locale = Locale(identifier: "hy_AM")
        }

        let weekday = DateFormatter()
        weekday.locale = locale
        weekday.dateFormat = "EEEE"

        let monthDay = DateFormatter()
        monthDay.locale = locale
        switch language {
        case .en:
            monthDay.dateFormat = "MMMM d"
        case .ru, .hy:
            monthDay.dateFormat = "d MMMM"
        }

        let left = weekday.string(from: date).uppercased(with: locale)
        let right = monthDay.string(from: date).uppercased(with: locale)
        return "\(left) · \(right)"
    }

    var listen: String {
        switch language {
        case .en: return "Listen"
        case .ru: return "Слушать"
        case .hy: return "Լսել"
        }
    }

    var playing: String {
        switch language {
        case .en: return "Playing…"
        case .ru: return "Играет…"
        case .hy: return "Հնչում է…"
        }
    }

    var save: String {
        switch language {
        case .en: return "Save"
        case .ru: return "Сохранить"
        case .hy: return "Պահել"
        }
    }

    var saved: String {
        switch language {
        case .en: return "Saved"
        case .ru: return "Сохранено"
        case .hy: return "Պահված է"
        }
    }

    var share: String {
        switch language {
        case .en: return "Share"
        case .ru: return "Поделиться"
        case .hy: return "Կիսվել"
        }
    }

    var sayItToday: String {
        switch language {
        case .en: return "Say it today"
        case .ru: return "Скажи сегодня"
        case .hy: return "Ասա այսօր"
        }
    }

    var betweenTheLines: String {
        switch language {
        case .en: return "Between the lines"
        case .ru: return "Между строк"
        case .hy: return "Տողերի միջև"
        }
    }

    var newWordTomorrow: String {
        switch language {
        case .en: return "A new word tomorrow at 9:00"
        case .ru: return "Новое слово завтра в 9:00"
        case .hy: return "Նոր բառը վաղը ժամը 9:00"
        }
    }

    var scrollForMore: String {
        switch language {
        case .en: return "Scroll for more"
        case .ru: return "Листайте дальше"
        case .hy: return "Թերթիր ավելին"
        }
    }

    var homeScreen: String {
        switch language {
        case .en: return "Home Screen"
        case .ru: return "Экран «Домой»"
        case .hy: return "Գլխավոր էկրան"
        }
    }

    var keepTodaysWord: String {
        switch language {
        case .en: return "Keep today’s word on your Home Screen"
        case .ru: return "Держите слово дня на экране «Домой»"
        case .hy: return "Պահիր օրվա բառը գլխավոր էկրանին"
        }
    }

    var widgetPromoBody: String {
        switch language {
        case .en: return "Choose a widget style, then add it — one Armenian word every day, without opening the app."
        case .ru: return "Выберите стиль виджета и добавьте его — одно армянское слово каждый день, не открывая приложение."
        case .hy: return "Ընտրիր վիդջեթի ոճը և ավելացրու՝ մեկ հայերեն բառ ամեն օր՝ առանց հավելվածը բացելու։"
        }
    }

    var chooseStyle: String {
        switch language {
        case .en: return "Choose style"
        case .ru: return "Выбрать стиль"
        case .hy: return "Ընտրել ոճ"
        }
    }

    // MARK: - Widget sheet

    var chooseYourWidget: String {
        switch language {
        case .en: return "Choose your widget"
        case .ru: return "Выберите виджет"
        case .hy: return "Ընտրիր վիդջեթը"
        }
    }

    var widgetSwipeHint: String {
        switch language {
        case .en: return "Swipe left to preview styles. Then add your favorite from the Home Screen."
        case .ru: return "Листайте влево, чтобы посмотреть стили. Затем добавьте любимый с экрана «Домой»."
        case .hy: return "Սահեցրու ձախ՝ ոճերը տեսնելու համար։ Ապա ավելացրու ընտրյալը գլխավոր էկրանից։"
        }
    }

    var howToAdd: String {
        switch language {
        case .en: return "How to add"
        case .ru: return "Как добавить"
        case .hy: return "Ինչպես ավելացնել"
        }
    }

    var widgetDisclaimerPrefix: String {
        switch language {
        case .en: return "Apps can’t place a widget for you. Follow the steps below to put "
        case .ru: return "Приложения не могут поставить виджет за вас. Следуйте шагам ниже, чтобы добавить "
        case .hy: return "Հավելվածները չեն կարող վիդջեթ տեղադրել քո փոխարեն։ Հետևիր քայլերին՝ "
        }
    }

    var widgetDisclaimerSuffix: String {
        switch language {
        case .en: return " on your Home Screen."
        case .ru: return " на экран «Домой»."
        case .hy: return " գլխավոր էկրանին ավելացնելու համար։"
        }
    }

    var gotIt: String {
        switch language {
        case .en: return "Got it"
        case .ru: return "Понятно"
        case .hy: return "Հասկացա"
        }
    }

    var close: String {
        switch language {
        case .en: return "Close"
        case .ru: return "Закрыть"
        case .hy: return "Փակել"
        }
    }

    func iphoneWidgetSteps(styleName: String) -> [String] {
        switch language {
        case .en:
            return [
                "Touch and hold the Home Screen",
                "Tap **Edit** → **Add Widget**",
                "Find **MiBar** and choose **\(styleName)**",
                "Tap **Add Widget**",
            ]
        case .ru:
            return [
                "Удерживайте экран «Домой»",
                "Нажмите **Изменить** → **Добавить виджет**",
                "Найдите **MiBar** и выберите **\(styleName)**",
                "Нажмите **Добавить виджет**",
            ]
        case .hy:
            return [
                "Սեղմիր և պահիր գլխավոր էկրանը",
                "Հպիր **Խմբագրել** → **Ավելացնել վիդջեթ**",
                "Գտիր **MiBar** և ընտրիր **\(styleName)**",
                "Հպիր **Ավելացնել վիդջեթ**",
            ]
        }
    }

    func androidWidgetSteps(styleName: String) -> [String] {
        switch language {
        case .en:
            return [
                "Touch and hold the Home Screen",
                "Tap **Widgets**",
                "Find **MiBar · \(styleName)**",
                "Drag the widget onto your screen",
            ]
        case .ru:
            return [
                "Удерживайте экран «Домой»",
                "Нажмите **Виджеты**",
                "Найдите **MiBar · \(styleName)**",
                "Перетащите виджет на экран",
            ]
        case .hy:
            return [
                "Սեղմիր և պահիր գլխավոր էկրանը",
                "Հպիր **Վիդջեթներ**",
                "Գտիր **MiBar · \(styleName)**",
                "Քաշիր վիդջեթը էկրանին",
            ]
        }
    }

    // MARK: - All words

    var archiveKicker: String {
        switch language {
        case .en: return "Growing, one word at a time"
        case .ru: return "Растём — по одному слову"
        case .hy: return "Աճում ենք՝ մեկ բառով"
        }
    }

    var archiveTitle: String { tabAllWords }

    var archiveSubtitle: String {
        switch language {
        case .en: return "Tap any word and try saying it"
        case .ru: return "Нажмите на слово и попробуйте сказать"
        case .hy: return "Հպիր բառին և փորձիր ասել"
        }
    }

    var wordsCountLabel: String {
        switch language {
        case .en: return "words"
        case .ru: return "слова"
        case .hy: return "բառ"
        }
    }

    var archiveMonth: String {
        switch language {
        case .en: return "June 2025"
        case .ru: return "Июнь 2025"
        case .hy: return "Հունիս 2025"
        }
    }

    var todayBadge: String {
        switch language {
        case .en: return "today"
        case .ru: return "сегодня"
        case .hy: return "այսօր"
        }
    }

    // MARK: - Favorites

    var favoritesKicker: String {
        switch language {
        case .en: return "Words worth keeping"
        case .ru: return "Слова, которые стоит хранить"
        case .hy: return "Բառեր, որոնք արժե պահել"
        }
    }

    var favoritesTitle: String { tabFavorites }

    var savedCountLabel: String {
        switch language {
        case .en: return "saved"
        case .ru: return "сохранено"
        case .hy: return "պահված"
        }
    }

    var emptyFavoritesTitle: String {
        switch language {
        case .en: return "Your words will\nlive here"
        case .ru: return "Здесь будут жить\nваши слова"
        case .hy: return "Քո բառերը\nկապրեն այստեղ"
        }
    }

    var emptyFavoritesBody: String {
        switch language {
        case .en: return "Tap the bookmark beside a word to return to it whenever you like."
        case .ru: return "Нажмите закладку рядом со словом, чтобы вернуться к нему в любой момент."
        case .hy: return "Հպիր էջանիշին բառի կողքին՝ ցանկացած պահի վերադառնալու համար։"
        }
    }

    var emptyFavoritesFootnote: String {
        switch language {
        case .en: return "հիշել · to remember"
        case .ru: return "հիշել · помнить"
        case .hy: return "հիշել · to remember"
        }
    }
}

extension AppLanguage {
    var copy: L10n { L10n(language: self) }
}

extension PartOfSpeech {
    func localizedTitle(for language: AppLanguage) -> String {
        switch (self, language) {
        case (.noun, .en): return "noun"
        case (.noun, .ru): return "сущ."
        case (.noun, .hy): return "գոյական"
        case (.verb, .en): return "verb"
        case (.verb, .ru): return "гл."
        case (.verb, .hy): return "բայ"
        case (.adjective, .en): return "adj."
        case (.adjective, .ru): return "прил."
        case (.adjective, .hy): return "ածական"
        case (.adverb, .en): return "adv."
        case (.adverb, .ru): return "нар."
        case (.adverb, .hy): return "մակբայ"
        }
    }
}
