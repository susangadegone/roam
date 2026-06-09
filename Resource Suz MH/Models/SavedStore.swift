import SwiftUI

@Observable
final class SavedStore {
    private static let key = "saved_resource_ids"

    private(set) var savedIDs: Set<String>

    init() {
        let stored = UserDefaults.standard.stringArray(forKey: Self.key) ?? []
        savedIDs = Set(stored)
    }

    func toggle(_ resource: Resource) {
        if savedIDs.contains(resource.id) {
            savedIDs.remove(resource.id)
        } else {
            savedIDs.insert(resource.id)
        }
        persist()
    }

    func isSaved(_ resource: Resource) -> Bool {
        savedIDs.contains(resource.id)
    }

    private func persist() {
        UserDefaults.standard.set(Array(savedIDs), forKey: Self.key)
    }
}
