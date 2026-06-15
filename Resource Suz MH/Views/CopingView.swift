import SwiftUI

struct CopingView: View {
    @Environment(GamificationStore.self) private var gamification
    @Environment(PlanStore.self) private var plan
    @State private var selectedSkill: CopingSkill? = nil
    @State private var showingPlanPicker = false

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
                        todaysPlanSection.padding(.top, 24)
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
            .sheet(isPresented: $showingPlanPicker) {
                PlanPickerView()
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

    @ViewBuilder
    private var todaysPlanSection: some View {
        if plan.plannedSkills.isEmpty {
            Button {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                showingPlanPicker = true
            } label: {
                PaperCard(stripeColor: Theme.terracotta) {
                    HStack(spacing: 14) {
                        Image(systemName: "list.bullet.clipboard")
                            .font(.system(size: 18, weight: .light))
                            .foregroundStyle(Theme.terracotta)
                            .frame(width: 28)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Plan your day")
                                .font(.serifTitle(16, weight: .semibold))
                                .foregroundStyle(Theme.cocoa)
                            Text("Pick 2-3 things to try today.")
                                .font(.sans(13))
                                .foregroundStyle(Theme.cocoaMuted)
                        }
                        Spacer(minLength: 8)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(Theme.cocoaMuted)
                    }
                }
            }
            .buttonStyle(.plain)
        } else {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Today's plan")
                        .font(.serifTitle(18, weight: .semibold))
                        .foregroundStyle(Theme.cocoa)
                    Spacer()
                    Button {
                        showingPlanPicker = true
                    } label: {
                        Text("Edit")
                            .font(.sans(13, weight: .semibold))
                            .foregroundStyle(Theme.terracotta)
                    }
                }
                VStack(spacing: 10) {
                    ForEach(plan.plannedSkills) { skill in
                        PlanItemRow(
                            skill: skill,
                            isCompleted: plan.isCompleted(skill.id),
                            onToggle: {
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                plan.toggleCompletion(skill.id)
                                if plan.isCompleted(skill.id) {
                                    gamification.completeActivity(
                                        resourceID: "plan-\(skill.id)",
                                        title: skill.title,
                                        followUp: skill.category.rawValue
                                    )
                                }
                            },
                            onTap: { selectedSkill = skill }
                        )
                    }
                }
            }
        }
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
                    Text("\(skill.estimatedMinutes)m")
                        .font(.sans(12, weight: .semibold))
                        .foregroundStyle(Theme.cocoaMuted)
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
}

private struct PlanItemRow: View {
    let skill: CopingSkill
    let isCompleted: Bool
    var onToggle: () -> Void
    var onTap: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            Button(action: onToggle) {
                Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22, weight: .regular))
                    .foregroundStyle(isCompleted ? Theme.sage : Theme.cocoaMuted)
            }
            .buttonStyle(.plain)
            .frame(width: 28)

            Button {
                onTap()
            } label: {
                HStack(spacing: 14) {
                    Image(systemName: skill.icon)
                        .font(.system(size: 16, weight: .light))
                        .foregroundStyle(Theme.sage)
                        .frame(width: 22)
                    Text(skill.title)
                        .font(.sans(15, weight: .medium))
                        .foregroundStyle(isCompleted ? Theme.cocoaMuted : Theme.cocoa)
                        .strikethrough(isCompleted)
                    Spacer(minLength: 8)
                    Text("\(skill.estimatedMinutes)m")
                        .font(.sans(12, weight: .semibold))
                        .foregroundStyle(Theme.cocoaMuted)
                }
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 14)
        .frame(height: 52)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Theme.cream)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Theme.cocoaBorder, lineWidth: 1)
                )
        )
        .animation(.spring(duration: 0.2), value: isCompleted)
    }
}

#Preview {
    CopingView()
        .environment(GamificationStore())
        .environment(PlanStore())
}
