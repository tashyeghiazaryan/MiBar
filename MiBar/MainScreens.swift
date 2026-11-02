import AVFoundation
import SwiftUI

struct MainShell: View {
    @EnvironmentObject private var model: AppModel
    @State private var ready = true
    @State private var showWidget = false
    @State private var widgetStyle: HomeWidgetStyle = .classic

    private var today: Word { Word.catalog[0] }

    private var scrollID: String {
        if let detail = model.detail { return "detail-\(detail.id)" }
        return "tab-\(model.tab.rawValue)"
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                Group {
                    if let detail = model.detail {
                        WordFeature(
                            word: detail,
                            saved: model.savedIDs.contains(detail.id),
                            isDetail: true,
                            onToggleSave: { model.toggleSaved(detail.id) },
                            onBack: { model.detail = nil }
                        )
                    } else if model.tab == .today {
                        WordFeature(
                            word: today,
                            saved: model.savedIDs.contains(today.id),
                            widgetStyle: widgetStyle,
                            onToggleSave: { model.toggleSaved(today.id) },
                            onChooseWidget: {
                                withAnimation(.easeOut(duration: 0.28)) { showWidget = true }
                            }
                        )
                    } else if model.tab == .archive {
                        ScrollView {
                            ArchivePage(
                                savedIDs: model.savedIDs,
                                onOpen: { model.open($0) },
                                onToggleSave: { model.toggleSaved($0) }
                            )
                        }
                        .scrollIndicators(.hidden)
                    } else {
                        ScrollView {
                            FavoritesPage(
                                words: model.savedWords,
                                onOpen: { model.open($0) },
                                onRemove: { model.toggleSaved($0) }
                            )
                        }
                        .scrollIndicators(.hidden)
                    }
                }
                .id(scrollID)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                if model.detail == nil && !showWidget {
                    TabBar(active: model.tab) { model.changeTab($0) }
                }
            }
            .opacity(ready ? 1 : 0)
            .offset(y: ready ? 0 : 10)

            if showWidget {
                WidgetStyleSheet(word: today, selected: $widgetStyle) {
                    withAnimation(.easeOut(duration: 0.28)) { showWidget = false }
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .zIndex(2)
            }
        }
        .background {
            ZStack(alignment: .leading) {
                Color.paper
                if model.tab == .favorites && model.detail == nil {
                    Rectangle()
                        .fill(Color.navy.opacity(0.04))
                        .frame(width: 1)
                        .padding(.leading, 19)
                }
            }
            .ignoresSafeArea()
        }
        .onAppear {
            if model.openWidgetOnLaunch {
                showWidget = true
                model.openWidgetOnLaunch = false
            }
            guard !ready else { return }
            withAnimation(.easeOut(duration: 0.7)) { ready = true }
        }
    }
}

struct TabBar: View {
    var active: AppTab
    var onChange: (AppTab) -> Void
    @EnvironmentObject private var model: AppModel

    var body: some View {
        let copy = model.language.copy
        HStack(spacing: 0) {
            item(.today, copy.tabToday, .home)
            item(.archive, copy.tabAllWords, .calendar)
            item(.favorites, copy.tabFavorites, .heart)
        }
        .padding(.top, 8)
        .padding(.bottom, 8)
        .padding(.horizontal, 15)
        .background {
            Rectangle()
                .fill(Color.paper.opacity(0.96))
                .background(.ultraThinMaterial)
                .overlay(alignment: .top) {
                    Rectangle().fill(Color.navy.opacity(0.09)).frame(height: 1)
                }
                .ignoresSafeArea(edges: .bottom)
        }
    }

    private func item(_ tab: AppTab, _ title: String, _ icon: MiBarIcon) -> some View {
        let on = active == tab
        return Button {
            onChange(tab)
        } label: {
            VStack(spacing: 4) {
                MiBarIconView(name: icon, size: 21)
                    .overlay(alignment: .topTrailing) {
                        if on {
                            Circle()
                                .fill(Color.orangeBrand)
                                .frame(width: 5, height: 5)
                                .offset(x: 5, y: -3)
                        }
                    }
                Text(title)
                    .font(MiBarFont.ui(size: 9, weight: .medium))
            }
            .foregroundStyle(on ? Color.navy : Color.muted5)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(MiBarPressStyle())
        .accessibilityLabel(title)
    }
}

final class Speaker: ObservableObject {
    private let synth = AVSpeechSynthesizer()

    func speak(_ text: String) {
        synth.stopSpeaking(at: .immediate)
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "hy-AM")
        utterance.rate = 0.42
        synth.speak(utterance)
    }

    func stop() {
        synth.stopSpeaking(at: .immediate)
    }
}

struct WordFeature: View {
    var word: Word
    var saved: Bool
    var isDetail = false
    var widgetStyle: HomeWidgetStyle = .classic
    var onToggleSave: () -> Void
    var onBack: (() -> Void)?
    var onChooseWidget: (() -> Void)?

    @EnvironmentObject private var model: AppModel
    @StateObject private var speaker = Speaker()
    @State private var playing = false
    @State private var showScrollHint: Bool
    @State private var showSettings = false
    @State private var playTask: Task<Void, Never>?
    @State private var scrollMetrics = ScrollMetrics(minY: 0, height: 0)
    @State private var viewportHeight: CGFloat = 0

