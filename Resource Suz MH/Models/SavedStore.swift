import SwiftUI

@Observable
final class SavedStore {
    private static let key = "saved_resource_ids"
    private static let copingKey = "saved_coping_skill_ids"

    private(set) var savedIDs: Set<String>
    private(set) var savedCopingSkillIDs: Set<String>

    init() {
        savedIDs = Set(UserDefaults.standard.stringArray(forKey: Self.key) ?? [])
        savedCopingSkillIDs = Set(UserDefaults.standard.stringArray(forKey: Self.copingKey) ?? [])
    }

    func toggle(_ resource: Resource) {
        if savedIDs.contains(resource.id) {
            savedIDs.remove(resource.id)
        } else {
            savedIDs.insert(resource.id)
        }
        UserDefaults.standard.set(Array(savedIDs), forKey: Self.key)
    }

    func isSaved(_ resource: Resource) -> Bool {
        savedIDs.contains(resource.id)
    }

    func toggle(_ skill: CopingSkill) {
        if savedCopingSkillIDs.contains(skill.id) {
            savedCopingSkillIDs.remove(skill.id)
        } else {
            savedCopingSkillIDs.insert(skill.id)
        }
        UserDefaults.standard.set(Array(savedCopingSkillIDs), forKey: Self.copingKey)
    }

    func isSaved(_ skill: CopingSkill) -> Bool {
        savedCopingSkillIDs.contains(skill.id)
    }
}
