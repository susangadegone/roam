import SwiftUI

struct RootView: View {
    @AppStorage("hasAccount") private var hasAccount = false
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @AppStorage("hasSeenMoodIntro") private var hasSeenMoodIntro = false
    @AppStorage("hasSeenAppTour") private var hasSeenAppTour = false

    @State private var showMoodCheckIn = true
    @State private var showRecheckPrompt = false
    @State private var showingTour = false

    private static let recheckInterval: Duration = .seconds(30 * 60)

    private enum Cover {
        case auth, onboarding, moodIntro, moodCheckIn
    }

    private var activeCover: Cover? {
        if !hasAccount { return .auth }
        if !hasSeenOnboarding { return .onboarding }
        if !hasSeenMoodIntro { return .moodIntro }
        if showMoodCheckIn { return .moodCheckIn }
        return nil
    }

    var body: some View {
        ZStack {
            RootTabView()
                .fullScreenCover(isPresented: Binding(
                    get: { activeCover != nil },
                    set: { _ in }
                )) {
                    switch activeCover {
                    case .auth:
                        AuthView()
                    case .onboarding:
                        OnboardingView(isShowing: Binding(
                            get: { !hasSeenOnboarding },
                            set: { _ in }
                        ))
                    case .moodIntro:
                        MoodIntroView()
                    case .moodCheckIn:
                        MoodCheckInView(isShowing: $showMoodCheckIn)
                    case nil:
                        EmptyView()
                    }
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
                .onChange(of: showMoodCheckIn) { _, isShowing in
                    if !isShowing && hasAccount && hasSeenOnboarding && hasSeenMoodIntro && !hasSeenAppTour {
                        Task {
                            try? await Task.sleep(for: .milliseconds(500))
                            withAnimation(.easeIn(duration: 0.3)) { showingTour = true }
                        }
                    }
                }

            if showingTour {
                AppTourOverlay(isShowing: $showingTour)
                    .transition(.opacity)
            }
        }
    }
}

private struct MoodIntroView: View {
    @AppStorage("hasSeenMoodIntro") private var hasSeenMoodIntro = false

    var body: some View {
        ZStack {
            Theme.canvas.ignoresSafeArea()
            VStack(spacing: 0) {
                Spacer()
                VStack(spacing: 28) {
                    ZStack {
                        Circle()
                            .fill(Theme.cream)
                            .frame(width: 80, height: 80)
                            .overlay(Circle().strokeBorder(Theme.cocoaBorder, lineWidth: 1))
                        Image(systemName: "waveform.path.ecg")
                            .font(.system(size: 32, weight: .light))
                            .foregroundStyle(Theme.terracotta)
                    }
                    VStack(spacing: 12) {
                        Text("How are you feeling today?")
                            .font(.serifTitle(26, weight: .semibold))
                            .foregroundStyle(Theme.cocoa)
                            .multilineTextAlignment(.center)
                        Text("We ask this each time you open roam.\nYour answer helps us show you what fits right now.")
                            .font(.sans(15))
                            .foregroundStyle(Theme.cocoaMuted)
                            .multilineTextAlignment(.center)
                            .lineSpacing(5)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(.horizontal, 32)
                Spacer()
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    hasSeenMoodIntro = true
                } label: {
                    Text("Got it")
                        .font(.sans(17, weight: .semibold))
                        .foregroundStyle(Theme.cream)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Capsule().fill(Theme.terracotta))
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 24)
                .padding(.bottom, 52)
            }
        }
    }
}

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
