import AVFoundation
import SwiftUI

struct MainShell: View {
    @EnvironmentObject private var model: AppModel
    @State private var ready = true
    @State private var showWidget = false
    @State private var wordPendingSave: Word?

    private var today: Word { model.todayWord }

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
                            saved: model.isSaved(detail.id),
                            isDetail: true,
                            onToggleSave: { handleSaveTap(for: detail) },
                            onBack: { model.detail = nil }
                        )
                    } else if model.tab == .today {
                        WordFeature(
                            word: today,
                            saved: model.isSaved(today.id),
                            widgetStyle: model.widgetStyle,
                            onToggleSave: { handleSaveTap(for: today) },
                            onChooseWidget: {
                                withAnimation(.easeOut(duration: 0.28)) { showWidget = true }
                            }
                        )
                    } else if model.tab == .archive {
                        ScrollView {
                            ArchivePage(
                                onOpen: { model.open($0) },
                                onToggleSave: { handleSaveTap(for: $0) }
                            )
                        }
                        .scrollIndicators(.hidden)
                    } else {
                        FavoritesPage(
                            onOpen: { model.open($0) }
                        )
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
                WidgetStyleSheet(word: today, selected: $model.widgetStyle) {
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
        .sheet(item: $wordPendingSave) { word in
            SaveToFolderSheet(word: word) {
                wordPendingSave = nil
            }
            .environmentObject(model)
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
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

    private func handleSaveTap(for word: Word) {
        if model.isSaved(word.id) {
            model.removeWordFromAllFavorites(word.id)
            return
        }
        if model.favoriteFolders.isEmpty {
            model.saveWord(word.id, toFolder: nil)
        } else {
            wordPendingSave = word
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

/// Plays recorded Armenian audio from the app bundle (`MiBar/Audio/word-{id}.m4a`).
final class Speaker: NSObject, ObservableObject, AVAudioPlayerDelegate {
    private var player: AVAudioPlayer?
    var onFinished: (() -> Void)?

    /// Looks for `word-{id}.m4a`, then `.mp3`, then `.caf` in the main bundle / Audio folder.
    func speak(wordID: Int) {
        stop()
        activateSession()
        guard let url = Self.audioURL(for: wordID) else {
            finish()
            return
        }
        do {
            let audio = try AVAudioPlayer(contentsOf: url)
            audio.delegate = self
            audio.prepareToPlay()
            player = audio
            audio.play()
        } catch {
            finish()
        }
    }

    func stop() {
        player?.stop()
        player = nil
    }

    private func finish() {
        onFinished?()
    }

    private func activateSession() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playback, mode: .spokenAudio, options: [.duckOthers])
            try session.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {}
    }

    static func audioURL(for wordID: Int) -> URL? {
        let name = "word-\(wordID)"
        for ext in ["m4a", "mp3", "caf"] {
            if let url = Bundle.main.url(forResource: name, withExtension: ext, subdirectory: "Audio") {
                return url
            }
            if let url = Bundle.main.url(forResource: name, withExtension: ext) {
                return url
            }
        }
        return nil
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        DispatchQueue.main.async { self.finish() }
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
    @State private var showSupport = false
    @State private var reopenSettingsAfterSupport = false
    @State private var showSharePage = false
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
            speaker.stop()
        }
        .overlay {
            if showSharePage {
                WordSharePage(
                    word: word,
                    language: model.language,
                    wordsCompleted: Word.catalog.count
                ) {
                    withAnimation(.easeOut(duration: 0.28)) {
                        showSharePage = false
                    }
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .trailing).combined(with: .opacity)
                ))
                .zIndex(40)
            }
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
                onOpenSupport: {
                    reopenSettingsAfterSupport = true
                    showSettings = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                        showSupport = true
                    }
                },
                onLogout: {
                    showSettings = false
                    model.logout()
                }
            )
            .environmentObject(model)
        }
        .fullScreenCover(isPresented: $showSupport, onDismiss: {
            guard reopenSettingsAfterSupport else { return }
            reopenSettingsAfterSupport = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                showSettings = true
            }
        }) {
            SupportSheet(language: model.language)
                .environmentObject(model)
        }
    }

    private var hero: some View {
        VStack(spacing: 0) {
            Text(isDetail ? copy.fromTheArchive : copy.wordOfTheDay)
                .font(MiBarFont.ui(size: 9, weight: .semibold))
                .tracking(1.44)
                .textCase(.uppercase)
                .foregroundStyle(Color.orangeSoft)

            AdaptiveArmenianWord(
                text: word.armenian,
                size: ScreenMetrics.armenianWord,
                weight: UIFont.Weight.medium,
                color: .white,
                minScale: 0.32,
                alignment: .center
            )
            .padding(.horizontal, 8)
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
                Text(word.gloss(for: model.language))
                    .font(MiBarFont.ui(size: 17, weight: .medium))
                    .foregroundStyle(Color.white.opacity(0.82))
                    .multilineTextAlignment(.center)
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
            Text(word.gloss(for: model.language))
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
            withAnimation(.easeOut(duration: 0.28)) {
                showSharePage = true
            }
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
                Text(word.phraseTranslation(for: model.language))
                    .font(MiBarFont.ui(size: 16, weight: .medium))
                    .foregroundStyle(Color.black)
                    .padding(.top, 10)
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
        if playing {
            playing = false
            speaker.stop()
            return
        }
        playing = true
        speaker.onFinished = {
            playing = false
        }
        speaker.speak(wordID: word.id)
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
            AdaptiveArmenianWord(
                text: word.armenian,
                size: large ? 26 : 22,
                weight: UIFont.Weight.semibold,
                color: primary,
                minScale: 0.32,
                alignment: .leading
            )
            .layoutPriority(1)
            Text("[\(word.transliteration)]")
                .font(MiBarFont.ui(size: large ? 11 : 10, italic: true, editorial: true))
                .foregroundStyle(meta)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .allowsTightening(true)
            Text(word.gloss(for: model.language))
                .font(MiBarFont.ui(size: large ? 9 : 8, weight: .medium))
                .foregroundStyle(translation)
                .lineLimit(2)
                .minimumScaleFactor(0.65)
                .allowsTightening(true)
        }
        .padding(.horizontal, large ? 13 : 10)
        .padding(.vertical, large ? 15 : 12)
        .frame(width: side, height: side, alignment: .leading)
        .background { background }
        .clipShape(RoundedRectangle(cornerRadius: large ? 26 : 22, style: .continuous))
        .overlay {
            if style == .soft || style == .clear {
                RoundedRectangle(cornerRadius: large ? 26 : 22, style: .continuous)
                    .stroke(style == .clear ? Color.white.opacity(0.55) : Color.navy.opacity(0.1), lineWidth: 1)
            }
        }
        .shadow(color: Color.navy.opacity(style == .clear ? 0.1 : 0.18), radius: style == .clear ? 10 : 12, y: 8)
    }

    private var kicker: Color {
        switch style {
        case .classic: return .orangeSoft
        case .soft: return .orangeBrand
        case .sun: return Color.white.opacity(0.8)
        case .clear: return Color.primary.opacity(0.62)
        }
    }

    private var primary: Color {
        switch style {
        case .classic, .sun: return .white
        case .soft: return .navy
        case .clear: return .primary
        }
    }

    private var meta: Color {
        switch style {
        case .classic: return .translitBlue
        case .soft: return .brandBlue
        case .sun: return .sunMeta
        case .clear: return .secondary
        }
    }

    private var translation: Color {
        switch style {
        case .classic: return Color.white.opacity(0.72)
        case .soft: return .inkSoft
        case .sun: return Color.white.opacity(0.8)
        case .clear: return Color.primary.opacity(0.72)
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
                // Faux wallpaper so frosted glass reads in-app (real widget blurs Home Screen).
                LinearGradient(
                    colors: [Color(hex: 0x90B4D8), Color(hex: 0xD9C4A8), Color(hex: 0xC7A07A)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                Rectangle().fill(.ultraThinMaterial)
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
    var onOpen: (Word) -> Void
    var onToggleSave: (Word) -> Void
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
        let saved = model.isSaved(word.id)
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
                        Text(word.gloss(for: model.language))
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
                onToggleSave(word)
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
    var onOpen: (Word) -> Void
    @EnvironmentObject private var model: AppModel
    @State private var openedFolderID: UUID?
    @State private var showCreateFolder = false
    @State private var newFolderName = ""

    private var copy: L10n { model.language.copy }
    private var generalWords: [Word] { model.savedWords }
    private var folders: [FavoriteFolder] { model.sortedFavoriteFolders }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    header

                    if !folders.isEmpty {
                        Text(copy.collectionsLabel)
                            .font(MiBarFont.ui(size: 11, weight: .bold))
                            .tracking(1.1)
                            .textCase(.uppercase)
                            .foregroundStyle(Color.brandBlue)
                            .padding(.top, 28)

                        LazyVGrid(
                            columns: [
                                GridItem(.flexible(), spacing: 8),
                                GridItem(.flexible(), spacing: 8),
                                GridItem(.flexible(), spacing: 8),
                            ],
                            spacing: 8
                        ) {
                            ForEach(folders) { folder in
                                Button {
                                    openedFolderID = folder.id
                                } label: {
                                    folderSquare(folder)
                                }
                                .buttonStyle(MiBarPressStyle())
                            }
                        }
                        .padding(.top, 12)
                    }

                    Text(copy.generalCollection)
                        .font(MiBarFont.ui(size: 11, weight: .bold))
                        .tracking(1.1)
                        .textCase(.uppercase)
                        .foregroundStyle(Color.brandBlue)
                        .padding(.top, 28)

                    if generalWords.isEmpty && folders.isEmpty {
                        EmptyFavorites(copy: copy)
                            .padding(.top, 8)
                    } else if generalWords.isEmpty {
                        Text(copy.emptyCollectionBody)
                            .font(MiBarFont.ui(size: 14))
                            .foregroundStyle(Color.inkSoft)
                            .padding(.top, 14)
                    } else {
                        VStack(spacing: 11) {
                            ForEach(generalWords) { word in
                                favoriteCard(word, folderID: nil)
                            }
                        }
                        .padding(.top, 14)
                    }
                }
                .padding(.horizontal, 25)
                .padding(.top, 20)
                .padding(.bottom, 26)
            }
            .scrollIndicators(.hidden)
            .background(Color.paper.ignoresSafeArea())
            .navigationBarHidden(true)
            .navigationDestination(item: $openedFolderID) { folderID in
                FavoriteFolderDetail(
                    folderID: folderID,
                    onOpen: onOpen
                )
                .environmentObject(model)
            }
            .overlay {
                if showCreateFolder {
                    CreateCollectionModal(
                        name: $newFolderName,
                        copy: copy,
                        onCancel: {
                            withAnimation(.easeOut(duration: 0.2)) {
                                showCreateFolder = false
                            }
                            newFolderName = ""
                        },
                        onCreate: {
                            let createdID = model.createFavoriteFolder(name: newFolderName)
                            withAnimation(.easeOut(duration: 0.2)) {
                                showCreateFolder = false
                            }
                            newFolderName = ""
                            if let createdID {
                                openedFolderID = createdID
                            }
                        }
                    )
                    .transition(.opacity.combined(with: .scale(scale: 0.96)))
                    .zIndex(10)
                }
            }
            .animation(.easeOut(duration: 0.22), value: showCreateFolder)
        }
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 0) {
                Kicker(text: copy.favoritesKicker)
                Text(copy.favoritesTitle)
                    .font(MiBarFont.ui(size: 41, editorial: true))
                    .tracking(-1.64)
                    .foregroundStyle(Color.black)
                    .padding(.top, 9)
            }
            Spacer(minLength: 12)
            HStack(alignment: .center, spacing: 10) {
                Button {
                    newFolderName = ""
                    withAnimation(.easeOut(duration: 0.22)) {
                        showCreateFolder = true
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "plus")
                            .font(.system(size: 10, weight: .bold))
                        Text(copy.createCollection)
                            .font(MiBarFont.ui(size: 11, weight: .semibold))
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                    .foregroundStyle(Color.navy)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 7)
                    .background(Color.white)
                    .clipShape(Capsule())
                    .overlay {
                        Capsule()
                            .stroke(Color.navy.opacity(0.18), lineWidth: 1.2)
                    }
                }
                .buttonStyle(MiBarPressStyle())
                .accessibilityLabel(copy.createCollection)

                if model.allFavoriteCount > 0 {
                    countBlock(value: model.allFavoriteCount, label: copy.savedCountLabel)
                }
            }
            .padding(.top, 10)
        }
    }

    private func folderSquare(_ folder: FavoriteFolder) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Image(systemName: "bookmark.fill")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(Color.white.opacity(0.7))
                Spacer(minLength: 0)
                Image(systemName: "arrow.up.right")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(Color.white.opacity(0.55))
            }

            Spacer(minLength: 0)

            Text(folder.name)
                .font(MiBarFont.ui(size: 14, weight: .semibold, editorial: true))
                .tracking(-0.3)
                .foregroundStyle(Color.white)
                .lineLimit(2)
                .minimumScaleFactor(0.75)
                .multilineTextAlignment(.leading)

            Text("\(folder.wordIDs.count)")
                .font(MiBarFont.ui(size: 10, weight: .medium))
                .foregroundStyle(Color.white.opacity(0.75))
                .padding(.top, 4)
        }
        .padding(10)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .aspectRatio(1, contentMode: .fit)
        .background(Color.collectionCard)
        .clipShape(
            UnevenRoundedRectangle(
                topLeadingRadius: 3,
                bottomLeadingRadius: 3,
                bottomTrailingRadius: 3,
                topTrailingRadius: 16
            )
        )
    }

    private func favoriteCard(_ word: Word, folderID: UUID?) -> some View {
        HStack(alignment: .top, spacing: 8) {
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
                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Text("[\(word.transliteration)]")
                            .font(MiBarFont.ui(size: 11, italic: true, editorial: true))
                            .opacity(0.7)
                        Text(word.gloss(for: model.language))
                            .font(MiBarFont.ui(size: 13))
                            .opacity(0.85)
                    }
                    .padding(.top, 8)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
            }
            .buttonStyle(MiBarPressStyle())
            .accessibilityLabel("Open \(word.armenian)")

            Button {
                model.removeWord(word.id, fromFolder: folderID)
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

private struct CreateCollectionModal: View {
    @Binding var name: String
    var copy: L10n
    var onCancel: () -> Void
    var onCreate: () -> Void

    @FocusState private var focused: Bool

    private var canCreate: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        ZStack {
            Color.navy.opacity(0.42)
                .ignoresSafeArea()
                .onTapGesture {
                    focused = false
                    onCancel()
                }

            VStack(alignment: .leading, spacing: 0) {
                Text(copy.collectionsLabel)
                    .font(MiBarFont.ui(size: 11, weight: .bold))
                    .tracking(1.1)
                    .textCase(.uppercase)
                    .foregroundStyle(Color.brandBlue)

                Text(copy.createCollectionTitle)
                    .font(MiBarFont.ui(size: 28, weight: .semibold, editorial: true))
                    .tracking(-0.7)
                    .foregroundStyle(Color.black)
                    .padding(.top, 8)

                TextField(copy.collectionNamePlaceholder, text: $name)
                    .font(MiBarFont.ui(size: 17, weight: .medium))
                    .foregroundStyle(Color.black)
                    .focused($focused)
                    .textInputAutocapitalization(.sentences)
                    .submitLabel(.done)
                    .onSubmit {
                        guard canCreate else { return }
                        onCreate()
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 14)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(
                                focused ? Color.navy.opacity(0.35) : Color.black.opacity(0.1),
                                lineWidth: 1.5
                            )
                    }
                    .padding(.top, 22)

                HStack(spacing: 10) {
                    Button(action: onCancel) {
                        Text(copy.cancel)
                            .font(MiBarFont.ui(size: 15, weight: .semibold))
                            .foregroundStyle(Color.navy)
                            .frame(maxWidth: .infinity, minHeight: 48)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            .overlay {
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .stroke(Color.navy.opacity(0.18), lineWidth: 1.5)
                            }
                    }
                    .buttonStyle(MiBarPressStyle())

                    Button(action: onCreate) {
                        Text(copy.createCollectionConfirm)
                            .font(MiBarFont.ui(size: 15, weight: .semibold))
                            .foregroundStyle(Color.white)
                            .frame(maxWidth: .infinity, minHeight: 48)
                            .background(canCreate ? Color.orangeBrand : Color.navy.opacity(0.25))
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                    .buttonStyle(MiBarPressStyle())
                    .disabled(!canCreate)
                }
                .padding(.top, 16)
            }
            .padding(22)
            .frame(maxWidth: 340)
            .background(Color.paper)
            .clipShape(
                UnevenRoundedRectangle(
                    topLeadingRadius: 8,
                    bottomLeadingRadius: 8,
                    bottomTrailingRadius: 8,
                    topTrailingRadius: 28
                )
            )
            .shadow(color: Color.navy.opacity(0.22), radius: 28, y: 14)
            .padding(.horizontal, 28)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
                    focused = true
                }
            }
        }
    }
}