    init(
        word: Word,
        saved: Bool,
        isDetail: Bool = false,
        widgetStyle: HomeWidgetStyle = .classic,
        onToggleSave: @escaping () -> Void,
        onBack: (() -> Void)? = nil,
        onChooseWidget: (() -> Void)? = nil
    ) {
        self.word = word
        self.saved = saved
        self.isDetail = isDetail
        self.widgetStyle = widgetStyle
        self.onToggleSave = onToggleSave
        self.onBack = onBack
        self.onChooseWidget = onChooseWidget
        _showScrollHint = State(initialValue: !isDetail)
    }

    var body: some View {
        ScrollViewReader { proxy in
            ZStack(alignment: .bottom) {
                ScrollView {
                    VStack(spacing: 0) {
                        topBar
                        hero
                        phrase.id("phrase")
                        if let note = word.note(for: model.language) {
                            culture(note)
                        }
                        if !isDetail {
                            tomorrow
                            if let onChooseWidget {
                                WidgetPromo(word: word, style: widgetStyle, onChoose: onChooseWidget)
                            }
                        }
                    }
                    .background {
                        GeometryReader { geo in
                            Color.clear.preference(
                                key: ScrollMetricsKey.self,
                                value: ScrollMetrics(
                                    minY: geo.frame(in: .named("wordScroll")).minY,
                                    height: geo.size.height
                                )
                            )
                        }
                    }
                }
                .coordinateSpace(name: "wordScroll")
                .scrollIndicators(.hidden)
                .background {
                    GeometryReader { geo in
                        Color.clear.preference(
                            key: ViewportHeightKey.self,
                            value: geo.size.height
                        )
                    }
                }
                .onPreferenceChange(ScrollMetricsKey.self) { metrics in
                    scrollMetrics = metrics
                    updateScrollHint(viewportHeight: viewportHeight)
                }
                .onPreferenceChange(ViewportHeightKey.self) { height in
                    viewportHeight = height
                    updateScrollHint(viewportHeight: height)
                }

                if !isDetail && showScrollHint {
                    ScrollHint(label: copy.scrollForMore) {
                        withAnimation(.easeInOut(duration: 0.45)) {
                            proxy.scrollTo("phrase", anchor: .top)
                        }
                        showScrollHint = false
                    }
                    .padding(.bottom, 12)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                    .zIndex(1)
                }
            }
        }
        .onDisappear {
            playTask?.cancel()
            speaker.stop()
        }
    }

    private func updateScrollHint(viewportHeight: CGFloat) {
        guard !isDetail, showScrollHint, viewportHeight > 0 else { return }
        let scrolled = scrollMetrics.minY < -24
        let contentFits = scrollMetrics.height <= viewportHeight + 8
        let nearBottom = scrollMetrics.minY <= viewportHeight - scrollMetrics.height + 48
        if scrolled || contentFits || nearBottom {
            showScrollHint = false
        }
    }

    private var copy: L10n { model.language.copy }

    private var topBar: some View {
        ZStack {
            HStack(spacing: 8) {
                Text(isDetail ? word.date : copy.todayHeader)
                    .font(MiBarFont.ui(size: 9, weight: .semibold))
                    .tracking(0.72)
                    .foregroundStyle(Color.inkSoft)
                Circle()
                    .fill(Color.orangeBrand)
                    .frame(width: 7, height: 7)
                    .background {
                        Circle()
                            .fill(Color(hex: 0xED764F).opacity(0.13))
                            .frame(width: 15, height: 15)
                    }
            }
            .frame(maxWidth: .infinity)

            HStack(alignment: .center) {
                if isDetail {
                    IconButton(icon: .back) { onBack?() }
                        .accessibilityLabel("Back to the list")
                } else {
                    BrandMark(compact: true, showMark: false)
                }
                Spacer(minLength: 8)
                if !isDetail {
                    IconButton(icon: .settings) {
                        showSettings = true
                    }
                } else {
                    Color.clear.frame(width: 42, height: 42)
                }
            }
        }
        .padding(.horizontal, 25)
        .padding(.top, 8)
        .padding(.bottom, 10)
        .sheet(isPresented: $showSettings) {
            SettingsSheet(
                language: $model.language,
                onLogout: {
                    showSettings = false
                    model.logout()
                }
            )
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
    }

    private var hero: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                Text(isDetail ? copy.fromTheArchive : copy.wordOfTheDay)
                    .foregroundStyle(Color.orangeSoft)
                Text("No. \(word.issueNumber)")
                    .foregroundStyle(Color.white.opacity(0.5))
            }
            .font(MiBarFont.ui(size: 9, weight: .semibold))
            .tracking(1.44)
            .textCase(.uppercase)

            Text(word.armenian)
                .font(MiBarFont.ui(size: ScreenMetrics.armenianWord, weight: .medium, editorial: true))
                .tracking(ScreenMetrics.armenianWord * -0.045)
                .foregroundStyle(Color.white)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .padding(.top, 45)

            meta
                .padding(.top, 22)

