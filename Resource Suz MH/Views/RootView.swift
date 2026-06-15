import SwiftUI

struct RootView: View {
    @AppStorage("hasAccount") private var hasAccount = false
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false

    @State private var showMoodCheckIn = true
    @State private var showRecheckPrompt = false

    private static let recheckInterval: Duration = .seconds(30 * 60)

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
            .fullScreenCover(isPresented: Binding(
                get: { showMoodCheckIn && hasAccount && hasSeenOnboarding },
                set: { showMoodCheckIn = $0 }
            )) {
                MoodCheckInView(isShowing: $showMoodCheckIn)
            }
            .overlay(alignment: .bottom) {
                if showRecheckPrompt {
                    MoodRecheckBanner(
                        onCheckIn: {
                            showRecheckPrompt = false
                            showMoodCheckIn = true
                        },
                        onDismiss: { showRecheckPrompt = false }
                    )
                    .padding(.horizontal, 16)
                    .padding(.bottom, 90)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .animation(.spring(duration: 0.35), value: showRecheckPrompt)
            .task {
                try? await Task.sleep(for: Self.recheckInterval)
                if !showMoodCheckIn {
                    showRecheckPrompt = true
                }
            }
    }
}

/// Gentle nature-themed prompt offering a fresh mood check-in after extended use.
private struct MoodRecheckBanner: View {
    var onCheckIn: () -> Void
    var onDismiss: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "leaf.fill")
                .font(.system(size: 18))
                .foregroundStyle(Theme.sage)

            VStack(alignment: .leading, spacing: 2) {
                Text("Still feeling the same?")
                    .font(.sans(14, weight: .semibold))
                    .foregroundStyle(Theme.cocoa)
                Text("Take a moment to check back in.")
                    .font(.sans(12))
                    .foregroundStyle(Theme.cocoaMuted)
            }

            Spacer()

            Button("Check in", action: onCheckIn)
                .font(.sans(13, weight: .semibold))
                .foregroundStyle(Theme.cream)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(Capsule().fill(Theme.terracotta))

            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Theme.cocoaMuted)
                    .padding(6)
            }
        }
        .buttonStyle(.plain)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Theme.cream)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(Theme.cocoaBorder, lineWidth: 1)
                )
        )
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
    }
}
