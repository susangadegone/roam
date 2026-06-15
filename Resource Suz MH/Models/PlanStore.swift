import SwiftUI

/// Tracks the user's self-chosen "today's plan" — 2-3 coping skills picked for the day,
/// checked off as they're completed. Resets each calendar day.
@Observable
final class PlanStore {
    private static let planDateKey = "planDate"
    private static let plannedSkillIDsKey = "plannedSkillIDs"
    private static let completedSkillIDsKey = "completedSkillIDs"

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    private(set) var plannedSkillIDs: [String]
    private(set) var completedSkillIDs: Set<String>

    var plannedSkills: [CopingSkill] {
        plannedSkillIDs.compactMap { id in CopingSkill.all.first { $0.id == id } }
    }

    init() {
        let defaults = UserDefaults.standard
        let storedDate = defaults.string(forKey: Self.planDateKey) ?? ""
        let today = Self.dateFormatter.string(from: Date())

        if storedDate == today {
            plannedSkillIDs = defaults.stringArray(forKey: Self.plannedSkillIDsKey) ?? []
            completedSkillIDs = Set(defaults.stringArray(forKey: Self.completedSkillIDsKey) ?? [])
        } else {
            plannedSkillIDs = []
            completedSkillIDs = []
        }
    }

    func isCompleted(_ id: String) -> Bool {
        completedSkillIDs.contains(id)
    }

    func setPlan(_ ids: [String]) {
        plannedSkillIDs = ids
        completedSkillIDs = []
        let defaults = UserDefaults.standard
        defaults.set(Self.dateFormatter.string(from: Date()), forKey: Self.planDateKey)
        defaults.set(ids, forKey: Self.plannedSkillIDsKey)
        defaults.set([], forKey: Self.completedSkillIDsKey)
    }

    func toggleCompletion(_ id: String) {
        if completedSkillIDs.contains(id) {
            completedSkillIDs.remove(id)
        } else {
            completedSkillIDs.insert(id)
        }
        UserDefaults.standard.set(Array(completedSkillIDs), forKey: Self.completedSkillIDsKey)
    }
}