            HStack(alignment: .top, spacing: 0) {
                VStack(spacing: 7) {
                    audioButton
                    Text(playing ? copy.playing : copy.listen)
                        .font(MiBarFont.ui(size: 9))
                        .foregroundStyle(Color.white.opacity(0.55))
                }
                .frame(maxWidth: .infinity)
                VStack(spacing: 7) {
                    saveButton
                    Text(saved ? copy.saved : copy.save)
                        .font(MiBarFont.ui(size: 9))
                        .foregroundStyle(Color.white.opacity(0.55))
                }
                .frame(maxWidth: .infinity)
                VStack(spacing: 7) {
                    shareButton
                    Text(copy.share)
                        .font(MiBarFont.ui(size: 9))
                        .foregroundStyle(Color.white.opacity(0.55))
                }
                .frame(maxWidth: .infinity)
            }
            .frame(width: 248)
            .padding(.top, 35)
        }
        .padding(.top, 37)
        .padding(.horizontal, 20)
        .padding(.bottom, isDetail ? 30 : 22)
        .frame(maxWidth: .infinity)
        .frame(minHeight: isDetail ? 372 : nil)
        .background(Color.navy)
    }

    private var meta: some View {
        ViewThatFits(in: .horizontal) {
            metaRow
            VStack(spacing: 6) {
                Text("[\(word.transliteration)]")
                    .font(MiBarFont.ui(size: 19, italic: true, editorial: true))
                    .foregroundStyle(Color.translitBlue)
                HStack(spacing: 10) {
                    Text(word.english)
                    Text("·").foregroundStyle(Color.orangeBrand)
                    Text(word.russian)
                }
                .font(MiBarFont.ui(size: 17, weight: .medium))
                .foregroundStyle(Color.white.opacity(0.82))
            }
        }
    }

    private var metaRow: some View {
        HStack(spacing: 10) {
            Text("[\(word.transliteration)]")
                .font(MiBarFont.ui(size: 19, italic: true, editorial: true))
                .foregroundStyle(Color.translitBlue)
            Capsule()
                .fill(Color.white.opacity(0.25))
                .frame(width: 17, height: 1)
            Text(word.english)
                .font(MiBarFont.ui(size: 17, weight: .medium))
            Text("·")
                .font(MiBarFont.ui(size: 17, weight: .medium))
                .foregroundStyle(Color.orangeBrand)
            Text(word.russian)
                .font(MiBarFont.ui(size: 17, weight: .medium))
        }
        .foregroundStyle(Color.white.opacity(0.82))
    }

    private var audioButton: some View {
        Button(action: togglePlay) {
            ZStack {
                Circle().fill(playing ? Color.brandBlue : Color.orangeBrand)
                Circle().stroke(playing ? Color.brandBlue : Color.orangeBrand, lineWidth: 1)
                MiBarIconView(name: playing ? .pause : .play, size: 22)
                    .foregroundStyle(Color.white)
                if playing {
                    AudioRipple()
                }
            }
            .frame(width: 58, height: 58)
        }
        .buttonStyle(MiBarPressStyle())
        .accessibilityLabel(playing ? "Stop pronunciation" : "Play pronunciation")
    }

    private var saveButton: some View {
        Button(action: onToggleSave) {
            ZStack {
                Circle().stroke(saved ? Color.brandBlue : Color.white.opacity(0.28), lineWidth: 1)
                MiBarIconView(name: saved ? .bookmarked : .bookmark, size: 22)
                    .foregroundStyle(saved ? Color.brandBlue : Color.white)
            }
            .frame(width: 58, height: 58)
        }
        .buttonStyle(MiBarPressStyle())
        .accessibilityLabel(saved ? "Remove from favorites" : "Save to favorites")
    }

    private var shareButton: some View {
        Button {
            StoryShare.shareWord(word, language: model.language)
        } label: {
            ZStack {
                Circle().stroke(Color.white.opacity(0.28), lineWidth: 1)
                MiBarIconView(name: .share, size: 22)
                    .foregroundStyle(Color.white)
                    .offset(y: -1)
            }
            .frame(width: 58, height: 58)
        }
        .buttonStyle(MiBarPressStyle())
        .accessibilityLabel(copy.share)
    }

    private var phrase: some View {
        HStack(alignment: .top, spacing: 16) {
            RoundedRectangle(cornerRadius: 3)
                .fill(Color.brandBlue)
                .frame(width: 3)
            VStack(alignment: .leading, spacing: 0) {
                Kicker(text: copy.sayItToday)
                Text(word.phrase)
                    .font(MiBarFont.ui(size: 23, weight: .semibold, editorial: true))
                    .foregroundStyle(Color.black)
                    .padding(.top, 12)
                    .fixedSize(horizontal: false, vertical: true)
                Text("[\(word.phraseTransliteration)]")
                    .font(MiBarFont.ui(size: 16, italic: true, editorial: true))
                    .foregroundStyle(Color.brandBlue)
                    .padding(.top, 8)
                Text(primaryPhrase)
                    .font(MiBarFont.ui(size: 16, weight: .medium))
                    .foregroundStyle(Color.black)
                    .padding(.top, 10)
                if let secondaryPhrase {
                    Text(secondaryPhrase)
                        .font(MiBarFont.ui(size: 16, weight: .medium))
                        .foregroundStyle(Color.black)
                        .padding(.top, 4)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 28)
        .overlay(alignment: .bottom) {
            Rectangle().fill(Color.line).frame(height: 1)
        }
        .padding(.horizontal, 25)
    }

    private func culture(_ note: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                MiBarIconView(name: .spark, size: 20)
                    .foregroundStyle(Color.orangeBrand)
            }
            .frame(width: 39, height: 39)
            .overlay {
                UnevenRoundedRectangle(
                    topLeadingRadius: 19.5,
                    bottomLeadingRadius: 8,
                    bottomTrailingRadius: 19.5,
                    topTrailingRadius: 19.5
                )
                .stroke(Color.orangeBrand, lineWidth: 1)
            }
            VStack(alignment: .leading, spacing: 9) {
                Kicker(text: copy.betweenTheLines)
                Text(note)
                    .font(MiBarFont.ui(size: 15, editorial: true))
                    .foregroundStyle(Color.inkSoft)
                    .lineSpacing(5)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.vertical, 27)
        .overlay(alignment: .bottom) {
            Rectangle().fill(Color.line).frame(height: 1)
        }
        .padding(.horizontal, 25)
    }

    private var primaryPhrase: String {
        switch model.language {
        case .ru: return word.phraseRussian
        case .en, .hy: return word.phraseEnglish
        }
    }

    private var secondaryPhrase: String? {
        switch model.language {
        case .ru: return word.phraseEnglish
        case .en: return word.phraseRussian
        case .hy: return word.phraseRussian
        }
    }

    private var tomorrow: some View {
        HStack(spacing: 10) {
            Rectangle().fill(Color.line).frame(height: 1)
            Text(copy.newWordTomorrow)
                .font(MiBarFont.ui(size: 10))
                .tracking(0.8)
                .textCase(.uppercase)
                .foregroundStyle(Color.muted4)
                .fixedSize()
            Rectangle().fill(Color.line).frame(height: 1)
        }
        .padding(.top, 23)
        .padding(.horizontal, 25)
    }

    private func togglePlay() {
        playTask?.cancel()
        if playing {
            playing = false
            speaker.stop()
            return
        }
        playing = true
        speaker.speak(word.armenian)
        playTask = Task {
            try? await Task.sleep(nanoseconds: 2_300_000_000)
            guard !Task.isCancelled else { return }
            playing = false
        }
    }
}

