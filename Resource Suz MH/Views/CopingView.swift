import SwiftUI

struct CopingView: View {
    @Environment(GamificationStore.self) private var gamification
    @State private var selectedSkill: CopingSkill? = nil

    private var suggested: [CopingSkill] {
        guard let category = CopingCategory(rawValue: gamification.lastCheckInFollowUp) else { return [] }
        return CopingSkill.all.filter { $0.category == category }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.canvas.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        header.padding(.top, 4)
                        if !suggested.isEmpty {
                            suggestedSection.padding(.top, 24)
                        }
                        ForEach(CopingCategory.allCases) { category in
                            categorySection(category).padding(.top, 24)
                        }
                        Color.clear.frame(height: 12)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                }
            }
            .navigationDestination(item: $selectedSkill) { skill in
                CopingSkillDetailView(skill: skill)
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Coping skills")
                .font(.serifTitle(28, weight: .semibold))
                .foregroundStyle(Theme.cocoa)
            Text("Small things you can try on your own, wherever you are.")
                .font(.sans(13))
                .foregroundStyle(Theme.cocoaMuted)
                .lineSpacing(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var suggestedSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Suggested for you")
                .font(.serifTitle(18, weight: .semibold))
                .foregroundStyle(Theme.cocoa)
            VStack(spacing: 10) {
                ForEach(suggested) { skill in
                    CopingSkillCard(skill: skill) {
                        selectedSkill = skill
                    }
                }
            }
        }
    }

    private func categorySection(_ category: CopingCategory) -> some View {
        let skills = CopingSkill.all.filter { $0.category == category }
        return VStack(alignment: .leading, spacing: 12) {
            Text(category.rawValue.uppercased())
                .font(.sans(11, weight: .semibold))
                .tracking(0.6)
                .foregroundStyle(Theme.cocoaMuted)
            VStack(spacing: 10) {
                ForEach(skills) { skill in
                    CopingSkillCard(skill: skill) {
                        selectedSkill = skill
                    }
                }
            }
        }
    }
}

private struct CopingSkillCard: View {
    let skill: CopingSkill
    var onTap: () -> Void

    @Environment(SavedStore.self) private var saved
    @Environment(PlanStore.self) private var plan
    @State private var pressed = false

    var body: some View {
        Button(action: {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            onTap()
        }) {
            PaperCard(stripeColor: Theme.sage) {
                HStack(spacing: 14) {
                    Image(systemName: skill.icon)
                        .font(.system(size: 18, weight: .light))
                        .foregroundStyle(Theme.sage)
                        .frame(width: 28)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(skill.title)
                            .font(.serifTitle(16, weight: .semibold))
                            .foregroundStyle(Theme.cocoa)
                        Text(skill.summary)
                            .font(.sans(13))
                            .foregroundStyle(Theme.cocoaMuted)
                            .lineLimit(2)
                    }
                    Spacer(minLength: 8)
                    VStack(spacing: 10) {
                        Text("\(skill.estimatedMinutes)m")
                            .font(.sans(12, weight: .semibold))
                            .foregroundStyle(Theme.cocoaMuted)
                        HStack(spacing: 10) {
                            favoriteButton
                            planButton
                        }
                    }
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .fill(pressed ? Theme.cocoaTapState : .clear)
            )
        }
        .buttonStyle(.plain)
        .frame(minHeight: 44)
        .onLongPressGesture(minimumDuration: 0, pressing: { pressed = $0 }, perform: {})
    }

    private var favoriteButton: some View {
        let isFavorite = saved.isSaved(skill)
        return Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            saved.toggle(skill)
        } label: {
            Image(systemName: isFavorite ? "heart.fill" : "heart")
                .font(.system(size: 15, weight: .regular))
                .foregroundStyle(isFavorite ? Theme.terracotta : Theme.cocoaMuted)
                .frame(width: 24, height: 24)
        }
        .buttonStyle(.plain)
    }

    private var planButton: some View {
        let isPlanned = plan.isPlanned(skill)
        return Button {
            if plan.togglePlanned(skill) {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            } else {
                UINotificationFeedbackGenerator().notificationOccurred(.warning)
            }
        } label: {
            Image(systemName: isPlanned ? "checkmark.circle.fill" : "plus.circle")
                .font(.system(size: 15, weight: .regular))
                .foregroundStyle(isPlanned ? Theme.sage : Theme.cocoaMuted)
                .frame(width: 24, height: 24)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    CopingView()
        .environment(GamificationStore())
        .environment(SavedStore())
        .environment(PlanStore())
}
