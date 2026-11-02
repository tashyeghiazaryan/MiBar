import CoreText
import SwiftUI
import UIKit

extension Color {
    init(hex: UInt32, alpha: Double = 1) {
        let red = Double((hex >> 16) & 0xff) / 255
        let green = Double((hex >> 8) & 0xff) / 255
        let blue = Double(hex & 0xff) / 255
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
    }

    static let navy = Color(hex: 0x0D1846)
    static let brandBlue = Color(hex: 0x406EB7)
    static let orangeBrand = Color(hex: 0xE95623)
    static let orangeSoft = Color(hex: 0xF2A07E)
    static let paper = Color(hex: 0xE3E3E3)
    static let inkSoft = Color(hex: 0x5A5A5A)
    static let danger = Color(hex: 0xC62828)
    static let success = Color(hex: 0x2E7D4F)
    static let muted1 = Color(hex: 0x9A9A9A)
    static let muted2 = Color(hex: 0x7A7A7A)
    static let muted3 = Color(hex: 0x757575)
    static let muted4 = Color(hex: 0x6E6E6E)
    static let muted5 = Color(hex: 0x6A6A6A)
    static let muted6 = Color(hex: 0x727272)
    static let translitBlue = Color(hex: 0x9EC0EF)
    static let softPaper = Color(hex: 0xF4F1EA)
    static let sunMeta = Color(hex: 0xFFE3D4)
    static let line = Color(hex: 0x0D1846, alpha: 0.14)
}

enum FontRegistrar {
    static func register() {
        let existing = Set(UIFont.familyNames)
        let files = [
            ("Outfit", "Outfit"),
            ("NotoSansArmenian", "Noto Sans Armenian"),
            ("NotoSerifArmenian", "Noto Serif Armenian"),
        ]
        for (resource, family) in files where !existing.contains(family) {
            guard let url = Bundle.main.url(forResource: resource, withExtension: "ttf") else { continue }
            CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
        }
    }
}

enum MiBarFont {
    static func ui(size: CGFloat, weight: UIFont.Weight = .regular, italic: Bool = false, editorial: Bool = false) -> Font {
        guard !outfitFamily.isEmpty else {
            let font = Font.system(size: size, weight: swiftWeight(weight))
            return italic ? font.italic() : font
        }
        return Font(makeUIFont(size: size, weight: weight, italic: italic, editorial: editorial))
    }

    private static let outfitFamily = resolve("Outfit")
    private static let sansFamily = resolve("Noto Sans Armenian")
    private static let serifFamily = resolve("Noto Serif Armenian")

    private static func resolve(_ name: String) -> String {
        UIFont.familyNames.first { $0.caseInsensitiveCompare(name) == .orderedSame } ?? ""
    }

    private static func swiftWeight(_ weight: UIFont.Weight) -> Font.Weight {
        if weight >= UIFont.Weight.bold { return .bold }
        if weight >= UIFont.Weight.semibold { return .semibold }
        if weight >= UIFont.Weight.medium { return .medium }
        return .regular
    }

    private static func makeUIFont(size: CGFloat, weight: UIFont.Weight, italic: Bool, editorial: Bool) -> UIFont {
        let traits: [UIFontDescriptor.TraitKey: Any] = [.weight: weight]
        var primary = UIFontDescriptor(fontAttributes: [
            .family: outfitFamily,
            .traits: traits,
        ])
        if italic, let styled = primary.withSymbolicTraits(primary.symbolicTraits.union(.traitItalic)) {
            primary = styled
        }
        let fallbackName = editorial ? serifFamily : sansFamily
        if !fallbackName.isEmpty {
            let fallback = UIFontDescriptor(fontAttributes: [
                .family: fallbackName,
                .traits: traits,
            ])
            primary = primary.addingAttributes([.cascadeList: [fallback]])
        }
        return UIFont(descriptor: primary, size: size)
    }
}

struct Kicker: View {
    var text: String
    var color: Color = .orangeBrand
    var size: CGFloat = 10
    var weight: UIFont.Weight = .bold
    var trackingEm: CGFloat = 0.15

    var body: some View {
        Text(text)
            .font(MiBarFont.ui(size: size, weight: weight))
            .tracking(size * trackingEm)
            .textCase(.uppercase)
            .foregroundStyle(color)
    }
}

