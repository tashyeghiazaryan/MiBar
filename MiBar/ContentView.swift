import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        ZStack {
            Color.paper.ignoresSafeArea()
            switch model.screen {
            case .welcome:
                WelcomeScreen(
                    onSignUp: {
                        model.isReturningUser = false
                        model.screen = .email
                    },
                    onLogIn: {
                        model.isReturningUser = true
                        model.screen = .login
                    }
                )
            case .email:
                EmailScreen(
                    onContinue: { email in
                        model.email = email
                        model.isReturningUser = false
                        model.screen = .otp
                    },
                    onHaveAccount: {
                        model.isReturningUser = true
                        model.screen = .login
                    },
                    onBack: {
                        model.isReturningUser = false
                        model.screen = .welcome
                    }
                )
            case .login:
                LoginScreen(
                    onContinue: { email in
                        model.email = email
                        model.isReturningUser = true
                        model.screen = .otp
                    },
                    onCreateAccount: {
                        model.isReturningUser = false
                        model.screen = .email
                    },
                    onBack: {
                        model.isReturningUser = false
                        model.screen = .welcome
                    }
                )
            case .otp:
                OtpScreen(
                    email: model.email,
                    onBack: {
                        model.screen = model.isReturningUser ? .login : .email
                    },
                    onSuccess: {
                        model.screen = model.isReturningUser ? .loading : .language
                    }
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
