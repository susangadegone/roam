import SwiftUI

struct AppTourOverlay: View {
    @Binding var isShowing: Bool

    @AppStorage("pref_area") private var prefArea = ""
    @AppStorage("pref_access") private var prefAccess = ""
    @AppStorage("pref_distance") private var prefDistance = ""
    @AppStorage("pref_interests") private var prefInterests = ""
    @AppStorage("hasSeenAppTour") private var hasSeenAppTour = false

    @Environment(TabSelection.self) private var tabSelection

    @State private var currentStep = 0

    private enum SpotlightTarget {
        case tabBarItem(index: Int)
        case navBarTrailing
        case none
    }

    private struct TourStep {
        let tab: RootTabView.Tab
        let spotlight: SpotlightTarget
        let title: String
        let body: String
    }

    private var steps: [TourStep] {
        let area = prefArea.isEmpty ? "your area" : prefArea
        let interests = Set(prefInterests.split(separator: ",").map(String.init))
        let isHomeBased = prefAccess == "Solo, on my own terms" || prefDistance == "Close to home"
        let hasOutdoors = !interests.isDisjoint(with: ["fitness", "movement", "natureWellness"])

        let homeBody: String
        let copingBody: String

        if isHomeBased {
            copingBody = "Breathing exercises, grounding techniques, short stretches — use this when you need something right now, wherever you are."
            homeBody = "Browse free and low-cost spots near you in \(area). Search or filter by what fits today."
        } else if hasOutdoors {
            homeBody = "Parks, trails, and fitness spots near you in \(area). Filter by what fits your energy today."
            copingBody = "For days when getting out feels like too much — quick skills you can do anywhere."
        } else {
            homeBody = "Browse free and low-cost spots near you in \(area). Search or filter by what fits."
            copingBody = "Quick skills for hard moments — breathing, grounding, stretches. Works anywhere."
        }

        let tabOrder: [TourStep] = isHomeBased ? [
            TourStep(tab: .coping, spotlight: .tabBarItem(index: 1), title: "Coping", body: copingBody),
            TourStep(tab: .home,   spotlight: .tabBarItem(index: 0), title: "Home",   body: homeBody),
        ] : hasOutdoors ? [
            TourStep(tab: .home,   spotlight: .tabBarItem(index: 0), title: "Home",   body: homeBody),
            TourStep(tab: .coping, spotlight: .tabBarItem(index: 1), title: "Coping", body: copingBody),
        ] : [
            TourStep(tab: .home,   spotlight: .tabBarItem(index: 0), title: "Home",   body: homeBody),
            TourStep(tab: .coping, spotlight: .tabBarItem(index: 1), title: "Coping", body: copingBody),
        ]

        return tabOrder + [
            TourStep(tab: .map,     spotlight: .tabBarItem(index: 2), title: "Map",
                     body: "See everything as pins. Tap a pin to preview, tap again for details."),
            TourStep(tab: .saved,   spotlight: .tabBarItem(index: 3), title: "Saved",
                     body: "Bookmark any resource from the Home tab or its detail page. Find them all here."),
            TourStep(tab: .profile, spotlight: .tabBarItem(index: 4), title: "Profile",
                     body: "Update your preferences, track your journey, and replay onboarding anytime."),
            TourStep(tab: .home,    spotlight: .navBarTrailing,        title: "Crisis support",
                     body: "Tap the phone icon in the top right anytime for crisis lines — free, confidential, available now."),
        ]
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                spotlightLayer(geo: geo)
                VStack(spacing: 0) {
                    Spacer()
                    tooltipCard
                        .padding(.horizontal, 20)
                        .padding(.bottom, geo.safeAreaInsets.bottom + 49 + 20)
                }
            }
        }
        .ignoresSafeArea()
        .onAppear { activateCurrentStep() }
    }

    // MARK: - Spotlight

    private func spotlightCenter(geo: GeometryProxy) -> CGPoint? {
        switch steps[currentStep].spotlight {
        case .tabBarItem(let index):
            let tabWidth = geo.size.width / 5.0
            return CGPoint(
                x: tabWidth * CGFloat(index) + tabWidth / 2,
                y: geo.size.height - geo.safeAreaInsets.bottom - 24.5
            )
        case .navBarTrailing:
            // Phone icon is left of info icon in the trailing group
            return CGPoint(x: geo.size.width - 60, y: geo.safeAreaInsets.top + 22)
        case .none:
            return nil
        }
    }

    private func spotlightRadius() -> CGFloat {
        switch steps[currentStep].spotlight {
        case .navBarTrailing: return 52
        default: return 76
        }
    }

    @ViewBuilder
    private func spotlightLayer(geo: GeometryProxy) -> some View {
        if let center = spotlightCenter(geo: geo) {
            let r = spotlightRadius()
            Rectangle()
                .fill(Color.black.opacity(0.65))
                .mask {
                    Rectangle()
                        .overlay {
                            Circle()
                                .frame(width: r, height: r)
                                .position(center)
                                .blendMode(.destinationOut)
                        }
                        .compositingGroup()
                }
                .animation(.spring(duration: 0.4), value: currentStep)
        } else {
            Rectangle()
                .fill(Color.black.opacity(0.65))
                .animation(.easeInOut(duration: 0.3), value: currentStep)
        }
    }

    // MARK: - Tooltip

    private var tooltipCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(steps[currentStep].title)
                    .font(.serifTitle(18, weight: .semibold))
                    .foregroundStyle(Theme.cocoa)
                Text(steps[currentStep].body)
                    .font(.sans(14))
                    .foregroundStyle(Theme.cocoaMuted)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .id(currentStep)
            .transition(AnyTransition.opacity.combined(with: .move(edge: .trailing)))

            HStack {
                HStack(spacing: 6) {
                    ForEach(0..<steps.count, id: \.self) { i in
                        Capsule()
                            .fill(i == currentStep ? Theme.cocoa : Theme.cocoaBorder)
                            .frame(width: i == currentStep ? 16 : 6, height: 6)
                            .animation(.spring(duration: 0.3), value: currentStep)
                    }
                }
                Spacer()
                Button(action: advance) {
                    Text(currentStep < steps.count - 1 ? "Next" : "Got it")
                        .font(.sans(15, weight: .semibold))
                        .foregroundStyle(Theme.cream)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Capsule().fill(Theme.terracotta))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Theme.canvas)
                .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(Theme.cocoaBorder, lineWidth: 1))
        )
        .shadow(color: Color.black.opacity(0.1), radius: 12, x: 0, y: 4)
    }

    // MARK: - Actions

    private func activateCurrentStep() {
        withAnimation(.easeInOut(duration: 0.3)) {
            tabSelection.selection = steps[currentStep].tab
        }
    }

    private func advance() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        if currentStep < steps.count - 1 {
            withAnimation(.spring(duration: 0.4)) { currentStep += 1 }
            activateCurrentStep()
        } else {
            hasSeenAppTour = true
            withAnimation(.easeOut(duration: 0.3)) { isShowing = false }
            tabSelection.selection = .home
        }
    }
}