enum MiBarIcon: String {
    case arrow = "arrow.right"
    case back = "chevron.left"
    case bookmark = "bookmark"
    case bookmarked = "bookmark.fill"
    case calendar = "calendar"
    case check = "checkmark"
    case close = "xmark"
    case heart = "heart"
    case home = "house"
    case pause = "pause"
    case play = "play.fill"
    case settings = "gearshape"
    case spark = "sparkle"
    case widget = "square.grid.2x2"
    case chevronDown = "chevron.down"
    case share = "square.and.arrow.up"
}

struct MiBarIconView: View {
    var name: MiBarIcon
    var size: CGFloat = 22

    var body: some View {
        Image(systemName: name.rawValue)
            .font(.system(size: size * 0.78, weight: name == .play || name == .bookmarked ? .semibold : .regular))
            .frame(width: size, height: size)
    }
}

struct MiBarPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeOut(duration: 0.16), value: configuration.isPressed)
    }
}

struct Spinner: View {
    var size: CGFloat = 20
    var light = true
    @State private var spinning = false

    var body: some View {
        Circle()
            .stroke(light ? Color.white.opacity(0.3) : Color.navy.opacity(0.2), lineWidth: 2)
            .overlay {
                Circle()
                    .trim(from: 0, to: 0.28)
                    .stroke(light ? Color.white : Color.navy, style: StrokeStyle(lineWidth: 2, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .rotationEffect(.degrees(spinning ? 360 : 0))
            }
            .frame(width: size, height: size)
            .onAppear {
                withAnimation(.linear(duration: 0.7).repeatForever(autoreverses: false)) {
                    spinning = true
                }
            }
    }
}

struct PrimaryButton: View {
    var title: String
    var icon: MiBarIcon? = .arrow
    var isLoading = false
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                if isLoading {
                    Spinner()
                } else {
                    HStack(spacing: 12) {
                        Text(title)
                        Spacer(minLength: 8)
                        if let icon {
                            MiBarIconView(name: icon, size: 22)
                        }
                    }
                    .padding(.horizontal, 22)
                }
            }
            .font(MiBarFont.ui(size: 16, weight: .semibold))
            .foregroundStyle(Color.white)
            .frame(maxWidth: .infinity)
            .frame(height: 58)
            .background(Color.navy)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .opacity(isLoading ? 0.7 : 1)
        }
        .buttonStyle(MiBarPressStyle())
        .disabled(isLoading)
    }
}

struct IconButton: View {
    var icon: MiBarIcon
    var size: CGFloat = 22
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            MiBarIconView(name: icon, size: size)
                .foregroundStyle(Color.black)
                .frame(width: 42, height: 42)
                .contentShape(Circle())
        }
        .buttonStyle(MiBarPressStyle())
        .accessibilityLabel(accessibilityTitle)
    }

    private var accessibilityTitle: String {
        switch icon {
        case .back: return "Back"
        case .settings: return "Settings"
        default: return "Close"
        }
    }
}

struct BrandMark: View {
    var compact = false
    var showMark = true
    var leading = false

    var body: some View {
        if compact {
            HStack(spacing: 9) {
                sun(side: 30, glyph: 14)
                wordmark(20)
            }
        } else {
            VStack(alignment: leading ? .leading : .center, spacing: 4) {
                sun(side: leading ? 48 : 56, glyph: leading ? 20 : 24)
                wordmark(25)
                    .padding(.top, 2)
                Text("մի բառ · one word")
                    .font(MiBarFont.ui(size: 10))
                    .tracking(1)
                    .foregroundStyle(Color.brandBlue)
            }
        }
    }

    @ViewBuilder
    private func sun(side: CGFloat, glyph: CGFloat) -> some View {
        if showMark {
            ZStack {
                Circle().fill(Color.orangeBrand)
                Text("Մ")
                    .font(MiBarFont.ui(size: glyph, editorial: true))
                    .foregroundStyle(Color.white)
            }
            .frame(width: side, height: side)
        }
    }

    private func wordmark(_ size: CGFloat) -> some View {
        Text("MiBar")
            .font(MiBarFont.ui(size: size, weight: .bold, editorial: true))
            .tracking(size * -0.04)
            .foregroundStyle(Color.black)
    }
}

struct ScreenMetrics {
    static var width: CGFloat { UIScreen.main.bounds.width }
    static var height: CGFloat { UIScreen.main.bounds.height }

    /// iPhone 16 / 16 Pro (~852–874); Plus / Pro Max are ≥ 900.
    static var isCompactPhone: Bool { height < 900 }

    static var displayTitle: CGFloat {
        min(55, max(42, width * 0.12))
    }

    static var armenianWord: CGFloat {
        min(88, max(65, width * 0.20))
    }
}
