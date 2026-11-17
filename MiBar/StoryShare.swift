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

    var body: some View {
        ZStack {
            Color.navy.ignoresSafeArea()

            Circle()
                .fill(Color.white.opacity(0.06))
                .frame(width: 320, height: 320)
                .blur(radius: 60)
                .offset(x: -100, y: -180)
                .allowsHitTesting(false)

            Circle()
                .fill(Color.orangeBrand.opacity(0.16))
                .frame(width: 280, height: 280)
                .blur(radius: 70)
                .offset(x: 120, y: 280)
                .allowsHitTesting(false)

            VStack(spacing: 0) {
                header

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 18) {
                        Text(copy.shareYourWord)
                            .font(MiBarFont.ui(size: 11, weight: .medium))
                            .tracking(1.8)
                            .textCase(.uppercase)
                            .foregroundStyle(Color.white.opacity(0.45))
                            .frame(maxWidth: .infinity)
                            .padding(.top, 8)

                        cardCarousel
                            .padding(.top, 4)

                        kindDots

                        stylePicker
                            .padding(.horizontal, 28)
                            .padding(.top, 6)

                        Text(copy.shareLookHint)
                            .font(MiBarFont.ui(size: 13))
                            .foregroundStyle(Color.white.opacity(0.4))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                    .padding(.bottom, 24)
                }

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
                            .font(MiBarFont.ui(size: 15, weight: .semibold))
                        MiBarIconView(name: .arrow, size: 16)
                            .opacity(0.75)
                    }
                    .foregroundStyle(Color.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.orangeBrand)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                .buttonStyle(MiBarPressStyle())
                .padding(.horizontal, 24)
                .padding(.bottom, 36)
                .accessibilityLabel(copy.shareToInstagram)
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

            MiBarAppLogo(textSize: 18, horizontal: 16, vertical: 8, corner: 12)
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 8)
    }

    private var cardCarousel: some View {
        TabView(selection: $kind) {
            WordStoryShareCard(word: word, language: language, style: style)
                .frame(maxWidth: .infinity)
                .tag(ShareCardKind.word)

            WordsProgressShareCard(wordsCompleted: wordsCompleted, language: language, style: style)
                .frame(maxWidth: .infinity)
                .tag(ShareCardKind.progress)
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .frame(height: 420)
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
        VStack(alignment: .leading, spacing: 10) {
            Text(copy.look)
                .font(MiBarFont.ui(size: 10, weight: .bold))
                .tracking(1.4)
                .textCase(.uppercase)
                .foregroundStyle(Color.white.opacity(0.4))

            HStack(spacing: 8) {
                ForEach(ShareStoryStyle.allCases) { option in
                    let selected = style == option
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            style = option
                        }
                    } label: {
                        Text(option.localizedName(for: language))
                            .font(MiBarFont.ui(size: 13, weight: selected ? .semibold : .medium))
                            .foregroundStyle(selected ? Color.navy : Color.navy.opacity(0.45))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 11)
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
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .padding(.horizontal, 26)
            .padding(.top, 20)
            .padding(.bottom, 24)
            .frame(width: 340)
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

    private var copy: L10n { language.copy }
    private var palette: ShareCardPalette { ShareCardPalette(style: style) }

    private var wordSize: CGFloat {
        if word.armenian.count >= 14 { return 34 }
        if word.armenian.count >= 10 { return 40 }
        if word.armenian.count >= 7 { return 46 }
        return 52
    }

    var body: some View {
        ShareCardChrome(style: style) {
            VStack(spacing: 0) {
                HStack {
                    MiBarAppLogo(textSize: 14, horizontal: 12, vertical: 6, corner: 8)
                    Spacer(minLength: 0)
                }
                .padding(.bottom, 20)

                Text(copy.wordOfTheDay.uppercased())
                    .font(MiBarFont.ui(size: 11, weight: .bold))
                    .tracking(1.6)
                    .foregroundStyle(palette.kicker)
                    .padding(.bottom, 14)

                AdaptiveArmenianWord(
                    text: word.armenian,
                    size: wordSize,
                    weight: UIFont.Weight.medium,
                    color: palette.primary,
                    minScale: 0.28,
                    alignment: .center
                )
                .padding(.bottom, 10)

                Text("[\(word.transliteration)]")
                    .font(MiBarFont.ui(size: 16, italic: true, editorial: true))
                    .foregroundStyle(palette.meta)
                    .padding(.bottom, 8)

                Text(word.gloss(for: language))
                    .font(MiBarFont.ui(size: 15, weight: .medium))
                    .foregroundStyle(palette.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 18)

                Rectangle()
                    .fill(palette.divider)
                    .frame(height: 1)
                    .padding(.bottom, 16)

                Text(word.phrase)
                    .font(MiBarFont.ui(size: 15, weight: .semibold, editorial: true))
                    .foregroundStyle(palette.primary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.bottom, 8)

                Text(word.phraseTranslation(for: language))
                    .font(MiBarFont.ui(size: 13, weight: .medium))
                    .foregroundStyle(palette.secondary.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

// MARK: - Progress sticker

struct WordsProgressShareCard: View {
    var wordsCompleted: Int
    var language: AppLanguage
    var style: ShareStoryStyle = .classic

    private var copy: L10n { language.copy }
    private var palette: ShareCardPalette { ShareCardPalette(style: style) }

    var body: some View {
        ShareCardChrome(style: style) {
            VStack(spacing: 0) {
                HStack {
                    MiBarAppLogo(textSize: 14, horizontal: 12, vertical: 6, corner: 8)
                    Spacer(minLength: 0)
                }
                .padding(.bottom, 28)

                Text(copy.wordsCompletedTitle.uppercased())
                    .font(MiBarFont.ui(size: 11, weight: .bold))
                    .tracking(1.6)
                    .foregroundStyle(palette.kicker)
                    .padding(.bottom, 22)

                Text("\(wordsCompleted)")
                    .font(MiBarFont.ui(size: 88, weight: .bold, editorial: true))
                    .tracking(-2.4)
                    .foregroundStyle(palette.primary)
                    .monospacedDigit()
                    .padding(.bottom, 6)

                Text(copy.wordsCompletedUnit(wordsCompleted))
                    .font(MiBarFont.ui(size: 20, weight: .semibold))
                    .foregroundStyle(palette.meta)
                    .padding(.bottom, 22)

                Rectangle()
                    .fill(palette.divider)
                    .frame(height: 1)
                    .padding(.bottom, 18)

                Text(copy.wordsCompletedFootnote)
                    .font(MiBarFont.ui(size: 15, weight: .medium, editorial: true))
                    .foregroundStyle(palette.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(minHeight: 280, alignment: .top)
        }
    }
}
