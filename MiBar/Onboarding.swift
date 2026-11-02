import CoreMotion
import SwiftUI

struct FloatLetter: Identifiable {
    let id: String
    let char: String
    let scatterX: CGFloat
    let scatterY: CGFloat
    let targetX: CGFloat
    let targetY: CGFloat
    let size: CGFloat
    let drift: CGFloat
    let isExtra: Bool
}

enum LetterMath {
    static func lerp(_ a: CGFloat, _ b: CGFloat, _ t: CGFloat) -> CGFloat {
        a + (b - a) * t
    }

    static func clamp01(_ value: CGFloat) -> CGFloat {
        min(1, max(0, value))
    }

    static func smoothstep(_ value: CGFloat) -> CGFloat {
        let t = clamp01(value)
        return t * t * (3 - 2 * t)
    }

    static func loadingFormation(_ elapsed: CGFloat) -> CGFloat {
        if elapsed < 220 { return 0 }
        if elapsed < 1100 { return smoothstep((elapsed - 220) / 880) }
        return 1
    }

    static func mod(_ value: Int, _ divisor: Int) -> Int {
        let remainder = value % divisor
        return remainder >= 0 ? remainder : remainder + divisor
    }

    static let constellation: [FloatLetter] = {
        let lines: [(text: String, x: CGFloat, y: CGFloat, spacing: CGFloat, size: CGFloat)] = [
            ("Սեր", 22, 22, 13, 28),
            ("Լույս", 68, 48, 11, 24),
            ("Սիրուն", 38, 78, 10, 22),
        ]
        var letters: [FloatLetter] = []
        for (wordIndex, word) in lines.enumerated() {
            let chars = Array(word.text)
            let startX = word.x - (CGFloat(chars.count - 1) * word.spacing) / 2
            for (index, char) in chars.enumerated() {
                let seed = wordIndex * 17 + index * 13
                letters.append(
                    FloatLetter(
                        id: "\(wordIndex)-\(index)",
                        char: String(char),
                        scatterX: CGFloat(8 + mod(seed * 37, 84)),
                        scatterY: CGFloat(6 + mod(seed * 53, 88)),
                        targetX: startX + CGFloat(index) * word.spacing,
                        targetY: word.y,
                        size: word.size,
                        drift: CGFloat(mod(seed, 7) + 3),
                        isExtra: false
                    )
                )
            }
        }
        return letters
    }()

    static let loading: [FloatLetter] = buildLoad(
        word: "MiBar",
        extras: ["A", "r", "e", "v", "s", "o", "n", "u", "y", "l", "t"],
        size: 42
    )

    /// Center positions of M·i·B·a·r measured from the App Icon (0…100 within the word).
    private static let mibarIconCenters: [CGFloat] = [14.0, 34.52, 51.08, 73.18, 93.49]

    private static func buildLoad(word: String, extras: [String], size: CGFloat) -> [FloatLetter] {
        let chars = Array(word)
        // Compact word span matching the icon proportions on screen.
        let wordSpan: CGFloat = 34
        let wordOrigin = 50 - wordSpan / 2
        let targets = mibarIconCenters.map { wordOrigin + ($0 / 100) * wordSpan }

        var letters: [FloatLetter] = []
        for (order, char) in chars.enumerated() {
            let code = Int(char.unicodeScalars.first?.value ?? 0)
            let seed = order * 19 + code
            letters.append(
                FloatLetter(
                    id: "\(word)-\(order)",
                    char: String(char),
                    scatterX: CGFloat(30 + mod(seed * 41, 40)),
                    scatterY: CGFloat(32 + mod(seed * 67, 36)),
                    targetX: targets[order],
                    targetY: 50,
                    size: size,
                    drift: 0,
                    isExtra: false
                )
            )
        }

        for (order, extra) in extras.enumerated() {
            let char = Array(extra)[0]
            let code = Int(char.unicodeScalars.first?.value ?? 0)
            let seed = order * 23 + code + 11
            letters.append(
                FloatLetter(
                    id: "\(word)-extra-\(order)",
                    char: extra,
                    scatterX: CGFloat(26 + mod(seed * 37, 48)),
                    scatterY: CGFloat(28 + mod(seed * 53, 44)),
                    targetX: CGFloat(22 + mod(seed * 29, 56)),
                    targetY: CGFloat(18 + mod(seed * 31, 14) + (order % 2) * 58),
                    size: (size * 0.7).rounded(),
                    drift: 0,
                    isExtra: true
                )
            )
        }
        return letters
    }
}

