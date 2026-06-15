import SwiftUI

@main
struct ResourceSuzApp: App {
    @State private var savedStore = SavedStore()
    @State private var resourceStore = ResourceStore()
    @State private var gamificationStore = GamificationStore()
    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(savedStore)
                .environment(resourceStore)
                .environment(gamificationStore)
                .tint(Theme.terracotta)
                .preferredColorScheme(.light)
                .task {
                    await resourceStore.refresh()
                }
        }
    }
}
