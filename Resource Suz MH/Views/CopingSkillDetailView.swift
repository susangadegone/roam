import SwiftUI

struct CopingSkillDetailView: View {
    let skill: CopingSkill
    @Environment(GamificationStore.self) private var gamification
    @State private var showingCompletionFollowUp = false
    @State private var showingCompletionConfirmation = false
    @State private var completionAwardedPoints = true

    var body: some View {
        ZStack {
            Theme.canvas.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    header
                    summary.padding(.top, 24)
                    stepsList.padding(.top, 24)
                    Color.clear.frame(height: 90)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
            }
            VStack {
                Spacer()
                actionBar
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Theme.canvas, for: .navigationBar)
        .overlay(alignment: .top) {
            if showingCompletionConfirmation {
                completionConfirmationToast
                    .padding(.top, 12)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.spring(duration: 0.3), value: showingCompletionConfirmation)
        .sheet(isPresented: $showingCompletionFollowUp) {
            ActivityFollowUpSheet { answer in
                showingCompletionFollowUp = false
                completionAwardedPoints = gamification.completeActivity(
                    resourceID: "coping-\(skill.id)",
                    title: skill.title,
                    followUp: answer
                )
                showingCompletionConfirmation = true
                Task {
                    try? await Task.sleep(for: .seconds(2.5))
                    showingCompletionConfirmation = false
                }
            }
            .presentationDetents([.medium])
        }
    }

    private var completionConfirmationToast: some View {
        HStack(spacing: 10) {
            Image(systemName: "leaf.fill")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Theme.sage)
            Text(completionAwardedPoints ? "+10 points · Glad you made time for this" : "Logged — thanks for checking in")
                .font(.sans(13, weight: .semibold))
                .foregroundStyle(Theme.cocoa)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Theme.cream)
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(Theme.cocoaBorder, lineWidth: 1)
                )
        )
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            ZStack {
                Circle()
                    .fill(Theme.cream)
                    .frame(width: 56, height: 56)
                    .overlay(Circle().strokeBorder(Theme.cocoaBorder, lineWidth: 1))
                Image(systemName: skill.icon)
                    .font(.system(size: 22, weight: .light))
                    .foregroundStyle(Theme.sage)
            }
            .padding(.bottom, 8)

            Text(skill.title)
                .font(.serifTitle(28, weight: .semibold))
                .foregroundStyle(Theme.cocoa)
            Text(skill.category.rawValue.uppercased())
                .font(.sans(12, weight: .semibold))
                .tracking(0.6)
                .foregroundStyle(Theme.cocoaMuted)
                .padding(.top, 4)
            Text("About \(skill.estimatedMinutes) min")
                .font(.sans(14))
                .foregroundStyle(Theme.cocoaMuted)
                .padding(.top, 4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var summary: some View {
        Text(skill.summary)
            .font(.sans(15))
            .foregroundStyle(Theme.cocoa)
            .lineSpacing(6)
    }

    private var stepsList: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("How to")
                .font(.serifTitle(18, weight: .semibold))
                .foregroundStyle(Theme.cocoa)
            VStack(alignment: .leading, spacing: 12) {
                ForEach(Array(skill.steps.enumerated()), id: \.offset) { index, step in
                    HStack(alignment: .top, spacing: 12) {
                        Text("\(index + 1)")
                            .font(.sans(13, weight: .semibold))
                            .foregroundStyle(Theme.cream)
                            .frame(width: 22, height: 22)
                            .background(Circle().fill(Theme.sage))
                        Text(step)
                            .font(.sans(15))
                            .foregroundStyle(Theme.cocoa)
                            .lineSpacing(4)
                    }
                }
            }
        }
    }

    private var actionBar: some View {
        VStack(spacing: 8) {
            Button {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                showingCompletionFollowUp = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle")
                        .font(.system(size: 14, weight: .semibold))
                    Text("Mark as done")
                        .font(.sans(15, weight: .semibold))
                }
                .foregroundStyle(Theme.cream)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(Capsule().fill(Theme.sage))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 8)
        .background(Theme.canvas)
    }
}

#Preview {
    NavigationStack { CopingSkillDetailView(skill: CopingSkill.all[0]) }
        .environment(GamificationStore())
}
