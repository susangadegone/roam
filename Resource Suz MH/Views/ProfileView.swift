import SwiftUI

struct ProfileView: View {
    @AppStorage("hasAccount") private var hasAccount = false
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @Environment(GamificationStore.self) private var gamification
    @State private var showingCrisis = false
    @State private var showingOnboarding = false

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.canvas.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 20) {
                        brandHeader
                        journeySection
                        crisisSection
                        howToUseRow
                        replayOnboardingRow
                        signOutRow
                        aboutSection
                        versionFooter
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(Theme.canvas, for: .navigationBar)
            .sheet(isPresented: $showingCrisis) {
                CrisisSheet().presentationDetents([.medium, .large])
            }
            .fullScreenCover(isPresented: $showingOnboarding) {
                OnboardingView(isShowing: $showingOnboarding)
            }
        }
    }

    private var brandHeader: some View {
        VStack(spacing: 6) {
            Text("roam")
                .font(.serifTitle(36, weight: .semibold))
                .foregroundStyle(Theme.cocoa)
            Text("Small steps, every day.")
                .font(.sans(14))
                .foregroundStyle(Theme.cocoaMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
    }

    private var journeySection: some View {
        sectionCard {
            VStack(alignment: .leading, spacing: 16) {
                label("Your journey", icon: "leaf")

                HStack(spacing: 12) {
                    statTile(value: "\(gamification.totalPoints)", label: "Points", icon: "sparkles", tint: Theme.terracotta)
                    statTile(value: "\(gamification.currentStreak)", label: gamification.currentStreak == 1 ? "Day streak" : "Day streak", icon: "leaf.fill", tint: Theme.sage)
                }

                if !gamification.recentActivity.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Recent activity")
                            .font(.sans(11, weight: .semibold))
                            .tracking(0.6)
                            .foregroundStyle(Theme.cocoaMuted)

                        VStack(spacing: 8) {
                            ForEach(gamification.recentActivity) { entry in
                                activityRow(entry)
                            }
                        }
                    }
                }
            }
            .padding(16)
        }
    }

    private func statTile(value: String, label: String, icon: String, tint: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(tint)
            Text(value)
                .font(.serifTitle(26, weight: .semibold))
                .foregroundStyle(Theme.cocoa)
            Text(label)
                .font(.sans(12))
                .foregroundStyle(Theme.cocoaMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Theme.canvas)
                .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(Theme.cocoaBorder, lineWidth: 1))
        )
    }

    private func activityRow(_ entry: ActivityLogEntry) -> some View {
        HStack(spacing: 10) {
            Image(systemName: entry.points >= 10 ? "checkmark.circle.fill" : "leaf.fill")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(entry.points >= 10 ? Theme.terracotta : Theme.sage)

            VStack(alignment: .leading, spacing: 2) {
                Text(entry.title)
                    .font(.sans(14, weight: .medium))
                    .foregroundStyle(Theme.cocoa)
                Text(entry.date.formatted(.relative(presentation: .named)))
                    .font(.sans(12))
                    .foregroundStyle(Theme.cocoaMuted)
            }

            Spacer()

            Text("+\(entry.points)")
                .font(.sans(13, weight: .semibold))
                .foregroundStyle(Theme.terracotta)
        }
    }

    private var crisisSection: some View {
        sectionCard {
            Button {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                showingCrisis = true
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Crisis support")
                            .font(.sans(15, weight: .semibold))
                            .foregroundStyle(Theme.cream)
                        Text("Free, confidential, available now")
                            .font(.sans(13))
                            .foregroundStyle(Theme.cream.opacity(0.8))
                    }
                    Spacer()
                    Image(systemName: "arrow.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Theme.cream)
                }
                .padding(16)
                .background(RoundedRectangle(cornerRadius: 12).fill(Theme.terracotta))
            }
            .buttonStyle(.plain)
        }
    }

    private var howToUseRow: some View {
        sectionCard {
            NavigationLink(destination: HowToUseView()) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("How to use Roam")
                            .font(.sans(15, weight: .semibold))
                            .foregroundStyle(Theme.cocoa)
                        Text("Browse, filter, save, and navigate")
                            .font(.sans(13))
                            .foregroundStyle(Theme.cocoaMuted)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Theme.cocoaMuted)
                }
                .padding(16)
            }
            .buttonStyle(.plain)
        }
    }

    private var replayOnboardingRow: some View {
        sectionCard {
            Button {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                showingOnboarding = true
            } label: {
                HStack {
                    Text("Replay intro")
                        .font(.sans(15, weight: .semibold))
                        .foregroundStyle(Theme.cocoa)
                    Spacer()
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(Theme.cocoaMuted)
                }
                .padding(16)
            }
            .buttonStyle(.plain)
        }
    }

    private var signOutRow: some View {
        sectionCard {
            Button {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                hasSeenOnboarding = false
                hasAccount = false
            } label: {
                HStack {
                    Text("Sign out")
                        .font(.sans(15, weight: .semibold))
                        .foregroundStyle(Theme.terracotta)
                    Spacer()
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(Theme.terracotta)
                }
                .padding(16)
            }
            .buttonStyle(.plain)
        }
    }

    private var aboutSection: some View {
        sectionCard {
            VStack(alignment: .leading, spacing: 12) {
                label("About Roam", icon: "info.circle")
                Text("Roam connects you to free and low-cost events, activities, and resources across the SF Bay Area — no account needed, no labels, just good things nearby.")
                    .font(.sans(14))
                    .foregroundStyle(Theme.cocoa)
                    .lineSpacing(4)
            }
            .padding(16)
        }
    }

    private var versionFooter: some View {
        Text("Roam · v1.0 · SF Bay Area")
            .font(.sans(12))
            .foregroundStyle(Theme.cocoaMuted)
            .padding(.top, 8)
    }

    private func label(_ text: String, icon: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .regular))
                .foregroundStyle(Theme.cocoaMuted)
            Text(text.uppercased())
                .font(.sans(11, weight: .semibold))
                .tracking(0.6)
                .foregroundStyle(Theme.cocoaMuted)
        }
    }

    private func sectionCard<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        content()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Theme.cream)
                    .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(Theme.cocoaBorder, lineWidth: 1))
            )
    }
}

#Preview {
    ProfileView()
        .environment(GamificationStore())
}