private struct ScrollMetrics: Equatable {
    var minY: CGFloat
    var height: CGFloat
}

private struct ScrollMetricsKey: PreferenceKey {
    static var defaultValue = ScrollMetrics(minY: 0, height: 0)
    static func reduce(value: inout ScrollMetrics, nextValue: () -> ScrollMetrics) {
        value = nextValue()
    }
}

private struct ViewportHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

private struct ScrollHint: View {
    var label: String
    var action: () -> Void
    @State private var down = false

    var body: some View {
        Button(action: action) {
            VStack(spacing: 3) {
                Text(label)
                    .font(MiBarFont.ui(size: 11, weight: .semibold))
                    .tracking(0.88)
                    .textCase(.uppercase)
                MiBarIconView(name: .chevronDown, size: 18)
            }
            .foregroundStyle(Color.navy.opacity(0.78))
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color.paper.opacity(0.96))
            .clipShape(Capsule())
            .overlay {
                Capsule()
                    .stroke(Color.navy.opacity(0.12), lineWidth: 1)
            }
            .shadow(color: Color.navy.opacity(0.12), radius: 12, y: 4)
            .offset(y: down ? 4 : 0)
            .opacity(down ? 1 : 0.85)
        }
        .buttonStyle(.plain)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                down = true
            }
        }
    }
}

private struct AudioRipple: View {
    @State private var animate = false

    var body: some View {
        Circle()
            .stroke(Color.brandBlue, lineWidth: 1)
            .scaleEffect(animate ? 1.4 : 1)
            .opacity(animate ? 0 : 1)
            .allowsHitTesting(false)
            .onAppear {
                withAnimation(.easeOut(duration: 1.2).repeatForever(autoreverses: false)) {
                    animate = true
                }
            }
    }
}

struct WidgetPreviewCard: View {
    var word: Word
    var style: HomeWidgetStyle
    var side: CGFloat = 112
    @EnvironmentObject private var model: AppModel

    var body: some View {
        let large = side > 120
        VStack(alignment: .leading, spacing: 2) {
            Text(model.language.copy.wordOfTheDay)
                .font(MiBarFont.ui(size: large ? 8 : 7, weight: .bold))
                .tracking(0.6)
                .textCase(.uppercase)
                .foregroundStyle(kicker)
            Spacer(minLength: 2)
            Text(word.armenian)
                .font(MiBarFont.ui(size: large ? 26 : 22, weight: .semibold, editorial: true))
                .foregroundStyle(primary)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
            Text("[\(word.transliteration)]")
                .font(MiBarFont.ui(size: large ? 11 : 10, italic: true, editorial: true))
                .foregroundStyle(meta)
            Text(model.language == .ru ? "\(word.russian) · \(word.english)" : "\(word.english) · \(word.russian)")
                .font(MiBarFont.ui(size: large ? 9 : 8, weight: .medium))
                .foregroundStyle(translation)
                .lineLimit(2)
                .minimumScaleFactor(0.7)
        }
        .padding(.horizontal, large ? 13 : 10)
        .padding(.vertical, large ? 15 : 12)
        .frame(width: side, height: side, alignment: .leading)
        .background { background }
        .clipShape(RoundedRectangle(cornerRadius: large ? 26 : 22, style: .continuous))
        .overlay {
            if style == .soft || style == .clear {
                RoundedRectangle(cornerRadius: large ? 26 : 22, style: .continuous)
                    .stroke(style == .clear ? Color.white.opacity(0.45) : Color.navy.opacity(0.1), lineWidth: 1)
            }
        }
        .shadow(color: Color.navy.opacity(style == .clear ? 0.12 : 0.18), radius: 12, y: 8)
    }

