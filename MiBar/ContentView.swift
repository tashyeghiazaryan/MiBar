import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        ZStack {
            Color.paper.ignoresSafeArea()
            switch model.screen {
            case .email:
                EmailScreen { email in
                    model.email = email
                    model.screen = .otp
                }
            case .otp:
                OtpScreen(
                    email: model.email,
                    onBack: { model.screen = .email },
                    onSuccess: { model.screen = .language }
                )
            case .language:
                LanguageScreen(value: model.language) { language in
                    model.language = language
                    model.screen = .loading
                }
            case .loading:
                HomeLoadingScreen {
                    model.enterMain()
                }
            case .main:
                MainShell()
            }
        }
        .tint(Color.navy)
        .preferredColorScheme(.light)
    }
}

#Preview {
    ContentView()
        .environmentObject(AppModel.make())
}