final class TiltMonitor: ObservableObject {
    @Published var tilt: CGSize = .zero
    private let motion = CMMotionManager()

    func start() {
        guard motion.isDeviceMotionAvailable, !motion.isDeviceMotionActive else { return }
        motion.deviceMotionUpdateInterval = 1.0 / 30.0
        motion.startDeviceMotionUpdates(using: .xArbitraryZVertical, to: .main) { [weak self] data, _ in
            guard let attitude = data?.attitude else { return }
            let roll = attitude.roll * 180 / .pi
            let pitch = attitude.pitch * 180 / .pi
            self?.tilt = CGSize(
                width: min(1, max(-1, roll / 28)),
                height: min(1, max(-1, pitch / 40))
            )
        }
    }

    func stop() {
        motion.stopDeviceMotionUpdates()
    }
}

struct LetterConstellation: View {
    @StateObject private var monitor = TiltMonitor()
    @State private var pointer: CGSize?

    var body: some View {
        GeometryReader { geo in
            TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { timeline in
                let tick = timeline.date.timeIntervalSinceReferenceDate * 1000
                let tilt = pointer ?? monitor.tilt
                let formation = min(1, abs(tilt.width) * 1.35)
                let ease = formation * formation * (3 - 2 * formation)
                ZStack {
                    ForEach(LetterMath.constellation) { letter in
                        constellationLetter(letter, ease: ease, tilt: tilt, tick: tick, size: geo.size)
                    }
                    Text(ease > 0.55 ? "սեր · լույս · սիրուն" : "tilt to form words")
                        .font(MiBarFont.ui(size: 8, weight: .semibold))
                        .tracking(0.96)
                        .textCase(.uppercase)
                        .foregroundStyle(Color.muted3.opacity(0.7))
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                        .padding(.bottom, 4)
                }
            }
            .contentShape(Rectangle())
            .highPriorityGesture(
                DragGesture(minimumDistance: 4)
                    .onChanged { value in
                        let x = (value.location.x / max(geo.size.width, 1)) * 2 - 1
                        let y = (value.location.y / max(geo.size.height, 1)) * 2 - 1
                        pointer = CGSize(
                            width: min(1, max(-1, x)),
                            height: min(1, max(-1, y))
                        )
                    }
                    .onEnded { _ in
                        pointer = nil
                    }
            )
        }
        .onAppear { monitor.start() }
        .onDisappear { monitor.stop() }
        .accessibilityHidden(true)
    }

    private func constellationLetter(_ letter: FloatLetter, ease: CGFloat, tilt: CGSize, tick: Double, size: CGSize) -> some View {
        let remain = CGFloat(1) - ease
        let wave = CGFloat(sin(tick / 700 + Double(letter.drift))) * remain * 4
        let x = LetterMath.lerp(letter.scatterX, letter.targetX, ease) + tilt.width * letter.drift * (CGFloat(1) - ease * 0.4)
        let y = LetterMath.lerp(letter.scatterY, letter.targetY, ease) + tilt.height * (letter.drift * 0.6) + wave
        let spin = remain * (letter.drift - 5) * 4
        return styledLetter(letter.char, size: letter.size, weight: .semibold)
            .opacity(0.28 + Double(ease) * 0.62)
            .rotationEffect(.degrees(Double(spin)))
            .shadow(color: ease > 0.7 ? Color.white.opacity(0.35) : .clear, radius: 0, y: 1)
            .position(x: size.width * x / 100, y: size.height * y / 100)
    }
}

struct HomeLoadingScreen: View {
    var onDone: () -> Void
    @State private var start: Date?
    @State private var didSchedule = false

    var body: some View {
        GeometryReader { geo in
            TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { timeline in
                let elapsed = CGFloat(start.map { timeline.date.timeIntervalSince($0) * 1000 } ?? 0)
                let formation = LetterMath.loadingFormation(elapsed)
                ZStack {
                    ForEach(Array(LetterMath.loading.enumerated()), id: \.element.id) { index, letter in
                        loadingLetter(letter, index: index, elapsed: elapsed, formation: formation, size: geo.size)
                    }
                }
                .opacity(exitOpacity(elapsed))
                .frame(width: geo.size.width, height: geo.size.height)
            }
        }
        .background(Color.white.ignoresSafeArea())
        .onAppear {
            guard !didSchedule else { return }
            didSchedule = true
            start = Date()
            Task {
                try? await Task.sleep(nanoseconds: 2_400_000_000)
                onDone()
            }
        }
        .accessibilityLabel("Loading MiBar")
    }