    private var kicker: Color {
        switch style {
        case .classic: return .orangeSoft
        case .soft: return .orangeBrand
        case .sun: return Color.white.opacity(0.8)
        case .clear: return Color.navy.opacity(0.7)
        }
    }

    private var primary: Color {
        switch style {
        case .classic, .sun: return .white
        case .soft, .clear: return .navy
        }
    }

    private var meta: Color {
        switch style {
        case .classic: return .translitBlue
        case .soft, .clear: return .brandBlue
        case .sun: return .sunMeta
        }
    }

    private var translation: Color {
        switch style {
        case .classic: return Color.white.opacity(0.72)
        case .soft: return .inkSoft
        case .sun: return Color.white.opacity(0.8)
        case .clear: return Color.navy.opacity(0.78)
        }
    }

    @ViewBuilder
    private var background: some View {
        switch style {
        case .classic:
            Color.navy
        case .soft:
            Color.softPaper
        case .sun:
            Color.orangeBrand
        case .clear:
            ZStack {
                LinearGradient(
                    colors: [Color(hex: 0x90B4D8), Color(hex: 0xD9C4A8), Color(hex: 0xC7A07A)],
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

private struct WidgetPromo: View {
    var word: Word
    var style: HomeWidgetStyle
    var onChoose: () -> Void
    @EnvironmentObject private var model: AppModel

    var body: some View {
        let copy = model.language.copy
        HStack(alignment: .center, spacing: 14) {
            VStack(alignment: .leading, spacing: 0) {
                Kicker(text: copy.homeScreen)
                Text(copy.keepTodaysWord)
                    .font(MiBarFont.ui(size: 20, weight: .semibold, editorial: true))
                    .tracking(-0.6)
                    .foregroundStyle(Color.black)
                    .padding(.top, 8)
                    .fixedSize(horizontal: false, vertical: true)
                Text(copy.widgetPromoBody)
                    .font(MiBarFont.ui(size: 12))
                    .foregroundStyle(Color.inkSoft)
                    .lineSpacing(3)
                    .padding(.top, 8)
                    .fixedSize(horizontal: false, vertical: true)
                Button(action: onChoose) {
                    HStack(spacing: 7) {
                        MiBarIconView(name: .widget, size: 18)
                        Text(copy.chooseStyle)
                        MiBarIconView(name: .arrow, size: 18)
                    }
                    .font(MiBarFont.ui(size: 12, weight: .semibold))
                    .foregroundStyle(Color.brandBlue)
                }
                .buttonStyle(MiBarPressStyle())
                .padding(.top, 14)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            WidgetPreviewCard(word: word, style: style, side: 112)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.line, lineWidth: 1)
        }
        .padding(.horizontal, 25)
        .padding(.top, 18)
        .padding(.bottom, 28)
    }
}

struct WidgetStyleSheet: View {
    var word: Word
    @Binding var selected: HomeWidgetStyle
    var onClose: () -> Void
    @EnvironmentObject private var model: AppModel
    @State private var visible: HomeWidgetStyle?

    private var copy: L10n { model.language.copy }
    private var selectedName: String { selected.localizedName(for: model.language) }

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.navy.opacity(0.35)
                .ignoresSafeArea()
                .onTapGesture(perform: onClose)
                .accessibilityLabel(copy.close)

            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        Capsule()
                            .fill(Color.navy.opacity(0.14))
                            .frame(width: 42, height: 4)
                            .frame(maxWidth: .infinity)
                            .padding(.bottom, 14)

                        HStack(alignment: .top, spacing: 12) {
                            VStack(alignment: .leading, spacing: 6) {
                                Kicker(text: copy.homeScreen)
                                Text(copy.chooseYourWidget)
                                    .font(MiBarFont.ui(size: 28, weight: .semibold, editorial: true))
                                    .tracking(-1.12)
                                    .foregroundStyle(Color.black)
                            }
                            Spacer(minLength: 8)
                            IconButton(icon: .close, size: 18, action: onClose)
                        }
                        .padding(.horizontal, 22)

                        Text(copy.widgetSwipeHint)
                            .font(MiBarFont.ui(size: 13))
                            .foregroundStyle(Color.inkSoft)
                            .lineSpacing(4)
                            .padding(.top, 12)
                            .padding(.horizontal, 22)
                            .fixedSize(horizontal: false, vertical: true)

                        carousel
                            .padding(.top, 18)

                        HStack(spacing: 6) {
                            ForEach(HomeWidgetStyle.allCases) { style in
                                Capsule()
                                    .fill(style == selected ? Color.navy : Color.navy.opacity(0.16))
                                    .frame(width: style == selected ? 16 : 6, height: 6)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 12)
                        .animation(.easeOut(duration: 0.2), value: selected)

                        VStack(alignment: .leading, spacing: 8) {
                            Text(copy.howToAdd)
                                .font(MiBarFont.ui(size: 22, weight: .semibold, editorial: true))
                                .tracking(-0.66)
                                .foregroundStyle(Color.black)
                            (
                                Text(copy.widgetDisclaimerPrefix)
                                + Text(selectedName).fontWeight(.bold)
                                + Text(copy.widgetDisclaimerSuffix)
                            )
                            .font(MiBarFont.ui(size: 13))
                            .foregroundStyle(Color.inkSoft)
                            .lineSpacing(4)
                        }
                        .padding(.top, 18)
                        .padding(.horizontal, 22)
                        .overlay(alignment: .top) {
                            Rectangle().fill(Color.line).frame(height: 1).padding(.horizontal, 22)
                        }

                        VStack(alignment: .leading, spacing: 16) {
                            stepGroup("iPhone", copy.iphoneWidgetSteps(styleName: selectedName))
                            stepGroup("Android", copy.androidWidgetSteps(styleName: selectedName))
                        }
                        .padding(.top, 16)
                        .padding(.horizontal, 22)
                        .padding(.bottom, 22)

                        PrimaryButton(title: copy.gotIt, icon: .check, action: onClose)
                            .padding(.horizontal, 22)
                    }
                    .padding(.top, 12)
                    .padding(.bottom, 20)
                }
                .frame(maxHeight: UIScreen.main.bounds.height * 0.88)
                .scrollIndicators(.hidden)

            }
            .frame(maxWidth: .infinity)
            .clipShape(
                UnevenRoundedRectangle(
                    topLeadingRadius: 24,
                    bottomLeadingRadius: 0,
                    bottomTrailingRadius: 0,
                    topTrailingRadius: 24
                )
            )
            // Drawn after clip so home-indicator area stays solid white (no gray bleed)
            .background {
                Color.white.ignoresSafeArea(edges: .bottom)
            }
            .ignoresSafeArea(edges: .bottom)
        }
        .onAppear { visible = selected }
    }

    private var carousel: some View {
        GeometryReader { geo in
            let inset = max(22, (geo.size.width - 168) / 2)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(HomeWidgetStyle.allCases) { style in
                        card(style)
                            .id(style)
                    }
                }
                .scrollTargetLayout()
                .padding(.vertical, 4)
            }
            .scrollClipDisabled()
            .contentMargins(.horizontal, inset, for: .scrollContent)
            .scrollTargetBehavior(.viewAligned)
            .scrollPosition(id: $visible, anchor: .center)
            .onChange(of: visible) { _, newValue in
                if let newValue, newValue != selected {
                    selected = newValue
                }
            }
        }
        .frame(height: 256)
    }

    private func card(_ style: HomeWidgetStyle) -> some View {
        let active = selected == style
        return Button {
            selected = style
            visible = style
        } label: {
            VStack(spacing: 8) {
                WidgetPreviewCard(word: word, style: style, side: 140)
                Text(style.localizedName(for: model.language))
                    .font(MiBarFont.ui(size: 14, weight: .bold))
                    .foregroundStyle(Color.black)
                Text(style.localizedHint(for: model.language))
                    .font(MiBarFont.ui(size: 10))
                    .foregroundStyle(Color.inkSoft)
            }
            .padding(.top, 14)
            .padding(.horizontal, 12)
            .padding(.bottom, 12)
            .frame(width: 168)
            .background(active ? Color.navy.opacity(0.04) : Color.paper)
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .strokeBorder(active ? Color.navy : Color.navy.opacity(0.1), lineWidth: active ? 2 : 1)
            }
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(active ? .isSelected : [])
    }

    private func stepGroup(_ title: String, _ steps: [String]) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(MiBarFont.ui(size: 11, weight: .bold))
                .tracking(1.1)
                .textCase(.uppercase)
                .foregroundStyle(Color.brandBlue)
                .padding(.bottom, 2)
            ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text("\(index + 1).")
                    Text(.init(step))
                        .fixedSize(horizontal: false, vertical: true)
                }
                .font(MiBarFont.ui(size: 13))
                .foregroundStyle(Color.black)
            }
        }
    }
}

