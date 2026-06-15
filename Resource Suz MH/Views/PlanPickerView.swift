import SwiftUI

/// Lets the user pick 2-3 coping skills to plan for today.
struct PlanPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(PlanStore.self) private var plan
    @State private var selection: Set<String>

    private let minSelections = 2
    private let maxSelections = 3

    init() {
        _selection = State(initialValue: [])
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.canvas.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        header.padding(.top, 4)
                        ForEach(CopingCategory.allCases) { category in
                            categorySection(category).padding(.top, 24)
                        }
                        Color.clear.frame(height: 100)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                }
            }
            .navigationTitle("Plan your day")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Theme.cocoa)
                }
            }
            .safeAreaInset(edge: .bottom) {
                saveButton
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 8)
                    .background(Theme.canvas)
            }
            .onAppear {
                selection = Set(plan.plannedSkillIDs)
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Pick 2-3 for today")
                .font(.serifTitle(24, weight: .semibold))
                .foregroundStyle(Theme.cocoa)
                .fixedSize(horizontal: false, vertical: true)
            Text("We'll keep these handy on the Coping tab so you can check them off as you go.")
                .font(.sans(13))
                .foregroundStyle(Theme.cocoaMuted)
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func categorySection(_ category: CopingCategory) -> some View {
        let skills = CopingSkill.all.filter { $0.category == category }
        return VStack(alignment: .leading, spacing: 12) {
            Text(category.rawValue.uppercased())
                .font(.sans(11, weight: .semibold))
                .tracking(0.6)
                .foregroundStyle(Theme.cocoaMuted)
            VStack(spacing: 10) {
                ForEach(stride(from: 0, to: skills.count, by: 2).map { $0 }, id: \.self) { i in
                    HStack(spacing: 10) {
                        chip(for: skills[i])
                        if i + 1 < skills.count {
                            chip(for: skills[i + 1])
                        } else {
                            Spacer().frame(maxWidth: .infinity)
                        }
                    }
                }
            }
        }
    }

    private func chip(for skill: CopingSkill) -> some View {
        let isSelected = selection.contains(skill.id)
        let atLimit = selection.count >= maxSelections
        return Button {
            if isSelected {
                UISelectionFeedbackGenerator().selectionChanged()
                selection.remove(skill.id)
            } else if !atLimit {
                UISelectionFeedbackGenerator().selectionChanged()
                selection.insert(skill.id)
            }
        } label: {
            VStack(spacing: 6) {
                Image(systemName: skill.icon)
                    .font(.system(size: 18, weight: .light))
                Text(skill.title)
                    .font(.sans(13))
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
            }
            .foregroundStyle(isSelected ? Theme.cream : Theme.cocoa)
            .padding(.horizontal, 12)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity, minHeight: 76)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? Theme.terracotta : Theme.cream)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(isSelected ? Theme.terracotta : Theme.cocoaBorder, lineWidth: 1)
                    )
            )
            .opacity(!isSelected && atLimit ? 0.5 : 1)
        }
        .buttonStyle(.plain)
        .disabled(!isSelected && atLimit)
        .animation(.spring(duration: 0.2), value: isSelected)
    }

    private var saveButton: some View {
        let canSave = selection.count >= minSelections && selection.count <= maxSelections
        return Button {
            plan.setPlan(Array(selection))
            dismiss()
        } label: {
            Text(canSave ? "Save plan" : "Pick \(minSelections)-\(maxSelections) to continue")
                .font(.sans(17, weight: .semibold))
                .foregroundStyle(Theme.cream)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Capsule().fill(canSave ? Theme.terracotta : Theme.cocoaBorder))
                .animation(.easeInOut(duration: 0.2), value: canSave)
        }
        .buttonStyle(.plain)
        .disabled(!canSave)
    }
}

#Preview {
    PlanPickerView()
        .environment(PlanStore())
}
