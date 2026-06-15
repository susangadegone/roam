import SwiftUI

/// Per-session mood check-in, shown on launch and offered again after extended use.
/// Independent of `OnboardingView`'s one-time preference survey.
struct MoodCheckInView: View {
    @Binding var isShowing: Bool
    @Environment(GamificationStore.self) private var gamification
    @State private var currentPage = 0

    @State private var moodAnswer = ""
    @State private var onMindAnswer = ""
    @State private var needAnswer = ""

    private let totalPages = 3

    private var canProceed: Bool {
        switch currentPage {
        case 0: return !moodAnswer.isEmpty
        case 1: return !onMindAnswer.isEmpty
        case 2: return !needAnswer.isEmpty
        default: return true
        }
    }

    var body: some View {
        ZStack {
            Theme.canvas.ignoresSafeArea()
            VStack(spacing: 0) {
                HStack {
                    Button { goBack() } label: {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundStyle(Theme.cocoa)
                            .padding(12)
                    }
                    .buttonStyle(.plain)

                    Spacer()

                    GrowthProgressView(step: currentPage, totalSteps: totalPages)

                    Spacer()

                    // Balances the back button so the progress view stays centered.
                    Color.clear
                        .frame(width: 41, height: 41)
                }
                .padding(.top, 12)
                .padding(.horizontal, 12)
                .animation(.easeInOut(duration: 0.2), value: currentPage)

                Spacer()

                TabView(selection: $currentPage) {
                    moodPage.tag(0)
                    onMindPage.tag(1)
                    needPage.tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(height: 480)

                Spacer()

                Button {
                    advance()
                } label: {
                    Text(currentPage < totalPages - 1 ? "Next" : "Done")
                        .font(.sans(17, weight: .semibold))
                        .foregroundStyle(Theme.cream)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Capsule().fill(canProceed ? Theme.terracotta : Theme.cocoaBorder))
                        .animation(.easeInOut(duration: 0.2), value: canProceed)
                }
                .buttonStyle(.plain)
                .disabled(!canProceed)
                .padding(.horizontal, 24)
                .padding(.bottom, 52)
            }
        }
    }

    private func advance() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        if currentPage < totalPages - 1 {
            withAnimation(.easeInOut(duration: 0.25)) { currentPage += 1 }
        } else {
            gamification.completeMoodCheckIn(followUp: needAnswer)
            isShowing = false
        }
    }

    private func goBack() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        if currentPage > 0 {
            withAnimation(.easeInOut(duration: 0.25)) { currentPage -= 1 }
        } else {
            isShowing = false
        }
    }

    // MARK: - Pages

    private var moodPage: some View {
        singleSelectPage(
            icon: "heart",
            question: "How are you feeling right now?",
            hint: "There's no wrong answer.",
            options: ["Calm", "Okay", "Stressed", "Overwhelmed", "Low energy"],
            selected: $moodAnswer
        )
    }

    private var onMindPage: some View {
        singleSelectPage(
            icon: "cloud",
            question: "What's on your mind?",
            hint: "Pick what feels closest.",
            options: ["Work or school", "Relationships", "Health", "Money", "A bit of everything", "Nothing in particular"],
            selected: $onMindAnswer
        )
    }

    private var needPage: some View {
        singleSelectPage(
            icon: "sparkles",
            question: "What sounds good right now?",
            hint: "We'll keep this in mind as you explore.",
            options: ["Something calming", "Getting outside", "Connecting with others", "Quiet time alone", "Just exploring"],
            selected: $needAnswer
        )
    }

    // MARK: - Reusable Components

    private func singleSelectPage(icon: String, question: String, hint: String, options: [String], selected: Binding<String>) -> some View {
        VStack(spacing: 20) {
            VStack(spacing: 12) {
                iconBubble(icon)
                VStack(spacing: 6) {
                    Text(question)
                        .font(.serifTitle(24, weight: .semibold))
                        .foregroundStyle(Theme.cocoa)
                        .multilineTextAlignment(.center)
                    Text(hint)
                        .font(.sans(14))
                        .foregroundStyle(Theme.cocoaMuted)
                        .multilineTextAlignment(.center)
                }
            }

            VStack(spacing: 10) {
                ForEach(options, id: \.self) { option in
                    let isSelected = selected.wrappedValue == option
                    Button {
                        UISelectionFeedbackGenerator().selectionChanged()
                        selected.wrappedValue = option
                    } label: {
                        HStack {
                            Text(option)
                                .font(.sans(15))
                                .foregroundStyle(isSelected ? Theme.cream : Theme.cocoa)
                            Spacer()
                            if isSelected {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundStyle(Theme.cream)
                            }
                        }
                        .padding(.horizontal, 20)
                        .frame(height: 52)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(isSelected ? Theme.terracotta : Theme.cream)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .strokeBorder(isSelected ? Theme.terracotta : Theme.cocoaBorder, lineWidth: 1)
                                )
                        )
                    }
                    .buttonStyle(.plain)
                    .animation(.spring(duration: 0.2), value: isSelected)
                }
            }
        }
        .padding(.horizontal, 28)
    }

    private func iconBubble(_ name: String) -> some View {
        ZStack {
            Circle()
                .fill(Theme.cream)
                .frame(width: 80, height: 80)
                .overlay(Circle().strokeBorder(Theme.cocoaBorder, lineWidth: 1))
            Image(systemName: name)
                .font(.system(size: 32, weight: .light))
                .foregroundStyle(Theme.terracotta)
        }
    }
}

/// A nature-themed step indicator: leaves fill in as the check-in progresses.
struct GrowthProgressView: View {
    let step: Int
    let totalSteps: Int

    var body: some View {
        HStack(spacing: 10) {
            ForEach(0..<totalSteps, id: \.self) { i in
                Image(systemName: i <= step ? "leaf.fill" : "leaf")
                    .font(.system(size: i == step ? 16 : 13, weight: .medium))
                    .foregroundStyle(i <= step ? Theme.sage : Theme.cocoaBorder)
            }
        }
        .animation(.spring(duration: 0.3), value: step)
    }
}

#Preview {
    MoodCheckInView(isShowing: .constant(true))
        .environment(GamificationStore())
}