struct ArchivePage: View {
    var savedIDs: [Int]
    var onOpen: (Word) -> Void
    var onToggleSave: (Int) -> Void
    @EnvironmentObject private var model: AppModel

    var body: some View {
        let copy = model.language.copy
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top, spacing: 16) {
                VStack(alignment: .leading, spacing: 0) {
                    Kicker(text: copy.archiveKicker)
                    Text(copy.archiveTitle)
                        .font(MiBarFont.ui(size: 41, editorial: true))
                        .tracking(-1.64)
                        .foregroundStyle(Color.black)
                        .padding(.top, 9)
                    Text(copy.archiveSubtitle)
                        .font(MiBarFont.ui(size: 13))
                        .foregroundStyle(Color.inkSoft)
                        .lineSpacing(3)
                        .padding(.top, 8)
                        .frame(maxWidth: 260, alignment: .leading)
                }
                Spacer(minLength: 8)
                countBlock(value: Word.catalog.count, label: copy.wordsCountLabel)
                    .padding(.top, 18)
            }

            HStack(spacing: 13) {
                Text(copy.archiveMonth)
                    .font(MiBarFont.ui(size: 9, weight: .semibold))
                    .tracking(1.08)
                    .textCase(.uppercase)
                    .foregroundStyle(Color.inkSoft)
                Rectangle().fill(Color.line).frame(height: 1)
            }
            .padding(.top, 39)

