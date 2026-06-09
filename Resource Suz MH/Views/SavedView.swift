import SwiftUI

struct SavedView: View {
    @Environment(SavedStore.self) private var saved
    @Environment(ResourceStore.self) private var store
    @State private var selectedResource: Resource? = nil

    private var savedResources: [Resource] {
        store.resources.filter { saved.savedIDs.contains($0.id) }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.canvas.ignoresSafeArea()
                if savedResources.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(savedResources) { r in
                                ResourceCard(resource: r) { selectedResource = r }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        .padding(.bottom, 24)
                    }
                }
            }
            .navigationTitle("Saved")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(Theme.canvas, for: .navigationBar)
            .navigationDestination(item: $selectedResource) { r in
                ResourceDetailView(resource: r)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "bookmark")
                .font(.system(size: 28, weight: .light))
                .foregroundStyle(Theme.cocoaMuted)
            Text("Nothing saved yet.")
                .font(.serifTitle(18, weight: .semibold))
                .foregroundStyle(Theme.cocoa)
            Text("Tap \"Save for later\" on any resource\nto bookmark it here.")
                .font(.sans(14))
                .foregroundStyle(Theme.cocoaMuted)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    SavedView()
        .environment(SavedStore())
        .environment(ResourceStore())
}