    private func exitOpacity(_ elapsed: CGFloat) -> Double {
        guard elapsed >= 1750 else { return 1 }
        return Double(1 - LetterMath.smoothstep((elapsed - 1750) / 650))
    }

    private func loadingLetter(_ letter: FloatLetter, index: Int, elapsed: CGFloat, formation: CGFloat, size: CGSize) -> some View {
        let gather = letter.isExtra ? formation * 0.15 : formation
        let wave = CGFloat(sin(Double(elapsed) / 420 + Double(index))) * (1 - formation) * 4
        let x = LetterMath.lerp(letter.scatterX, letter.targetX, gather)
        let y = LetterMath.lerp(letter.scatterY, letter.targetY, gather) + wave
        let opacity = letter.isExtra
            ? max(0, 0.4 * (1 - formation * 1.15))
            : 0.4 + formation * 0.6
        let angle: Double = (1 - gather) * (index % 2 == 0 ? -14 : 14)
        // Outfit Bold like the app icon — no editorial cascade.
        return Text(letter.char)
            .font(MiBarFont.ui(size: letter.size, weight: .bold))
            .foregroundStyle(Color.brandBlue)
            .opacity(opacity)
            .rotationEffect(.degrees(angle))
            .position(x: size.width * x / 100, y: size.height * y / 100)
    }
}

private func styledLetter(
    _ text: String,
    size: CGFloat,
    weight: UIFont.Weight,
    editorial: Bool = false
) -> Text {
    Text(text)
        .font(MiBarFont.ui(size: size, weight: weight, editorial: editorial))
        .foregroundStyle(Color.brandBlue)
}

struct EmailScreen: View {
    var onContinue: (String) -> Void
    @State private var email = ""
    @State private var touched = false
    @State private var isLoading = false
    @State private var keyboardHeight: CGFloat = 0
    @FocusState private var focused: Bool

    private var isValid: Bool {
        email == "1111" || email.range(
            of: #"^[^\s@]+@[^\s@]+\.[^\s@]+$"#,
            options: .regularExpression
        ) != nil
    }

    private var isKeyboardVisible: Bool { keyboardHeight > 0 }
    /// Current spacing tuned for 16 Plus / Pro Max; compact = 16 / 16 Pro.
    private var isCompact: Bool { ScreenMetrics.isCompactPhone }

    private var constellationHeight: CGFloat {
        if isKeyboardVisible {
            return isCompact ? 88 : 140
        }
        return isCompact ? 165 : 180
    }

    private var constellationTop: CGFloat {
        if isKeyboardVisible { return isCompact ? 8 : 12 }
        return isCompact ? 16 : 18
    }

    private var constellationBottom: CGFloat {
        if isKeyboardVisible { return isCompact ? 8 : 14 }
        return 8
    }

    private var formBlockTop: CGFloat {
        guard !isKeyboardVisible else { return 0 }
        return isCompact ? 58 : 72
    }

    private var subtitleTop: CGFloat {
        if isKeyboardVisible { return isCompact ? 12 : 14 }
        return isCompact ? 16 : 18
    }

    private var emailFieldTop: CGFloat {
        if isKeyboardVisible { return isCompact ? 18 : 24 }
        return isCompact ? 32 : 36
    }