struct FavoriteFolderDetail: View {
    var folderID: UUID
    var onOpen: (Word) -> Void

    @EnvironmentObject private var model: AppModel
    @Environment(\.dismiss) private var dismiss

    private var copy: L10n { model.language.copy }

    private var folder: FavoriteFolder? {
        model.favoriteFolders.first(where: { $0.id == folderID })
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center) {
                Button {
                    dismiss()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .semibold))
                        Text(copy.back)
                            .font(MiBarFont.ui(size: 14, weight: .medium))
                    }
                    .foregroundStyle(Color.navy.opacity(0.7))
                }
                .buttonStyle(.plain)

                Spacer(minLength: 8)

                Text(folder?.name ?? copy.collectionsLabel)
                    .font(MiBarFont.ui(size: 16, weight: .semibold))
                    .foregroundStyle(Color.black)
                    .lineLimit(1)

                Spacer(minLength: 8)
                Color.clear.frame(width: 72, height: 1)
            }
            .padding(.horizontal, 18)
            .padding(.top, 8)
            .padding(.bottom, 12)

            ScrollView {
                VStack(alignment: .leading, spacing: 11) {
                    if let folder, !folder.words.isEmpty {
                        ForEach(folder.words) { word in
                            favoriteDetailCard(word)
                        }
                    } else {
                        Text(copy.emptyCollectionBody)
                            .font(MiBarFont.ui(size: 14))
                            .foregroundStyle(Color.inkSoft)
                            .padding(.top, 24)
                    }
                }
                .padding(.horizontal, 25)
                .padding(.bottom, 28)
            }
            .scrollIndicators(.hidden)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.paper.ignoresSafeArea())
        .navigationBarHidden(true)
    }

    private func favoriteDetailCard(_ word: Word) -> some View {
        HStack(alignment: .top, spacing: 8) {
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
                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Text("[\(word.transliteration)]")
                            .font(MiBarFont.ui(size: 11, italic: true, editorial: true))
                            .opacity(0.7)
                        Text(word.gloss(for: model.language))
                            .font(MiBarFont.ui(size: 13))
                            .opacity(0.85)
                    }
                    .padding(.top, 8)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
            }
            .buttonStyle(MiBarPressStyle())

            Button {
                model.removeWord(word.id, fromFolder: folderID)
            } label: {
                MiBarIconView(name: .close, size: 18)
                    .frame(width: 34, height: 34)
            }
            .buttonStyle(MiBarPressStyle())
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