            VStack(spacing: 0) {
                ForEach(Array(Word.catalog.enumerated()), id: \.element.id) { index, word in
                    wordRow(word, isToday: index == 0, todayLabel: copy.todayBadge)
                }
            }
            .padding(.top, 9)
        }
        .padding(.horizontal, 25)
        .padding(.top, 20)
        .padding(.bottom, 26)
    }

    private func wordRow(_ word: Word, isToday: Bool, todayLabel: String) -> some View {
        let saved = savedIDs.contains(word.id)
        let gloss: String = {
            switch model.language {
            case .ru: return "\(word.russian) · \(word.english)"
            case .en, .hy: return "\(word.english) · \(word.russian)"
            }
        }()
        return HStack(spacing: 0) {
            Button {
                onOpen(word)
            } label: {
                HStack(spacing: 10) {
                    Text(word.dayNumber)
                        .font(MiBarFont.ui(size: 12, editorial: true))
                        .foregroundStyle(Color.muted6)
                        .frame(width: 28, alignment: .leading)
                    VStack(alignment: .leading, spacing: 3) {
                        Text(word.armenian)
                            .font(MiBarFont.ui(size: 21, weight: .semibold, editorial: true))
                            .foregroundStyle(Color.black)
                            .lineLimit(1)
                        Text(gloss)
                            .font(MiBarFont.ui(size: 12))
                            .foregroundStyle(Color.brandBlue)
                            .lineLimit(1)
                    }
                    Spacer(minLength: 0)
                    MiBarIconView(name: .arrow, size: 19)
                        .foregroundStyle(Color.muted3)
                }
                .padding(.vertical, 18)
                .contentShape(Rectangle())
            }
            .buttonStyle(MiBarPressStyle())
            .accessibilityLabel("Open \(word.armenian)")

            Button {
                onToggleSave(word.id)
            } label: {
                MiBarIconView(name: saved ? .bookmarked : .bookmark, size: 19)
                    .foregroundStyle(Color.black)
                    .frame(width: 34, height: 34)
            }
            .buttonStyle(MiBarPressStyle())
            .accessibilityLabel(saved ? "Remove from favorites" : "Save")
        }
        .overlay(alignment: .bottom) {
            Rectangle().fill(Color.line).frame(height: 1)
        }
        .overlay(alignment: .topLeading) {
            if isToday {
                Text(todayLabel)
                    .font(MiBarFont.ui(size: 7, weight: .bold))
                    .tracking(0.7)
                    .textCase(.uppercase)
                    .foregroundStyle(Color.orangeBrand)
                    .padding(.leading, 38)
                    .padding(.top, 8)
                    .allowsHitTesting(false)
            }
        }
    }
}

struct FavoritesPage: View {
    var words: [Word]
    var onOpen: (Word) -> Void
    var onRemove: (Int) -> Void
    @EnvironmentObject private var model: AppModel

    var body: some View {
        let copy = model.language.copy
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 0) {
                    Kicker(text: copy.favoritesKicker)
                    Text(copy.favoritesTitle)
                        .font(MiBarFont.ui(size: 41, editorial: true))
                        .tracking(-1.64)
                        .foregroundStyle(Color.black)
                        .padding(.top, 9)
                }
                Spacer()
                if !words.isEmpty {
                    countBlock(value: words.count, label: copy.savedCountLabel)
                }
            }

            if words.isEmpty {
                EmptyFavorites(copy: copy)
            } else {
                VStack(spacing: 11) {
                    ForEach(words) { word in
                        favoriteCard(word)
                    }
                }
                .padding(.top, 37)
            }
        }
        .padding(.horizontal, 25)
        .padding(.top, 20)
        .padding(.bottom, 26)
    }

    private func favoriteCard(_ word: Word) -> some View {
        let gloss: String = {
            switch model.language {
            case .ru: return "\(word.russian) · \(word.english)"
            case .en, .hy: return "\(word.english) · \(word.russian)"
            }
        }()
        return HStack(alignment: .top, spacing: 8) {
            Button {
                onOpen(word)
            } label: {
                VStack(alignment: .leading, spacing: 0) {
                    Text(word.pos.localizedTitle(for: model.language))
                        .font(MiBarFont.ui(size: 11, weight: .semibold))
                        .opacity(0.85)
                    Text(word.armenian)
                        .font(MiBarFont.ui(size: 31, weight: .semibold, editorial: true))
                        .padding(.top, 9)
                    Text(gloss)
                        .font(MiBarFont.ui(size: 13))
                        .opacity(0.85)
                        .padding(.top, 8)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
            }
            .buttonStyle(MiBarPressStyle())
            .accessibilityLabel("Open \(word.armenian)")

            Button {
                onRemove(word.id)
            } label: {
                MiBarIconView(name: .close, size: 18)
                    .frame(width: 34, height: 34)
            }
            .buttonStyle(MiBarPressStyle())
            .accessibilityLabel("Remove \(word.armenian)")
        }
        .padding(.leading, 20)
        .padding(.trailing, 15)
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity, minHeight: 116, alignment: .top)
        .foregroundStyle(word.pos.foreground)
        .background(word.pos.background)
        .clipShape(
            UnevenRoundedRectangle(
                topLeadingRadius: 4,
                bottomLeadingRadius: 4,
                bottomTrailingRadius: 4,
                topTrailingRadius: 24
            )
        )
    }
}