    private var contentTop: CGFloat {
        if isKeyboardVisible { return isCompact ? 6 : 8 }
        return isCompact ? 24 : 28
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // 3) Logo at the top (scrolls away when keyboard opens)
                    BrandMark(showMark: false, leading: true)

                    // Compact phones: shrink constellation with keyboard so Continue stays clear
                    LetterConstellation()
                        .frame(height: constellationHeight)
                        .padding(.top, constellationTop)
                        .padding(.bottom, constellationBottom)

                    // Idle: push title → Continue lower on large phones; keyboard: device-tuned stack
                    VStack(alignment: .leading, spacing: 0) {
                        // 4) New title + blue subtitle
                        Text("One Armenian word\nevery day.")
                            .font(MiBarFont.ui(size: isCompact && isKeyboardVisible ? 28 : 32, editorial: true))
                            .tracking(-1.0)
                            .lineSpacing(-2)
                            .foregroundStyle(Color.black)

                        Text("Discover Armenian in the app or right from your Home Screen widget.")
                            .font(MiBarFont.ui(size: 14))
                            .foregroundStyle(Color.brandBlue)
                            .lineSpacing(5)
                            .padding(.top, subtitleTop)
                            .fixedSize(horizontal: false, vertical: true)

                        // Field + Continue stay in one stack — no overlap
                        emailField
                            .padding(.top, emailFieldTop)

                        continueButton
                            .padding(.top, 13)
                            .id("continueButton")

                        if !isKeyboardVisible {
                            Text("Use 1111 for prototype access, or continue with your email.")
                                .font(MiBarFont.ui(size: 9))
                                .foregroundStyle(Color.muted2)
                                .multilineTextAlignment(.center)
                                .lineSpacing(2)
                                .frame(maxWidth: 290)
                                .frame(maxWidth: .infinity)
                                .padding(.top, 14)
                        }
                    }
                    .padding(.top, formBlockTop)
                }
                .padding(.horizontal, 30)
                .padding(.top, contentTop)
                .padding(.bottom, 26)
                .frame(maxWidth: .infinity)
            }
            .scrollDismissesKeyboard(.interactively)
            .scrollIndicators(.hidden)
            .onChange(of: keyboardHeight) { _, height in
                guard height > 0 else { return }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    withAnimation(.easeOut(duration: 0.28)) {
                        proxy.scrollTo("continueButton", anchor: .bottom)
                    }
                }
            }
        }
        .background(Color.paper.ignoresSafeArea())
        .padding(.bottom, keyboardHeight)
        .ignoresSafeArea(.keyboard)
        .animation(.easeOut(duration: 0.25), value: keyboardHeight)
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillChangeFrameNotification)) { note in
            guard let frame = note.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
            let screenHeight = UIScreen.main.bounds.height
            keyboardHeight = frame.origin.y >= screenHeight - 1
                ? 0
                : max(0, screenHeight - frame.origin.y)
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            keyboardHeight = 0
        }
    }

    private var emailField: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Your email")
                .font(MiBarFont.ui(size: 11, weight: .semibold))
                .foregroundStyle(Color.black)
                .padding(.bottom, 8)

            ZStack(alignment: .leading) {
                if email.isEmpty {
                    Text("name@example.com")
                        .font(MiBarFont.ui(size: 16))
                        .foregroundStyle(Color.black)
                        .padding(.horizontal, 16)
                        .allowsHitTesting(false)
                }
                TextField("", text: $email)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .autocorrectionDisabled()
                    .submitLabel(.done)
                    .focused($focused)
                    .font(MiBarFont.ui(size: 16))
                    .foregroundStyle(Color.black)
                    .tint(Color.navy)
                    .padding(.horizontal, 16)
            }
            .frame(height: 56)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(borderColor, lineWidth: 1.5)
            }
            .contentShape(Rectangle())
            .onTapGesture { focused = true }
            .onSubmit { focused = false }

            if touched && !isValid {
                Text("Enter a valid email address or 1111")
                    .font(MiBarFont.ui(size: 11))
                    .foregroundStyle(Color.danger)
                    .padding(.top, 6)
                    .padding(.horizontal, 2)
            }
        }
    }

    private var continueButton: some View {
        PrimaryButton(title: "Continue", isLoading: isLoading) {
            focused = false
            submit()
        }
    }

    private var borderColor: Color {
        if touched && !isValid { return .danger }
        if focused { return Color.black.opacity(0.4) }
        return Color.black.opacity(0.18)
    }

    private func submit() {
        touched = true
        guard isValid, !isLoading else { return }
        isLoading = true
        let value = email
        Task {
            try? await Task.sleep(nanoseconds: 650_000_000)
            onContinue(value)
        }
    }
}

struct OtpScreen: View {
    var email: String
    var onBack: () -> Void
    var onSuccess: () -> Void

    @State private var code = ""
    @State private var status: Status = .idle
    @State private var resent = false
    @State private var shakeToken: CGFloat = 0
    @State private var verifyTicket = UUID()
    @FocusState private var focused: Bool

    private enum Status { case idle, loading, error, success }

    private var inboxLabel: String {
        email == "1111" ? "your prototype inbox" : email
    }