struct SaveToFolderSheet: View {
    var word: Word
    var onDone: () -> Void

    @EnvironmentObject private var model: AppModel

    private var copy: L10n { model.language.copy }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Capsule()
                .fill(Color.navy.opacity(0.14))
                .frame(width: 42, height: 4)
                .frame(maxWidth: .infinity)
                .padding(.top, 10)
                .padding(.bottom, 18)

            Text(copy.saveToTitle)
                .font(MiBarFont.ui(size: 13, weight: .bold))
                .tracking(1.0)
                .textCase(.uppercase)
                .foregroundStyle(Color.brandBlue)

            Text(word.armenian)
                .font(MiBarFont.ui(size: 28, weight: .semibold, editorial: true))
                .foregroundStyle(Color.black)
                .padding(.top, 8)

            Text(word.gloss(for: model.language))
                .font(MiBarFont.ui(size: 14))
                .foregroundStyle(Color.inkSoft)
                .padding(.top, 4)

            VStack(spacing: 10) {
                destinationButton(title: copy.generalCollection, subtitle: copy.saveToGeneral, systemImage: "tray") {
                    model.saveWord(word.id, toFolder: nil)
                    onDone()
                }

                ForEach(model.sortedFavoriteFolders) { folder in
                    destinationButton(
                        title: folder.name,
                        subtitle: "\(folder.wordIDs.count) \(copy.wordsInCollectionLabel)",
                        systemImage: "folder.fill"
                    ) {
                        model.saveWord(word.id, toFolder: folder.id)
                        onDone()
                    }
                }
            }
            .padding(.top, 24)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 22)
        .padding(.bottom, 24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.paper.ignoresSafeArea())
    }

    private func destinationButton(
        title: String,
        subtitle: String,
        systemImage: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                ZStack {
                    Circle().fill(Color.navy.opacity(0.08))
                    Image(systemName: systemImage)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.navy.opacity(0.75))
                }
                .frame(width: 40, height: 40)

                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(MiBarFont.ui(size: 16, weight: .semibold))
                        .foregroundStyle(Color.black)
                    Text(subtitle)
                        .font(MiBarFont.ui(size: 12))
                        .foregroundStyle(Color.inkSoft)
                }

                Spacer(minLength: 0)

                Image(systemName: "plus")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Color.navy.opacity(0.35))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color.black.opacity(0.08), lineWidth: 1)
            }
        }
        .buttonStyle(MiBarPressStyle())
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
    var onOpenSupport: () -> Void
    var onLogout: () -> Void

    @EnvironmentObject private var model: AppModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL

    private var copy: L10n { language.copy }

    private var appVersion: String {
        let short = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        if let build, build != short {
            return "\(short) (\(build))"
        }
        return short
    }

    private var accountEmail: String {
        let value = model.email.trimmingCharacters(in: .whitespacesAndNewlines)
        return value.isEmpty ? "—" : value
    }

    private var termsURL: URL { URL(string: "https://mibar.app/terms")! }
    private var privacyURL: URL { URL(string: "https://mibar.app/privacy")! }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Capsule()
                .fill(Color.navy.opacity(0.14))
                .frame(width: 42, height: 4)
                .frame(maxWidth: .infinity)
                .padding(.top, 10)
                .padding(.bottom, 14)

            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Kicker(text: copy.settingsTitle)
                    Text(copy.settingsPreferences)
                        .font(MiBarFont.ui(size: 28, weight: .semibold, editorial: true))
                        .tracking(-1.12)
                        .foregroundStyle(Color.black)
                }
                Spacer(minLength: 8)
                IconButton(icon: .close, size: 18) { dismiss() }
            }
            .padding(.horizontal, 22)

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    sectionLabel(copy.settingsAccount)
                        .padding(.top, 24)

                    infoRow(
                        title: copy.settingsEmail,
                        subtitle: accountEmail
                    )
                    .padding(.top, 12)

                    sectionLabel(copy.settingsLanguage)
                        .padding(.top, 28)

                    VStack(spacing: 10) {
                        ForEach(AppLanguage.allCases) { option in
                            languageRow(option)
                        }
                    }
                    .padding(.top, 12)

                    sectionLabel(copy.settingsNotifications)
                        .padding(.top, 28)

                    reminderRow
                        .padding(.top, 12)

                    sectionLabel(copy.settingsSupport)
                        .padding(.top, 28)

                    Button(action: onOpenSupport) {
                        navigationRow(
                            title: copy.settingsSupport,
                            subtitle: copy.settingsSupportSubtitle
                        )
                    }
                    .buttonStyle(MiBarPressStyle())
                    .padding(.top, 12)
                    .accessibilityLabel(copy.settingsSupport)

                    sectionLabel(copy.settingsLegal)
                        .padding(.top, 28)

                    VStack(spacing: 10) {
                        Button {
                            openURL(termsURL)
                        } label: {
                            navigationRow(title: copy.settingsTerms, subtitle: nil)
                        }
                        .buttonStyle(MiBarPressStyle())

                        Button {
                            openURL(privacyURL)
                        } label: {
                            navigationRow(title: copy.settingsPrivacy, subtitle: nil)
                        }
                        .buttonStyle(MiBarPressStyle())
                    }
                    .padding(.top, 12)

                    sectionLabel(copy.settingsAbout)
                        .padding(.top, 28)

                    infoRow(
                        title: copy.settingsVersion,
                        subtitle: appVersion
                    )
                    .padding(.top, 12)

                    Button(action: onLogout) {
                        HStack {
                            Text(copy.settingsLogOut)
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
                    .padding(.top, 28)
                    .padding(.bottom, 12)
                }
                .padding(.horizontal, 22)
            }
            .scrollIndicators(.hidden)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.paper.ignoresSafeArea())
        .presentationDetents([.large])
        .presentationDragIndicator(.hidden)
    }

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(MiBarFont.ui(size: 11, weight: .bold))
            .tracking(1.1)
            .textCase(.uppercase)
            .foregroundStyle(Color.brandBlue)
    }

    private var reminderRow: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text(copy.settingsDailyReminder)
                    .font(MiBarFont.ui(size: 18, weight: .semibold, editorial: true))
                    .foregroundStyle(Color.black)
                Text(copy.settingsDailyReminderSubtitle)
                    .font(MiBarFont.ui(size: 12))
                    .foregroundStyle(Color.inkSoft)
            }
            Spacer(minLength: 0)
            Toggle("", isOn: $model.dailyReminderEnabled)
                .labelsHidden()
                .tint(Color.navy)
        }
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, minHeight: 64, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.black.opacity(0.1), lineWidth: 1.5)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(copy.settingsDailyReminder)
    }

    private func infoRow(title: String, subtitle: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            Text(title)
                .font(MiBarFont.ui(size: 16, weight: .semibold))
                .foregroundStyle(Color.black)
            Spacer(minLength: 8)
            Text(subtitle)
                .font(MiBarFont.ui(size: 14))
                .foregroundStyle(Color.inkSoft)
                .multilineTextAlignment(.trailing)
                .lineLimit(2)
                .minimumScaleFactor(0.85)
        }
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, minHeight: 56, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.black.opacity(0.1), lineWidth: 1.5)
        }
    }

    private func navigationRow(title: String, subtitle: String?) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(MiBarFont.ui(size: 18, weight: .semibold, editorial: true))
                    .foregroundStyle(Color.black)
                if let subtitle {
                    Text(subtitle)
                        .font(MiBarFont.ui(size: 12))
                        .foregroundStyle(Color.inkSoft)
                        .multilineTextAlignment(.leading)
                }
            }
            Spacer(minLength: 0)
            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color.navy.opacity(0.35))
        }
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, minHeight: subtitle == nil ? 56 : 64, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.black.opacity(0.1), lineWidth: 1.5)
        }
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