private struct EmptyFavorites: View {
    var copy: L10n

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Rectangle()
                    .fill(Color.line)
                    .frame(width: 1, height: 31)
                    .offset(y: -68)
                Circle()
                    .stroke(Color.navy.opacity(0.2), lineWidth: 1)
                    .frame(width: 103, height: 103)
                MiBarIconView(name: .bookmark, size: 30)
                    .foregroundStyle(Color.orangeBrand)
                Text("Ա")
                    .font(MiBarFont.ui(size: 28, editorial: true))
                    .foregroundStyle(Color.brandBlue)
                    .offset(x: 42, y: 34)
                Rectangle()
                    .fill(Color.line)
                    .frame(width: 1, height: 31)
                    .offset(y: 68)
            }
            .frame(height: 170)

            Text(copy.emptyFavoritesTitle)
                .font(MiBarFont.ui(size: 28, editorial: true))
                .tracking(-0.84)
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.black)
                .padding(.top, 20)
            Text(copy.emptyFavoritesBody)
                .font(MiBarFont.ui(size: 12))
                .foregroundStyle(Color.inkSoft)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .frame(maxWidth: 270)
                .padding(.top, 14)
            Text(copy.emptyFavoritesFootnote)
                .font(MiBarFont.ui(size: 11, italic: true, editorial: true))
                .foregroundStyle(Color.orangeBrand)
                .padding(.top, 28)
        }
        .frame(maxWidth: .infinity, minHeight: 520)
    }
}

private func countBlock(value: Int, label: String) -> some View {
    VStack(alignment: .trailing, spacing: 2) {
        Text("\(value)")
            .font(MiBarFont.ui(size: 25, weight: .medium, editorial: true))
            .foregroundStyle(Color.orangeBrand)
        Text(label)
            .font(MiBarFont.ui(size: 8))
            .tracking(0.5)
            .textCase(.uppercase)
            .foregroundStyle(Color.inkSoft)
    }
}

struct SettingsSheet: View {
    @Binding var language: AppLanguage
    var onLogout: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Kicker(text: "Settings")
                    Text("Preferences")
                        .font(MiBarFont.ui(size: 28, weight: .semibold, editorial: true))
                        .tracking(-1.12)
                        .foregroundStyle(Color.black)
                }
                Spacer(minLength: 8)
                IconButton(icon: .close, size: 18) { dismiss() }
            }
            .padding(.horizontal, 22)
            .padding(.top, 8)

            Text("Language")
                .font(MiBarFont.ui(size: 11, weight: .bold))
                .tracking(1.1)
                .textCase(.uppercase)
                .foregroundStyle(Color.brandBlue)
                .padding(.horizontal, 22)
                .padding(.top, 28)

            VStack(spacing: 10) {
                ForEach(AppLanguage.allCases) { option in
                    languageRow(option)
                }
            }
            .padding(.horizontal, 22)
            .padding(.top, 12)

            Spacer(minLength: 24)

            Button(action: onLogout) {
                HStack {
                    Text("Log out")
                        .font(MiBarFont.ui(size: 16, weight: .semibold))
                    Spacer()
                    MiBarIconView(name: .arrow, size: 20)
                }
                .foregroundStyle(Color.orangeBrand)
                .padding(.horizontal, 18)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(Color.orangeBrand.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .buttonStyle(MiBarPressStyle())
            .padding(.horizontal, 22)
            .padding(.bottom, 28)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.paper.ignoresSafeArea())
    }

    private func languageRow(_ option: AppLanguage) -> some View {
        let active = language == option
        return Button {
            language = option
        } label: {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(option.native)
                        .font(MiBarFont.ui(size: 18, weight: .semibold, editorial: true))
                        .foregroundStyle(Color.black)
                    Text(option.sample)
                        .font(MiBarFont.ui(size: 12))
                        .foregroundStyle(Color.inkSoft)
                }
                Spacer(minLength: 0)
                ZStack {
                    Circle()
                        .fill(active ? Color.navy : Color.clear)
                    Circle()
                        .stroke(active ? Color.navy : Color.black.opacity(0.14), lineWidth: 1.5)
                    if active {
                        MiBarIconView(name: .check, size: 16)
                            .foregroundStyle(Color.white)
                    }
                }
                .frame(width: 26, height: 26)
            }
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, minHeight: 64, alignment: .leading)
            .background(active ? Color.navy.opacity(0.04) : Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(active ? Color.navy : Color.black.opacity(0.1), lineWidth: 1.5)
            }
        }
        .buttonStyle(MiBarPressStyle())
        .accessibilityAddTraits(active ? .isSelected : [])
    }
}
