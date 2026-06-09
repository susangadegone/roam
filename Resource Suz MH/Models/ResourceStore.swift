import SwiftUI

@Observable
final class ResourceStore {
    private(set) var resources: [Resource] = SampleData.resources
    private(set) var isLoading = false
    private(set) var hasFetchError = false

    func refresh() async {
        isLoading = true
        hasFetchError = false
        print("[ResourceStore] Fetching from Airtable…")
        do {
            let fetched = try await ResourceService.fetch()
            if !fetched.isEmpty {
                resources = fetched
                print("[ResourceStore] ✓ Loaded \(fetched.count) resources from Airtable")
            } else {
                print("[ResourceStore] Airtable returned 0 records — keeping sample data")
            }
        } catch {
            hasFetchError = true
            print("[ResourceStore] ✗ Fetch failed: \(error) — keeping sample data")
        }
        isLoading = false
    }
}
