import SwiftUI

struct RootTabView: View {
    @State private var selection: Tab = .home

    enum Tab: Hashable { case home, coping, map, saved, profile }

    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Theme.canvas)
        appearance.shadowColor = UIColor(Theme.cocoa.opacity(0.15))

        let normal = UIColor(Theme.cocoa)
        let selected = UIColor(Theme.terracotta)

        let items: [UITabBarItemAppearance] = [
            appearance.stackedLayoutAppearance,
            appearance.inlineLayoutAppearance,
            appearance.compactInlineLayoutAppearance
        ]
        for item in items {
            item.normal.iconColor = normal
            item.normal.titleTextAttributes = [.foregroundColor: normal,
                                                .font: UIFont.systemFont(ofSize: 11, weight: .medium)]
            item.selected.iconColor = selected
            item.selected.titleTextAttributes = [.foregroundColor: selected,
                                                  .font: UIFont.systemFont(ofSize: 11, weight: .semibold)]
        }
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        TabView(selection: $selection) {
            HomeView()
                .tabItem { Label("Home", systemImage: "house") }
                .tag(Tab.home)

            CopingView()
                .tabItem { Label("Coping", systemImage: "sparkles") }
                .tag(Tab.coping)

            MapView()
                .tabItem { Label("Map", systemImage: "map") }
                .tag(Tab.map)

            SavedView()
                .tabItem { Label("Saved", systemImage: "bookmark") }
                .tag(Tab.saved)

            ProfileView()
                .tabItem { Label("Profile", systemImage: "person") }
                .tag(Tab.profile)
        }
    }
}

struct PlaceholderTab: View {
    let title: String
    let message: String
    let systemImage: String

    var body: some View {
        ZStack {
            Theme.canvas.ignoresSafeArea()
            VStack(spacing: 16) {
                Image(systemName: systemImage)
                    .font(.system(size: 36, weight: .light))
                    .foregroundStyle(Theme.cocoa.opacity(0.7))
                    .padding(20)
                    .background(
                        Circle()
                            .fill(Theme.cream)
                            .overlay(Circle().strokeBorder(Theme.cocoaBorder, lineWidth: 1))
                    )
                Text(title)
                    .font(.serifTitle(28, weight: .semibold))
                    .foregroundStyle(Theme.cocoa)
                Text(message)
                    .font(.sans(15))
                    .foregroundStyle(Theme.cocoaMuted)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
        }
    }
}

#Preview {
    RootTabView()
        .environment(SavedStore())
        .environment(ResourceStore())
        .environment(GamificationStore())
}