    private var digits: [String] {
        let chars = Array(code)
        return (0..<4).map { index in
            index < chars.count ? String(chars[index]) : ""
        }
    }

    private var activeIndex: Int {
        min(code.count, 3)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                HStack {
                    IconButton(icon: .back) {
                        focused = false
                        onBack()
                    }
                    Spacer()
                    BrandMark(compact: true, showMark: false)
                    Spacer()
                    Color.clear.frame(width: 42, height: 42)
                }
                .padding(.top, 4)

                VStack(spacing: 0) {
                    Kicker(text: "Almost there", color: .brandBlue)
                    Text("Check your inbox")
                        .font(MiBarFont.ui(size: 37, editorial: true))
                        .tracking(-1.48)
                        .foregroundStyle(Color.black)
                        .padding(.top, 9)
                    (
                        Text("We sent a four-digit code to\n")
                        + Text(inboxLabel).fontWeight(.semibold)
                    )
                    .font(MiBarFont.ui(size: 14))
                    .foregroundStyle(Color.inkSoft)
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
                    .padding(.top, 18)

                    Button(action: onBack) {
                        Text("Change email")
                            .font(MiBarFont.ui(size: 11, weight: .semibold))
                            .foregroundStyle(Color.brandBlue)
                    }
                    .buttonStyle(MiBarPressStyle())
                    .padding(.top, 9)

                    otpField
                        .padding(.top, 42)
                        .modifier(ShakeEffect(shakes: shakeToken))

                    statusView
                        .frame(minHeight: 40)
                        .padding(.top, 15)

                    Button(action: resend) {
                        Text(resent ? "New code sent" : "Send code again")
                            .font(MiBarFont.ui(size: 11, weight: .semibold))
                            .foregroundStyle(Color.brandBlue)
                            .opacity(resent ? 0.7 : 1)
                    }
                    .buttonStyle(MiBarPressStyle())
                    .disabled(resent)
                    .padding(.top, 8)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 64)
            }
            .padding(.horizontal, 25)
            .padding(.bottom, 28)
        }
        .scrollBounceBehavior(.basedOnSize)
        .scrollDismissesKeyboard(.interactively)
        .background(Color.paper.ignoresSafeArea())
        .animation(.easeInOut(duration: 0.22), value: focused)
    }

    private var otpField: some View {
        ZStack {
            TextField("", text: $code)
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .focused($focused)
                .tint(.clear)
                .foregroundStyle(.clear)
                .accentColor(.clear)
                .frame(maxWidth: .infinity)
                .frame(height: 57)
                .opacity(0.02)

            HStack(spacing: 7) {
                ForEach(0..<4, id: \.self) { index in
                    digitSlot(index)
                }
            }
            .allowsHitTesting(false)
        }
        .frame(height: 57)
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.25)) {
                focused = true
            }
        }
        .onChange(of: code) { _, next in
            apply(next)
        }
        .accessibilityLabel("One-time code")
    }

    private func digitSlot(_ index: Int) -> some View {
        let filled = !digits[index].isEmpty
        let active = focused && index == activeIndex && status != .success
        return Text(digits[index])
            .font(MiBarFont.ui(size: 27, editorial: true))
            .foregroundStyle(digitColor)
            .frame(maxWidth: .infinity)
            .frame(height: 57)
            .overlay(alignment: .bottom) {
                Rectangle()
                    .fill(lineColor(active: active, filled: filled))
                    .frame(height: 2)
                    .animation(.easeInOut(duration: 0.2), value: active)
            }
    }

    private var statusView: some View {
        Group {
            switch status {
            case .loading:
                HStack(spacing: 7) {
                    Spinner(size: 15, light: false)
                    Text("Checking code…")
                }
                .foregroundStyle(Color.navy)
            case .error:
                Text("That code didn’t work. Try again.")
                    .foregroundStyle(Color.danger)
            case .success:
                HStack(spacing: 5) {
                    MiBarIconView(name: .check, size: 18)
                    Text("All set! Opening MiBar…")
                }
                .foregroundStyle(Color.success)
            case .idle:
                HStack(spacing: 4) {
                    Text("Prototype code:")
                    Text("1111").fontWeight(.bold)
                }
                .foregroundStyle(Color.muted3)
            }
        }
        .font(MiBarFont.ui(size: 11))
    }

    private var digitColor: Color {
        switch status {
        case .error: return .danger
        case .success: return .success
        default: return .brandBlue
        }
    }

    private func lineColor(active: Bool, filled: Bool) -> Color {
        switch status {
        case .error: return .danger
        case .success: return .success
        default:
            if active { return Color.brandBlue }
            if filled { return Color.brandBlue.opacity(0.55) }
            return Color.brandBlue.opacity(0.35)
        }
    }

    private func apply(_ raw: String) {
        guard status != .success, status != .loading else { return }
        if status == .error { status = .idle }
        let filtered = String(raw.filter(\.isNumber).prefix(4))
        if filtered != code {
            code = filtered
            return
        }
        if filtered.count == 4 {
            verify(filtered)
        }
    }

    private func verify(_ value: String) {
        let ticket = UUID()
        verifyTicket = ticket
        status = .loading
        focused = false
        Task {
            try? await Task.sleep(nanoseconds: 700_000_000)
            guard verifyTicket == ticket else { return }
            if value == "1111" {
                status = .success
                try? await Task.sleep(nanoseconds: 700_000_000)
                guard verifyTicket == ticket else { return }
                onSuccess()
            } else {
                status = .error
                withAnimation(.linear(duration: 0.28)) {
                    shakeToken += 1
                }
                focused = true
            }
        }
    }

    private func resend() {
        code = ""
        status = .idle
        resent = true
        verifyTicket = UUID()
        withAnimation(.easeInOut(duration: 0.25)) {
            focused = true
        }
        Task {
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            resent = false
        }
    }
}

