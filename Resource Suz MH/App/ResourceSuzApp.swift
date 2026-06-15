import SwiftUI

@main
struct ResourceSuzApp: App {
    @State private var savedStore = SavedStore()
    @State private var resourceStore = ResourceStore()
    @State private var gamificationStore = GamificationStore()
    @State private var tabSelection = TabSelection()
    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(savedStore)
                .environment(resourceStore)
                .environment(gamificationStore)
                .environment(tabSelection)
                .tint(Theme.terracotta)
                .preferredColorScheme(.light)
                .task {
                    await resourceStore.refresh()
                }
        }
    }
}
