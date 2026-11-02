import SwiftUI
import UIKit

enum StoryShare {
    @MainActor
    static func shareWord(_ word: Word, language: AppLanguage) {
        var items: [Any] = [shareText(for: word, language: language)]
        if let image = renderStoryImage(word: word, language: language) {
            items.insert(image, at: 0)
        }
        presentActivity(items: items)
    }

    private static func shareText(for word: Word, language: AppLanguage) -> String {
        let copy = language.copy
        return "\(copy.wordOfTheDay): \(word.armenian) [\(word.transliteration)] — \(word.english) · \(word.russian)"
    }

    @MainActor
    private static func renderStoryImage(word: Word, language: AppLanguage) -> UIImage? {
        let card = StoryShareCard(word: word, language: language)
            .frame(width: 1080, height: 1920)
        let renderer = ImageRenderer(content: card)
        renderer.scale = 1
        return renderer.uiImage
    }

    private static func presentActivity(items: [Any]) {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let root = scene.keyWindow?.rootViewController
        else { return }

        var presenter = root
        while let presented = presenter.presentedViewController {
            presenter = presented
        }

        let activity = UIActivityViewController(activityItems: items, applicationActivities: nil)
        activity.popoverPresentationController?.sourceView = presenter.view
        presenter.present(activity, animated: true)
    }
}

private extension UIWindowScene {
    var keyWindow: UIWindow? {
        windows.first(where: \.isKeyWindow) ?? windows.first
    }
}

private struct StoryShareCard: View {
    var word: Word
    var language: AppLanguage

    private var copy: L10n { language.copy }

    var body: some View {
        ZStack {
            Color.navy

            VStack(spacing: 0) {
                Text("MiBar")
                    .font(MiBarFont.ui(size: 42, weight: .semibold, editorial: true))
                    .foregroundStyle(Color.white)
                    .padding(.top, 160)

                Text(copy.wordOfTheDay.uppercased())
                    .font(MiBarFont.ui(size: 28, weight: .semibold))
                    .tracking(4)
                    .foregroundStyle(Color.orangeSoft)
                    .padding(.top, 48)

                Spacer(minLength: 40)

                Text(word.armenian)
                    .font(MiBarFont.ui(size: 140, weight: .medium, editorial: true))
                    .foregroundStyle(Color.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .padding(.horizontal, 80)

                Text("[\(word.transliteration)]")
                    .font(MiBarFont.ui(size: 44, italic: true, editorial: true))
                    .foregroundStyle(Color.translitBlue)
                    .padding(.top, 28)

                HStack(spacing: 18) {
                    Text(word.english)
                    Text("·").foregroundStyle(Color.orangeBrand)
                    Text(word.russian)
                }
                .font(MiBarFont.ui(size: 40, weight: .medium))
                .foregroundStyle(Color.white.opacity(0.85))
                .padding(.top, 24)
                .padding(.horizontal, 60)

                Spacer(minLength: 40)

                Text(word.phrase)
                    .font(MiBarFont.ui(size: 36, weight: .semibold, editorial: true))
                    .foregroundStyle(Color.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 90)

                Text(language == .ru ? word.phraseRussian : word.phraseEnglish)
                    .font(MiBarFont.ui(size: 28, weight: .medium))
                    .foregroundStyle(Color.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.top, 16)
                    .padding(.horizontal, 90)
                    .padding(.bottom, 180)
            }
        }
    }
}
