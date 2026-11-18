import SwiftUI
import UIKit

// MARK: - Look

enum ShareStoryStyle: String, CaseIterable, Identifiable, Hashable {
    case soft
    case classic
    case sun

    var id: String { rawValue }

    func localizedName(for language: AppLanguage) -> String {
        switch (self, language) {
        case (.classic, .en): return "Classic"
        case (.classic, .ru): return "Классика"
        case (.classic, .hy): return "Դասական"
        case (.soft, .en): return "Soft"
        case (.soft, .ru): return "Мягкий"
        case (.soft, .hy): return "Փափուկ"
        case (.sun, .en): return "Bright"
        case (.sun, .ru): return "Яркий"
        case (.sun, .hy): return "Պայծառ"
        }
    }

    var storiesBackgroundTop: String {
        switch self {
        case .classic: return "#0D1846"
        case .soft: return "#F4F1EA"
        case .sun: return "#E95623"
        }
    }

    var storiesBackgroundBottom: String {
        switch self {
        case .classic: return "#0D1846"
        case .soft: return "#E8E2D6"
        case .sun: return "#C4451A"
        }
    }
}

enum ShareCardKind: String, CaseIterable, Identifiable, Hashable {
    case word
    case progress

    var id: String { rawValue }
}

// MARK: - App-icon logo (blue MiBar on white)

private struct MiBarAppLogo: View {
    var textSize: CGFloat = 18
    var horizontal: CGFloat = 14
    var vertical: CGFloat = 8
    var corner: CGFloat = 10

    var body: some View {
        Text("MiBar")
            .font(MiBarFont.ui(size: textSize, weight: .bold))
            .tracking(textSize * -0.03)
            .foregroundStyle(Color.brandBlue)
            .padding(.horizontal, horizontal)
            .padding(.vertical, vertical)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: corner, style: .continuous))
    }
}

// MARK: - Instagram Stories

enum InstagramStoriesShare {
    private static let storiesURL = URL(string: "instagram-stories://share")!

    static var isAvailable: Bool {
        UIApplication.shared.canOpenURL(storiesURL)
    }

    @MainActor
    static func share(
        word: Word,
        language: AppLanguage,
        style: ShareStoryStyle,
        kind: ShareCardKind,
        wordsCompleted: Int
    ) {
        let card: AnyView
        switch kind {
        case .word:
            card = AnyView(WordStoryShareCard(word: word, language: language, style: style))
        case .progress:
            card = AnyView(WordsProgressShareCard(wordsCompleted: wordsCompleted, language: language, style: style))
        }
        let renderer = ImageRenderer(content: card)
        renderer.scale = 3
        guard let image = renderer.uiImage, let png = image.pngData() else { return }

        if isAvailable {
            openStories(stickerPNG: png, style: style)
        } else {
            presentSystemShare(items: [image])
        }
    }

    private static func openStories(stickerPNG: Data, style: ShareStoryStyle) {
        var payload: [String: Any] = [
            "com.instagram.sharedSticker.stickerImage": stickerPNG,
            "com.instagram.sharedSticker.backgroundTopColor": style.storiesBackgroundTop,
            "com.instagram.sharedSticker.backgroundBottomColor": style.storiesBackgroundBottom,
        ]
        if let appID = Bundle.main.object(forInfoDictionaryKey: "FacebookAppID") as? String,
           !appID.isEmpty {
            payload["com.instagram.sharedSticker.appID"] = appID
        }

        UIPasteboard.general.setItems(
            [payload],
            options: [.expirationDate: Date().addingTimeInterval(60 * 5)]
        )
        UIApplication.shared.open(storiesURL)
    }

    private static func presentSystemShare(items: [Any]) {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let root = scene.keyWindow?.rootViewController
        else { return }

        var presenter = root
        while let presented = presenter.presentedViewController {
            presenter = presented
        }

        let activity = UIActivityViewController(activityItems: items, applicationActivities: nil)
        activity.popoverPresentationController?.sourceView = presenter.view
        activity.popoverPresentationController?.sourceRect = CGRect(
            x: presenter.view.bounds.midX,
            y: presenter.view.bounds.midY,
            width: 1,
            height: 1
        )
        activity.popoverPresentationController?.permittedArrowDirections = []
        presenter.present(activity, animated: true)
    }
}

private extension UIWindowScene {
    var keyWindow: UIWindow? {
        windows.first(where: \.isKeyWindow) ?? windows.first
    }
}

// MARK: - Share page

