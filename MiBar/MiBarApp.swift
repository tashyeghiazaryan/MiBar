import SwiftUI

@main
struct MiBarApp: App {
    @StateObject private var model: AppModel

    init() {
        FontRegistrar.register()
        _model = StateObject(wrappedValue: AppModel.make())
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(model)
        }
    }
}