struct ShakeEffect: GeometryEffect {
    var shakes: CGFloat

    var animatableData: CGFloat {
        get { shakes }
        set { shakes = newValue }
    }

    func effectValue(size: CGSize) -> ProjectionTransform {
        let translation = 3 * sin(Double(shakes) * Double.pi * 2)
        return ProjectionTransform(CGAffineTransform(translationX: translation, y: 0))
    }
}

struct LanguageScreen: View {
    var value: AppLanguage
    var onContinue: (AppLanguage) -> Void
    @State private var selected: AppLanguage

    init(value: AppLanguage, onContinue: @escaping (AppLanguage) -> Void) {
        self.value = value
        self.onContinue = onContinue
        _selected = State(initialValue: value)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            BrandMark(showMark: false, leading: true)
            VStack(alignment: .leading, spacing: 0) {
                Kicker(text: "Welcome")
                Text("Choose your\nlanguage")
                    .font(MiBarFont.ui(size: ScreenMetrics.displayTitle, editorial: true))
                    .tracking(ScreenMetrics.displayTitle * -0.055)
                    .lineSpacing(-4)
                    .foregroundStyle(Color.black)
                    .padding(.top, 12)
                Text("Pick the language for menus, buttons, and everyday guidance. You can change it later.")
                    .font(MiBarFont.ui(size: 14))
                    .foregroundStyle(Color.inkSoft)
                    .lineSpacing(6)
                    .padding(.top, 18)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.top, 42)

            VStack(spacing: 10) {
                ForEach(AppLanguage.allCases) { language in
                    languageRow(language)
                }
            }
            .padding(.top, 34)

            Spacer(minLength: 28)
            PrimaryButton(title: "Continue") {
                onContinue(selected)
            }
        }
        .padding(.horizontal, 30)
        .padding(.top, 12)
        .padding(.bottom, 26)
        .frame(maxWidth: .infinity, minHeight: UIScreen.main.bounds.height - 80, alignment: .top)
        .background(Color.paper)
        .background(Color.paper.ignoresSafeArea())
    }

    private func languageRow(_ language: AppLanguage) -> some View {
        let active = selected == language
        return Button {
            selected = language
        } label: {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(language.native)
                        .font(MiBarFont.ui(size: 22, weight: .semibold, editorial: true))
                        .foregroundStyle(Color.black)
                    Text(language.sample)
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
                        MiBarIconView(name: .check, size: 18)
                            .foregroundStyle(Color.white)
                    }
                }
                .frame(width: 28, height: 28)
            }
            .padding(.leading, 18)
            .padding(.trailing, 16)
            .frame(maxWidth: .infinity, minHeight: 76, alignment: .leading)
            .background(active ? Color.navy.opacity(0.04) : Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(active ? Color.navy : Color.black.opacity(0.12), lineWidth: 1.5)
            }
        }
        .buttonStyle(MiBarPressStyle())
        .accessibilityAddTraits(active ? .isSelected : [])
    }
}