struct WordSharePage: View {
    var word: Word
    var language: AppLanguage
    var wordsCompleted: Int
    var onClose: () -> Void

    @State private var style: ShareStoryStyle = .soft
    @State private var kind: ShareCardKind = .word

    private var copy: L10n { language.copy }
    private var layout: PhoneLayout { ScreenMetrics.layout }
    private var compact: Bool { layout == .compact }

    private var cardWidth: CGFloat {
        min(layout == .max ? 340 : 320, ScreenMetrics.width - (compact ? 36 : 48))
    }

    private var sectionSpacing: CGFloat { compact ? 10 : 16 }
    private var horizontalPad: CGFloat { compact ? 20 : 28 }

    var body: some View {
        ZStack {
            Color.navy.ignoresSafeArea()

            Circle()
                .fill(Color.white.opacity(0.06))
                .frame(width: compact ? 260 : 320, height: compact ? 260 : 320)
                .blur(radius: 60)
                .offset(x: -100, y: -180)
                .allowsHitTesting(false)

            Circle()
                .fill(Color.orangeBrand.opacity(0.16))
                .frame(width: compact ? 220 : 280, height: compact ? 220 : 280)
                .blur(radius: 70)
                .offset(x: 120, y: 280)
                .allowsHitTesting(false)

            VStack(spacing: 0) {
                header

                GeometryReader { geo in
                    let controlsBudget: CGFloat = compact ? 150 : 180
                    let carouselHeight = min(
                        layout == .max ? 420 : (layout == .plus ? 370 : 318),
                        max(268, geo.size.height - controlsBudget)
                    )

                    VStack(spacing: sectionSpacing) {
                        Text(copy.shareYourWord)
                            .font(MiBarFont.ui(size: compact ? 10 : 11, weight: .medium))
                            .tracking(1.8)
                            .textCase(.uppercase)
                            .foregroundStyle(Color.white.opacity(0.45))
                            .frame(maxWidth: .infinity)
                            .padding(.top, compact ? 4 : 6)

                        cardCarousel(height: carouselHeight)

                        kindDots

                        stylePicker
                            .padding(.horizontal, horizontalPad)

                        Text(copy.shareLookHint)
                            .font(MiBarFont.ui(size: compact ? 12 : 13))
                            .foregroundStyle(Color.white.opacity(0.4))
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .minimumScaleFactor(0.9)
                            .padding(.horizontal, horizontalPad)

                        Spacer(minLength: 0)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                }

                shareButton
            }
        }
    }

    private var header: some View {
        ZStack {
            HStack {
                Button(action: onClose) {
                    HStack(spacing: 2) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .medium))
                        Text(copy.back)
                            .font(MiBarFont.ui(size: 13))
                    }
                    .foregroundStyle(Color.white.opacity(0.55))
                }
                .buttonStyle(.plain)
                .accessibilityLabel(copy.back)

                Spacer()
            }

