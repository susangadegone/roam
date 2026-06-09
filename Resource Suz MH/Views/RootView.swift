import SwiftUI

struct RootView: View {
    @AppStorage("hasAccount") private var hasAccount = false
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false

    var body: some View {
        RootTabView()
            .fullScreenCover(isPresented: Binding(
                get: { !hasAccount || !hasSeenOnboarding },
                set: { _ in }
            )) {
                if !hasAccount {
                    AuthView()
                } else {
                    OnboardingView(isShowing: Binding(
                        get: { !hasSeenOnboarding },
                        set: { _ in }
                    ))
                }
            }
    }
}
