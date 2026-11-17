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

    var shareYourWord: String {
        switch language {
        case .en: return "Share your word"
        case .ru: return "Поделитесь словом"
        case .hy: return "Կիսվիր բառով"
        }
    }

    var shareLookHint: String {
        switch language {
        case .en: return "Swipe the card, pick a look, then share to Instagram Stories"
        case .ru: return "Листайте карточку, выберите вид и отправьте в Instagram Stories"
        case .hy: return "Թերթիր քարտը, ընտրիր տեսքը և ուղարկիր Instagram Stories"
        }
    }

    var wordsCompletedTitle: String {
        switch language {
        case .en: return "Words learned"
        case .ru: return "Слов пройдено"
        case .hy: return "Սովորած բառեր"
        }
    }

    func wordsCompletedUnit(_ count: Int) -> String {
        switch language {
        case .en: return count == 1 ? "word" : "words"
        case .ru:
            let n = abs(count) % 100
            let n1 = n % 10
            if n > 10 && n < 20 { return "слов" }
            if n1 == 1 { return "слово" }
            if n1 >= 2 && n1 <= 4 { return "слова" }
            return "слов"
        case .hy: return "բառ"
        }
    }

    var wordsCompletedFootnote: String {
        switch language {
        case .en: return "One Armenian word, every day."
        case .ru: return "Одно армянское слово — каждый день."
        case .hy: return "Մեկ հայերեն բառ՝ ամեն օր։"
        }
    }

    var shareToInstagram: String {
        switch language {
        case .en: return "Share to Instagram"
        case .ru: return "В Instagram"
        case .hy: return "Instagram"
        }
    }

    var look: String {
        switch language {
        case .en: return "Look"
        case .ru: return "Вид"
        case .hy: return "Տեսք"
        }
    }

    var back: String {
        switch language {
        case .en: return "Back"
        case .ru: return "Назад"
        case .hy: return "Հետ"
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
        case .en: return "First 30 words"
        case .ru: return "Первые 30 слов"
        case .hy: return "Առաջին 30 բառը"
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

    var createCollection: String {
        switch language {
        case .en: return "New collection"
        case .ru: return "Новая подборка"
        case .hy: return "Նոր ընտրանի"
        }
    }

    var createCollectionTitle: String {
        switch language {
        case .en: return "Create collection"
        case .ru: return "Создать подборку"
        case .hy: return "Ստեղծել ընտրանի"
        }
    }

    var collectionNamePlaceholder: String {
        switch language {
        case .en: return "Collection name"
        case .ru: return "Название подборки"
        case .hy: return "Ընտրանիի անուն"
        }
    }

    var createCollectionConfirm: String {
        switch language {
        case .en: return "Create"
        case .ru: return "Создать"
        case .hy: return "Ստեղծել"
        }
    }

    var cancel: String {
        switch language {
        case .en: return "Cancel"
        case .ru: return "Отмена"
        case .hy: return "Չեղարկել"
        }
    }

    var generalCollection: String {
        switch language {
        case .en: return "General"
        case .ru: return "Общее"
        case .hy: return "Ընդհանուր"
        }
    }

    var collectionsLabel: String {
        switch language {
        case .en: return "Collections"
        case .ru: return "Подборки"
        case .hy: return "Ընտրանիներ"
        }
    }

    var emptyCollectionBody: String {
        switch language {
        case .en: return "No words in this collection yet."
        case .ru: return "В этой подборке пока нет слов."
        case .hy: return "Այս ընտրանիում դեռ բառեր չկան։"
        }
    }

    var saveToTitle: String {
        switch language {
        case .en: return "Save to"
        case .ru: return "Сохранить в"
        case .hy: return "Պահել այստեղ"
        }
    }

    var saveToGeneral: String {
        switch language {
        case .en: return "Save to General"
        case .ru: return "Сохранить в «Общее»"
        case .hy: return "Պահել «Ընդհանուր»-ում"
        }
    }

    var wordsInCollectionLabel: String {
        switch language {
        case .en: return "words"
        case .ru: return "слов"
        case .hy: return "բառ"
        }
    }

    // MARK: - Settings / Support

    var settingsTitle: String {
        switch language {
        case .en: return "Settings"
        case .ru: return "Настройки"
        case .hy: return "Կարգավորումներ"
        }
    }

    var settingsPreferences: String {
        switch language {
        case .en: return "Preferences"
        case .ru: return "Параметры"
        case .hy: return "Նախապատվություններ"
        }
    }

    var settingsAccount: String {
        switch language {
        case .en: return "Account"
        case .ru: return "Аккаунт"
        case .hy: return "Հաշիվ"
        }
    }

    var settingsEmail: String {
        switch language {
        case .en: return "Email"
        case .ru: return "Email"
        case .hy: return "Էլ․ փոստ"
        }
    }

    var settingsLanguage: String {
        switch language {
        case .en: return "Language"
        case .ru: return "Язык"
        case .hy: return "Լեզու"
        }
    }

    var settingsNotifications: String {
        switch language {
        case .en: return "Notifications"
        case .ru: return "Уведомления"
        case .hy: return "Ծանուցումներ"
        }
    }

    var settingsDailyReminder: String {
        switch language {
        case .en: return "New word"
        case .ru: return "Новое слово"
        case .hy: return "Նոր բառ"
        }
    }

    var settingsDailyReminderSubtitle: String {
        switch language {
        case .en: return "Notify when it updates"
        case .ru: return "Уведомление при смене слова"
        case .hy: return "Ծանուցում՝ բառը փոխվելիս"
        }
    }

    var settingsLegal: String {
        switch language {
        case .en: return "Legal"
        case .ru: return "Документы"
        case .hy: return "Փաստաթղթեր"
        }
    }

    var settingsTerms: String {
        switch language {
        case .en: return "Terms of Use"
        case .ru: return "Условия использования"
        case .hy: return "Օգտագործման պայմաններ"
        }
    }

    var settingsPrivacy: String {
        switch language {
        case .en: return "Privacy Policy"
        case .ru: return "Политика конфиденциальности"
        case .hy: return "Գաղտնիության քաղաքականություն"
        }
    }

    var settingsAbout: String {
        switch language {
        case .en: return "About"
        case .ru: return "О приложении"
        case .hy: return "Հավելվածի մասին"
        }
    }

    var settingsVersion: String {
        switch language {
        case .en: return "Version"
        case .ru: return "Версия"
        case .hy: return "Տարբերակ"
        }
    }

    var settingsSupport: String {
        switch language {
        case .en: return "Support"
        case .ru: return "Поддержка"
        case .hy: return "Աջակցություն"
        }
    }

    var settingsSupportSubtitle: String {
        switch language {
        case .en: return "Chat with support"
        case .ru: return "Написать в поддержку"
        case .hy: return "Գրել աջակցությանը"
        }
    }

    var settingsLogOut: String {
        switch language {
        case .en: return "Log out"
        case .ru: return "Выйти"
        case .hy: return "Դուրս գալ"
        }
    }

    var supportTitle: String {
        switch language {
        case .en: return "Support"
        case .ru: return "Поддержка"
        case .hy: return "Աջակցություն"
        }
    }

    var supportHeadline: String {
        switch language {
        case .en: return "How can I help you?"
        case .ru: return "Чем могу помочь?"
        case .hy: return "Ինչո՞վ կարող եմ օգնել"
        }
    }

    var supportTopicLabel: String {
        switch language {
        case .en: return "Choose a topic"
        case .ru: return "Выберите тему"
        case .hy: return "Ընտրիր թեման"
        }
    }

    var supportTopicProblem: String {
        switch language {
        case .en: return "Report a problem"
        case .ru: return "Сообщить о проблеме"
        case .hy: return "Հաղորդել խնդրի մասին"
        }
    }

    var supportTopicFeedback: String {
        switch language {
        case .en: return "Feedback"
        case .ru: return "Отзыв"
        case .hy: return "Կարծիք"
        }
    }

    var supportTopicOther: String {
        switch language {
        case .en: return "Other"
        case .ru: return "Другое"
        case .hy: return "Այլ"
        }
    }

    var supportMessagePlaceholder: String {
        switch language {
        case .en: return "Write your message…"
        case .ru: return "Напишите сообщение…"
        case .hy: return "Գրիր հաղորդագրություն…"
        }
    }

    var supportSend: String {
        switch language {
        case .en: return "Send"
        case .ru: return "Отправить"
        case .hy: return "Ուղարկել"
        }
    }

    var supportTyping: String {
        switch language {
        case .en: return "Support is typing…"
        case .ru: return "Поддержка печатает…"
        case .hy: return "Աջակցությունը գրում է…"
        }
    }

    var supportWrite: String {
        switch language {
        case .en: return "Write"
        case .ru: return "Написать"
        case .hy: return "Գրել"
        }
    }

    var supportInboxEmpty: String {
        switch language {
        case .en: return "No conversations yet.\nTap Write to start one."
        case .ru: return "Пока нет диалогов.\nНажмите «Написать», чтобы начать."
        case .hy: return "Դեռ երկխոսություններ չկան։\nՍեղմիր «Գրել»՝ սկսելու համար։"
        }
    }

    var supportConversationsLabel: String {
        switch language {
        case .en: return "Conversations"
        case .ru: return "Диалоги"
        case .hy: return "Երկխոսություններ"
        }
    }

    var supportNoMessagesYet: String {
        switch language {
        case .en: return "No messages yet"
        case .ru: return "Пока нет сообщений"
        case .hy: return "Դեռ հաղորդագրություններ չկան"
        }
    }

    var supportAutoReplyProblem: String {
        switch language {
        case .en:
            return "Hello, and thank you for writing to us. Our team will get back to you soon."
        case .ru:
            return "Здравствуйте, и спасибо, что написали нам. Наша команда скоро свяжется с вами."
        case .hy:
            return "Բարև ձեզ, և շնորհակալություն մեզ գրելու համար։ Մեր թիմը շուտով կկապվի ձեզ հետ։"
        }
    }

    var supportAutoReplyFeedback: String {
        switch language {
        case .en:
            return "Hello! Thank you for your feedback. Our team will read it and get back to you soon."
        case .ru:
            return "Здравствуйте! Спасибо за отзыв. Наша команда прочитает его и скоро ответит."
        case .hy:
            return "Բարև ձեզ։ Շնորհակալություն կարծիքի համար։ Մեր թիմը կկարդա այն և շուտով կպատասխանի։"
        }
    }

    var supportAutoReplyOther: String {
        switch language {
        case .en:
            return "Hello! Thank you for your message. Our team will get back to you soon."
        case .ru:
            return "Здравствуйте! Спасибо за сообщение. Наша команда скоро ответит."
        case .hy:
            return "Բարև ձեզ։ Շնորհակալություն հաղորդագրության համար։ Մեր թիմը շուտով կպատասխանի։"
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