            MiBarAppLogo(
                textSize: compact ? 15 : 18,
                horizontal: compact ? 12 : 16,
                vertical: compact ? 6 : 8,
                corner: compact ? 10 : 12
            )
        }
        .padding(.horizontal, 20)
        .padding(.top, compact ? 6 : 12)
        .padding(.bottom, compact ? 12 : 14)
    }

    private var shareButton: some View {
        Button {
            InstagramStoriesShare.share(
                word: word,
                language: language,
                style: style,
                kind: kind,
                wordsCompleted: wordsCompleted
            )
        } label: {
            HStack(spacing: 10) {
                Text(copy.shareToInstagram)
                    .font(MiBarFont.ui(size: compact ? 14 : 15, weight: .semibold))
                MiBarIconView(name: .arrow, size: 16)
                    .opacity(0.75)
            }
            .foregroundStyle(Color.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, compact ? 14 : 16)
            .background(Color.orangeBrand)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(MiBarPressStyle())
        .padding(.horizontal, compact ? 20 : 24)
        .padding(.top, compact ? 8 : 10)
        .padding(.bottom, compact ? 12 : 20)
        .accessibilityLabel(copy.shareToInstagram)
    }

    private func cardCarousel(height: CGFloat) -> some View {
        TabView(selection: $kind) {
            WordStoryShareCard(
                word: word,
                language: language,
                style: style,
                cardWidth: cardWidth,
                compact: compact
            )
            .frame(maxWidth: .infinity)
            .tag(ShareCardKind.word)

            WordsProgressShareCard(
                wordsCompleted: wordsCompleted,
                language: language,
                style: style,
                cardWidth: cardWidth,
                compact: compact
            )
            .frame(maxWidth: .infinity)
            .tag(ShareCardKind.progress)
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .frame(height: height)
        .animation(.easeInOut(duration: 0.2), value: style)
    }

    private var kindDots: some View {
        HStack(spacing: 7) {
            ForEach(ShareCardKind.allCases) { option in
                Capsule()
                    .fill(option == kind ? Color.white : Color.white.opacity(0.28))
                    .frame(width: option == kind ? 16 : 6, height: 6)
            }
        }
        .animation(.easeOut(duration: 0.2), value: kind)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(kind == .word ? copy.wordOfTheDay : copy.wordsCompletedTitle)
    }

    private var stylePicker: some View {
        VStack(alignment: .leading, spacing: compact ? 7 : 10) {
            Text(copy.look)
                .font(MiBarFont.ui(size: 10, weight: .bold))
                .tracking(1.4)
                .textCase(.uppercase)
                .foregroundStyle(Color.white.opacity(0.4))

            HStack(spacing: compact ? 6 : 8) {
                ForEach(ShareStoryStyle.allCases) { option in
                    let selected = style == option
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            style = option
                        }
                    } label: {
                        Text(option.localizedName(for: language))
                            .font(MiBarFont.ui(size: compact ? 12 : 13, weight: selected ? .semibold : .medium))
                            .foregroundStyle(selected ? Color.navy : Color.navy.opacity(0.45))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, compact ? 9 : 11)
                            .background {
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(Color.white)
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .stroke(
                                                selected ? Color.navy.opacity(0.22) : Color.clear,
                                                lineWidth: 1.5
                                            )
                                    }
                            }
                    }
                    .buttonStyle(.plain)
                    .accessibilityAddTraits(selected ? .isSelected : [])
                }
            }
        }
    }
}

// MARK: - Shared card chrome

private struct ShareCardChrome<Content: View>: View {
    var style: ShareStoryStyle
    var cardWidth: CGFloat = 340
    var compact: Bool = false
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .padding(.horizontal, compact ? 18 : 26)
            .padding(.top, compact ? 14 : 20)
            .padding(.bottom, compact ? 16 : 24)
            .frame(width: cardWidth)
            .background { cardBackground }
    }

    @ViewBuilder
    private var cardBackground: some View {
        switch style {
        case .classic:
            // Same flat navy as the Home hero — no gradient.
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(Color.navy)
                .overlay {
                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
                }
                .shadow(color: Color.navy.opacity(0.35), radius: 20, y: 10)

        case .soft:
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color.white.opacity(0.98), Color.softPaper, Color(hex: 0xE8E2D6)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay {
                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                        .stroke(Color.white.opacity(0.9), lineWidth: 1.2)
                }
                .shadow(color: Color.black.opacity(0.12), radius: 24, y: 12)

        case .sun:
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: 0xF06A38), Color.orangeBrand, Color(hex: 0xC4451A)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay {
                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                        .stroke(Color.white.opacity(0.28), lineWidth: 1.2)
                }
                .shadow(color: Color.black.opacity(0.12), radius: 24, y: 12)
        }
    }
}

private struct ShareCardPalette {
    var style: ShareStoryStyle

    var kicker: Color {
        switch style {
        case .classic: return .orangeSoft
        case .soft: return .orangeBrand
        case .sun: return .white.opacity(0.85)
        }
    }

    var primary: Color {
        switch style {
        case .classic, .sun: return .white
        case .soft: return .navy
        }
    }

    var meta: Color {
        switch style {
        case .classic: return .translitBlue
        case .soft: return .brandBlue
        case .sun: return .sunMeta
        }
    }

    var secondary: Color {
        switch style {
        case .classic: return Color.white.opacity(0.72)
        case .soft: return .inkSoft
        case .sun: return Color.white.opacity(0.82)
        }
    }

    var divider: Color {
        switch style {
        case .classic: return Color.white.opacity(0.12)
        case .soft: return Color.navy.opacity(0.12)
        case .sun: return Color.white.opacity(0.28)
        }
    }
}

// MARK: - Word sticker

struct WordStoryShareCard: View {
    var word: Word
    var language: AppLanguage
    var style: ShareStoryStyle = .classic
    var cardWidth: CGFloat = 340
    var compact: Bool = false

    private var copy: L10n { language.copy }
    private var palette: ShareCardPalette { ShareCardPalette(style: style) }