private enum SupportNav: Hashable, Identifiable {
    case compose
    case conversation(UUID)

    var id: String {
        switch self {
        case .compose: return "compose"
        case .conversation(let id): return id.uuidString
        }
    }
}

struct SupportSheet: View {
    var language: AppLanguage

    @EnvironmentObject private var model: AppModel
    @Environment(\.dismiss) private var dismiss
    @State private var route: SupportNav?

    private var copy: L10n { language.copy }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HStack(alignment: .center) {
                    Button {
                        dismiss()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 14, weight: .semibold))
                            Text(copy.back)
                                .font(MiBarFont.ui(size: 14, weight: .medium))
                        }
                        .foregroundStyle(Color.navy.opacity(0.7))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(copy.back)

                    Spacer(minLength: 8)

                    Text(copy.supportTitle)
                        .font(MiBarFont.ui(size: 15, weight: .semibold))
                        .foregroundStyle(Color.black)

                    Spacer(minLength: 8)
                    Color.clear.frame(width: 72, height: 1)
                }
                .padding(.horizontal, 18)
                .padding(.top, 12)
                .padding(.bottom, 16)

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Button {
                            route = .compose
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: "square.and.pencil")
                                    .font(.system(size: 16, weight: .semibold))
                                Text(copy.supportWrite)
                                    .font(MiBarFont.ui(size: 16, weight: .semibold))
                                Spacer(minLength: 0)
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 13, weight: .semibold))
                                    .opacity(0.45)
                            }
                            .foregroundStyle(Color.white)
                            .padding(.horizontal, 18)
                            .frame(maxWidth: .infinity, minHeight: 56)
                            .background(Color.navy)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        }
                        .buttonStyle(MiBarPressStyle())
                        .accessibilityLabel(copy.supportWrite)

                        Text(copy.supportConversationsLabel)
                            .font(MiBarFont.ui(size: 11, weight: .bold))
                            .tracking(1.1)
                            .textCase(.uppercase)
                            .foregroundStyle(Color.brandBlue)
                            .padding(.top, 4)

                        if model.sortedSupportConversations.isEmpty {
                            Text(copy.supportInboxEmpty)
                                .font(MiBarFont.ui(size: 14))
                                .foregroundStyle(Color.inkSoft)
                                .multilineTextAlignment(.leading)
                                .padding(.top, 4)
                        } else {
                            VStack(spacing: 10) {
                                ForEach(model.sortedSupportConversations) { conversation in
                                    Button {
                                        route = .conversation(conversation.id)
                                    } label: {
                                        conversationRow(conversation)
                                    }
                                    .buttonStyle(MiBarPressStyle())
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 22)
                    .padding(.bottom, 28)
                }
                .scrollIndicators(.hidden)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(Color.paper.ignoresSafeArea())
            .navigationBarHidden(true)
            .navigationDestination(item: $route) { destination in
                switch destination {
                case .compose:
                    SupportChatView(language: language, conversationID: nil)
                        .environmentObject(model)
                case .conversation(let id):
                    SupportChatView(language: language, conversationID: id)
                        .environmentObject(model)
                }
            }
        }
    }

    private func conversationRow(_ conversation: SupportConversation) -> some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle().fill(Color.navy.opacity(0.08))
                Image(systemName: "bubble.left.and.bubble.right.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.navy.opacity(0.7))
            }
            .frame(width: 40, height: 40)

            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .firstTextBaseline) {
                    Text(conversation.topic.title(copy: copy))
                        .font(MiBarFont.ui(size: 15, weight: .semibold))
                        .foregroundStyle(Color.black)
                        .lineLimit(1)
                    Spacer(minLength: 8)
                    Text(Self.shortDate(conversation.updatedAt, language: language))
                        .font(MiBarFont.ui(size: 11, weight: .medium))
                        .foregroundStyle(Color.inkSoft)
                }

                Text(
                    conversation.previewText.isEmpty
                        ? copy.supportNoMessagesYet
                        : conversation.previewText
                )
                .font(MiBarFont.ui(size: 13))
                .foregroundStyle(Color.inkSoft)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
            }

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.navy.opacity(0.28))
                .padding(.top, 10)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.black.opacity(0.08), lineWidth: 1)
        }
    }

    private static func shortDate(_ date: Date, language: AppLanguage) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: language.rawValue == "hy" ? "hy_AM" : language.rawValue)
        formatter.doesRelativeDateFormatting = true
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct SupportChatView: View {
    var language: AppLanguage
    /// `nil` = compose a new request; conversation is created only on first send.
    var conversationID: UUID?

    @EnvironmentObject private var model: AppModel
    @Environment(\.dismiss) private var dismiss
    @State private var activeConversationID: UUID?
    @State private var draftTopic: SupportTopic = .problem
    @State private var draft = ""
    @State private var isSending = false
    @FocusState private var composerFocused: Bool

    private var copy: L10n { language.copy }
    private var trimmedDraft: String {
        draft.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var conversation: SupportConversation? {
        guard let activeConversationID else { return nil }
        return model.supportConversations.first(where: { $0.id == activeConversationID })
    }

    private var selectedTopic: SupportTopic {
        conversation?.topic ?? draftTopic
    }

    private var showsTopicPicker: Bool {
        conversation == nil || (conversation?.messages.isEmpty ?? true)
    }

    init(language: AppLanguage, conversationID: UUID?) {
        self.language = language
        self.conversationID = conversationID
        _activeConversationID = State(initialValue: conversationID)
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center) {
                Button {
                    composerFocused = false
                    dismiss()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .semibold))
                        Text(copy.back)
                            .font(MiBarFont.ui(size: 14, weight: .medium))
                    }
                    .foregroundStyle(Color.navy.opacity(0.7))
                }
                .buttonStyle(.plain)
                .accessibilityLabel(copy.back)

                Spacer(minLength: 8)

                VStack(spacing: 2) {
                    Text(copy.supportTitle)
                        .font(MiBarFont.ui(size: 13, weight: .bold))
                        .tracking(0.8)
                        .textCase(.uppercase)
                        .foregroundStyle(Color.brandBlue)
                    Text(
                        conversation == nil
                            ? copy.supportWrite
                            : selectedTopic.title(copy: copy)
                    )
                    .font(MiBarFont.ui(size: 15, weight: .semibold))
                    .foregroundStyle(Color.black)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                }

                Spacer(minLength: 8)
                Color.clear.frame(width: 72, height: 1)
            }
            .padding(.horizontal, 18)
            .padding(.top, 8)
            .padding(.bottom, 12)

            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        supportBubble(copy.supportHeadline)

                        if showsTopicPicker {
                            Text(copy.supportTopicLabel)
                                .font(MiBarFont.ui(size: 11, weight: .bold))
                                .tracking(1.1)
                                .textCase(.uppercase)
                                .foregroundStyle(Color.brandBlue)
                                .padding(.top, 4)

                            topicChips(selected: selectedTopic)
                        }

                        if let conversation {
                            ForEach(conversation.messages) { item in
                                chatRow(item)
                                    .id(item.id)
                            }
                        }

                        Color.clear.frame(height: 1).id("chatBottom")
                    }
                    .padding(.horizontal, 22)
                    .padding(.top, 8)
                    .padding(.bottom, 16)
                }
                .scrollIndicators(.hidden)
                .scrollDismissesKeyboard(.interactively)
                .onChange(of: conversation?.messages) { _, _ in
                    scrollChat(proxy)
                }
                .onChange(of: composerFocused) { _, focused in
                    guard focused else { return }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                        scrollChat(proxy)
                    }
                }
                .onAppear {
                    if let activeConversationID {
                        model.trimSupportTyping(in: activeConversationID)
                    }
                    isSending = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                        scrollChat(proxy)
                    }
                }
            }

            composer
                .padding(.horizontal, 16)
                .padding(.top, 10)
                .padding(.bottom, 12)
                .background {
                    Color.paper
                        .shadow(color: Color.navy.opacity(0.06), radius: 12, y: -4)
                }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.paper.ignoresSafeArea())
        .navigationBarHidden(true)
    }

    private func scrollChat(_ proxy: ScrollViewProxy) {
        withAnimation(.easeOut(duration: 0.25)) {
            proxy.scrollTo("chatBottom", anchor: .bottom)
        }
    }

    private func topicChips(selected: SupportTopic) -> some View {
        VStack(spacing: 8) {
            ForEach(SupportTopic.allCases) { option in
                let active = selected == option
                Button {
                    if let activeConversationID,
                       let index = model.supportConversationIndex(id: activeConversationID) {
                        model.supportConversations[index].topic = option
                    } else {
                        draftTopic = option
                    }
                } label: {
                    HStack {
                        Text(option.title(copy: copy))
                            .font(MiBarFont.ui(size: 14, weight: active ? .semibold : .medium))
                            .foregroundStyle(active ? Color.white : Color.navy)
                        Spacer(minLength: 0)
                        if active {
                            Image(systemName: "checkmark")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(Color.white.opacity(0.9))
                        }
                    }
                    .padding(.horizontal, 16)
                    .frame(maxWidth: .infinity, minHeight: 46, alignment: .leading)
                    .background(active ? Color.navy : Color.white)
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
    }

    @ViewBuilder
    private func chatRow(_ item: SupportChatMessage) -> some View {
        switch item.role {
        case .support:
            supportBubble(item.text)
        case .user:
            userBubble(item.text)
        case .typing:
            supportBubble(copy.supportTyping, muted: true)
        }
    }

    private func supportBubble(_ text: String, muted: Bool = false) -> some View {
        HStack(alignment: .top, spacing: 10) {
            ZStack {
                Circle().fill(Color.navy)
                Text("M")
                    .font(MiBarFont.ui(size: 12, weight: .bold))
                    .foregroundStyle(Color.white)
            }
            .frame(width: 28, height: 28)

            Text(text)
                .font(MiBarFont.ui(size: 15, weight: muted ? .medium : .regular))
                .foregroundStyle(muted ? Color.inkSoft : Color.black)
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(Color.white)
                .clipShape(
                    UnevenRoundedRectangle(
                        topLeadingRadius: 6,
                        bottomLeadingRadius: 18,
                        bottomTrailingRadius: 18,
                        topTrailingRadius: 18,
                        style: .continuous
                    )
                )
                .overlay {
                    UnevenRoundedRectangle(
                        topLeadingRadius: 6,
                        bottomLeadingRadius: 18,
                        bottomTrailingRadius: 18,
                        topTrailingRadius: 18,
                        style: .continuous
                    )
                    .stroke(Color.black.opacity(0.06), lineWidth: 1)
                }

            Spacer(minLength: 36)
        }
    }

    private func userBubble(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Spacer(minLength: 36)
            Text(text)
                .font(MiBarFont.ui(size: 15, weight: .medium))
                .foregroundStyle(Color.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(Color.navy)
                .clipShape(
                    UnevenRoundedRectangle(
                        topLeadingRadius: 18,
                        bottomLeadingRadius: 18,
                        bottomTrailingRadius: 6,
                        topTrailingRadius: 18,
                        style: .continuous
                    )
                )
        }
    }

    private var composer: some View {
        HStack(alignment: .bottom, spacing: 10) {
            TextField(copy.supportMessagePlaceholder, text: $draft, axis: .vertical)
                .lineLimit(1...5)
                .focused($composerFocused)
                .textInputAutocapitalization(.sentences)
                .submitLabel(.send)
                .onSubmit { send() }
                .font(MiBarFont.ui(size: 15))
                .foregroundStyle(Color.black)
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(
                            composerFocused ? Color.navy.opacity(0.35) : Color.black.opacity(0.1),
                            lineWidth: 1.5
                        )
                }
            Button {
                send()
            } label: {
                ZStack {
                    Circle()
                        .fill(canSend ? Color.orangeBrand : Color.navy.opacity(0.18))
                    if isSending {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Image(systemName: "arrow.up")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(Color.white)
                    }
                }
                .frame(width: 44, height: 44)
            }
            .buttonStyle(MiBarPressStyle())
            .disabled(!canSend)
            .accessibilityLabel(copy.supportSend)
        }
    }

    private var canSend: Bool {
        !trimmedDraft.isEmpty && !isSending
    }

    private func send() {
        let text = trimmedDraft
        guard !text.isEmpty, !isSending else { return }

        let topic = selectedTopic
        let conversationID: UUID
        if let existing = activeConversationID {
            conversationID = existing
        } else {
            conversationID = model.createSupportConversation(topic: topic)
            activeConversationID = conversationID
        }

        guard let index = model.supportConversationIndex(id: conversationID) else { return }

        composerFocused = false
        draft = ""

        withAnimation(.easeOut(duration: 0.2)) {
            model.supportConversations[index].topic = topic
            model.supportConversations[index].messages.append(
                SupportChatMessage(role: .user, text: text)
            )
            model.supportConversations[index].updatedAt = Date()
        }

        guard !model.supportConversations[index].didAutoReply else { return }

        model.supportConversations[index].didAutoReply = true
        isSending = true
        withAnimation(.easeOut(duration: 0.2)) {
            model.supportConversations[index].messages.append(
                SupportChatMessage(role: .typing)
            )
        }

        let replyText: String
        switch topic {
        case .problem:
            replyText = copy.supportAutoReplyProblem
        case .feedback:
            replyText = copy.supportAutoReplyFeedback
        case .other:
            replyText = copy.supportAutoReplyOther
        }

        Task {
            try? await Task.sleep(nanoseconds: 900_000_000)
            await MainActor.run {
                withAnimation(.easeOut(duration: 0.25)) {
                    model.trimSupportTyping(in: conversationID)
                    if let idx = model.supportConversationIndex(id: conversationID) {
                        model.supportConversations[idx].messages.append(
                            SupportChatMessage(role: .support, text: replyText)
                        )
                        model.supportConversations[idx].updatedAt = Date()
                    }
                }
                isSending = false
            }
        }
    }
}