    private var wordSize: CGFloat {
        let base: CGFloat
        if word.armenian.count >= 14 { base = 34 }
        else if word.armenian.count >= 10 { base = 40 }
        else if word.armenian.count >= 7 { base = 46 }
        else { base = 52 }
        return compact ? base * 0.88 : base
    }

    var body: some View {
        ShareCardChrome(style: style, cardWidth: cardWidth, compact: compact) {
            VStack(spacing: 0) {
                HStack {
                    MiBarAppLogo(
                        textSize: compact ? 12 : 14,
                        horizontal: compact ? 10 : 12,
                        vertical: compact ? 5 : 6,
                        corner: 8
                    )
                    Spacer(minLength: 0)
                }
                .padding(.bottom, compact ? 12 : 20)

                Text(copy.wordOfTheDay.uppercased())
                    .font(MiBarFont.ui(size: compact ? 10 : 11, weight: .bold))
                    .tracking(1.6)
                    .foregroundStyle(palette.kicker)
                    .padding(.bottom, compact ? 10 : 14)

                AdaptiveArmenianWord(
                    text: word.armenian,
                    size: wordSize,
                    weight: UIFont.Weight.medium,
                    color: palette.primary,
                    minScale: 0.28,
                    alignment: .center
                )
                .padding(.bottom, compact ? 6 : 10)

                Text("[\(word.transliteration)]")
                    .font(MiBarFont.ui(size: compact ? 14 : 16, italic: true, editorial: true))
                    .foregroundStyle(palette.meta)
                    .padding(.bottom, compact ? 5 : 8)

                Text(word.gloss(for: language))
                    .font(MiBarFont.ui(size: compact ? 13 : 15, weight: .medium))
                    .foregroundStyle(palette.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, compact ? 12 : 18)

                Rectangle()
                    .fill(palette.divider)
                    .frame(height: 1)
                    .padding(.bottom, compact ? 10 : 16)

                Text(word.phrase)
                    .font(MiBarFont.ui(size: compact ? 13 : 15, weight: .semibold, editorial: true))
                    .foregroundStyle(palette.primary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
                    .lineLimit(3)
                    .minimumScaleFactor(0.85)
                    .padding(.bottom, compact ? 5 : 8)

                Text(word.phraseTranslation(for: language))
                    .font(MiBarFont.ui(size: compact ? 12 : 13, weight: .medium))
                    .foregroundStyle(palette.secondary.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)
            }
        }
    }
}

// MARK: - Progress sticker

struct WordsProgressShareCard: View {
    var wordsCompleted: Int
    var language: AppLanguage
    var style: ShareStoryStyle = .classic
    var cardWidth: CGFloat = 340
    var compact: Bool = false

    private var copy: L10n { language.copy }
    private var palette: ShareCardPalette { ShareCardPalette(style: style) }

    var body: some View {
        ShareCardChrome(style: style, cardWidth: cardWidth, compact: compact) {
            VStack(spacing: 0) {
                HStack {
                    MiBarAppLogo(
                        textSize: compact ? 12 : 14,
                        horizontal: compact ? 10 : 12,
                        vertical: compact ? 5 : 6,
                        corner: 8
                    )
                    Spacer(minLength: 0)
                }
                .padding(.bottom, compact ? 16 : 28)

                Text(copy.wordsCompletedTitle.uppercased())
                    .font(MiBarFont.ui(size: compact ? 10 : 11, weight: .bold))
                    .tracking(1.6)
                    .foregroundStyle(palette.kicker)
                    .padding(.bottom, compact ? 14 : 22)

                Text("\(wordsCompleted)")
                    .font(MiBarFont.ui(size: compact ? 68 : 88, weight: .bold, editorial: true))
                    .tracking(-2.4)
                    .foregroundStyle(palette.primary)
                    .monospacedDigit()
                    .padding(.bottom, 6)

                Text(copy.wordsCompletedUnit(wordsCompleted))
                    .font(MiBarFont.ui(size: compact ? 17 : 20, weight: .semibold))
                    .foregroundStyle(palette.meta)
                    .padding(.bottom, compact ? 14 : 22)

                Rectangle()
                    .fill(palette.divider)
                    .frame(height: 1)
                    .padding(.bottom, compact ? 12 : 18)

                Text(copy.wordsCompletedFootnote)
                    .font(MiBarFont.ui(size: compact ? 13 : 15, weight: .medium, editorial: true))
                    .foregroundStyle(palette.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .minimumScaleFactor(0.85)
            }
            .frame(minHeight: compact ? 220 : 280, alignment: .top)
        }
    }
}
