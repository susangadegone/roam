import SwiftUI

struct OnboardingView: View {
    @Binding var isShowing: Bool
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @State private var currentPage = 0

    @AppStorage("pref_area") private var prefArea = ""
    @AppStorage("pref_interests") private var prefInterests = ""
    @AppStorage("pref_access") private var prefAccess = ""
    @AppStorage("pref_cost") private var prefCost = ""
    @AppStorage("pref_distance") private var prefDistance = ""

    @State private var areaAnswer = ""
    @State private var interestsAnswer: Set<String> = []
    @State private var accessAnswer = ""
    @State private var costAnswer = ""
    @State private var distanceAnswer = ""

    private let totalPages = 7

    private static let interestGroups: [(label: String, categories: [ResourceCategory])] = [
        ("Movement & outdoors",  [.fitness, .movement, .natureWellness]),
        ("Mind & wellness",      [.meditation, .soundHealing, .quiet]),
        ("Creative & art",       [.creative]),
        ("Events & community",   [.events, .communityEvent, .social, .community]),
        ("Learning & culture",   [.learning, .libraryProgram, .libraryEvent, .talks, .talksCulture]),
        ("Health & support",     [.healthcare, .peer, .counseling, .publicHealth, .youthHealth, .seniorWellness, .crisisSupport, .resource]),
    ]

    private var canProceed: Bool {
        switch currentPage {
        case 0: return true
        case 1: return !areaAnswer.isEmpty
        case 2: return !interestsAnswer.isEmpty
        case 3: return !accessAnswer.isEmpty
        case 4: return !costAnswer.isEmpty
        case 5: return !distanceAnswer.isEmpty
        default: return true
        }
    }

    var body: some View {
        ZStack {
            Theme.canvas.ignoresSafeArea()
            VStack(spacing: 0) {
                HStack {
                    if currentPage > 0 {
                        Button { goBack() } label: {
                            Image(systemName: "arrow.left")
                                .font(.system(size: 17, weight: .medium))
                                .foregroundStyle(Theme.cocoa)
                                .padding(12)
                        }
                        .buttonStyle(.plain)
                        .transition(.opacity.combined(with: .scale(scale: 0.8)))
                    }
                    Spacer()
                }
                .padding(.top, 12)
                .padding(.horizontal, 12)
                .animation(.easeInOut(duration: 0.2), value: currentPage)

                Spacer()

                TabView(selection: $currentPage) {
                    welcomePage.tag(0)
                    areaPage.tag(1)
                    interestsPage.tag(2)
                    accessPage.tag(3)
                    costPage.tag(4)
                    distancePage.tag(5)
                    tourPage.tag(6)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(height: 480)

                Spacer()

                HStack(spacing: 8) {
                    ForEach(0..<totalPages, id: \.self) { i in
                        Capsule()
                            .fill(i == currentPage ? Theme.cocoa : Theme.cocoaBorder)
                            .frame(width: i == currentPage ? 20 : 6, height: 6)
                            .animation(.spring(duration: 0.3), value: currentPage)
                    }
                }
                .padding(.bottom, 28)

                Button {
                    advance()
                } label: {
                    Text(currentPage == 0 ? "Get started" : currentPage < totalPages - 1 ? "Next" : "Start exploring")
                        .font(.sans(17, weight: .semibold))
                        .foregroundStyle(Theme.cream)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Capsule().fill(canProceed ? Theme.terracotta : Theme.cocoaBorder))
                        .animation(.easeInOut(duration: 0.2), value: canProceed)
                }
                .buttonStyle(.plain)
                .disabled(!canProceed)
                .padding(.horizontal, 24)
                .padding(.bottom, 52)
            }
        }
    }

    private func advance() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        if currentPage < totalPages - 1 {
            withAnimation(.easeInOut(duration: 0.25)) { currentPage += 1 }
        } else {
            prefArea = areaAnswer
            let expanded = interestsAnswer.flatMap { label in
                Self.interestGroups.first(where: { $0.label == label })?.categories.map(\.rawValue) ?? [label]
            }
            prefInterests = expanded.joined(separator: ",")
            prefAccess = accessAnswer
            prefCost = costAnswer
            prefDistance = distanceAnswer
            hasSeenOnboarding = true
            isShowing = false
        }
    }

    private func goBack() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        withAnimation(.easeInOut(duration: 0.25)) { currentPage -= 1 }
    }

    // MARK: - Pages

    private var welcomePage: some View {
        VStack(spacing: 28) {
            iconBubble("leaf.fill")
            VStack(spacing: 12) {
                Text("roam")
                    .font(.serifTitle(30, weight: .semibold))
                    .foregroundStyle(Theme.cocoa)
                Text("Small steps, every day.\nLet's find what fits you.")
                    .font(.sans(16))
                    .foregroundStyle(Theme.cocoaMuted)
                    .multilineTextAlignment(.center)
                    .lineSpacing(5)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.horizontal, 36)
    }

    private var areaPage: some View {
        singleSelectPage(
            icon: "map",
            question: "Where are you based?",
            hint: "We'll show you what's nearby first.",
            options: ["San Francisco", "East Bay"],
            selected: $areaAnswer
        )
    }

    private var interestsPage: some View {
        multiSelectPage(
            icon: "sparkles",
            question: "What sounds good to you?",
            hint: "Pick everything that fits.",
            options: Self.interestGroups.map { $0.label },
            selected: $interestsAnswer
        )
    }

    private var accessPage: some View {
        singleSelectPage(
            icon: "figure.walk",
            question: "How do you like to show up?",
            hint: "No right answer — just helps us find what fits.",
            options: ["Solo, on my own terms", "Open to being around others", "Depends on the day"],
            selected: $accessAnswer
        )
    }

    private var costPage: some View {
        singleSelectPage(
            icon: "dollarsign.circle",
            question: "What's your budget?",
            hint: "No judgement — just helps us find the right stuff.",
            options: ["Free only", "Low-cost OK", "Open to anything"],
            selected: $costAnswer
        )
    }

    private var distancePage: some View {
        singleSelectPage(
            icon: "location",
            question: "How far will you wander?",
            hint: "We'll prioritize accordingly.",
            options: ["Close to home", "A short trip is fine", "Take me anywhere"],
            selected: $distanceAnswer
        )
    }

    private struct TourItem {
        let icon: String
        let tab: String
        let body: String
    }

    private var tourItems: [TourItem] {
        var items: [TourItem] = []

        // Coping — always shown, description adapts to access/distance
        let copingBody: String
        if accessAnswer == "Solo, on my own terms" || distanceAnswer == "Close to home" {
            copingBody = "Breathing exercises, grounding techniques, short stretches — at home, on BART, wherever you are."
        } else {
            copingBody = "Quick skills for hard moments. No setup, no commute — works anywhere."
        }
        items.append(TourItem(icon: "sparkles", tab: "Coping", body: copingBody))

        // Home — always shown, description adapts to top interest + area
        let area = areaAnswer.isEmpty ? "your area" : areaAnswer
        let homeBody: String
        if interestsAnswer.contains("Movement & outdoors") {
            homeBody = "Parks, trails, and fitness spots near you in \(area). Filter by what fits your energy today."
        } else if interestsAnswer.contains("Events & community") {
            homeBody = "Free events and community spots in \(area). Search by neighborhood or filter by category."
        } else if interestsAnswer.contains("Learning & culture") {
            homeBody = "Talks, libraries, and cultural spots in \(area). Filter by cost or distance."
        } else if interestsAnswer.contains("Creative & art") {
            homeBody = "Creative spaces and art resources in \(area). Filter by cost or distance."
        } else {
            homeBody = "Free and low-cost spots near you in \(area). Search or filter by what fits."
        }
        items.append(TourItem(icon: "house", tab: "Home", body: homeBody))

        // Map — only if they're willing to travel
        if distanceAnswer != "Close to home" {
            items.append(TourItem(icon: "map", tab: "Map", body: "See everything as pins. Good for picking based on what's actually near you right now."))
        }

        // Crisis — always last
        items.append(TourItem(icon: "phone", tab: "Crisis support", body: "Always one tap away from the Home tab if you need it now."))

        return items
    }

    private var tourPage: some View {
        VStack(spacing: 20) {
            VStack(spacing: 12) {
                iconBubble("map.fill")
                VStack(spacing: 6) {
                    Text("Here's where to start")
                        .font(.serifTitle(24, weight: .semibold))
                        .foregroundStyle(Theme.cocoa)
                        .multilineTextAlignment(.center)
                    Text("Based on what you shared.")
                        .font(.sans(14))
                        .foregroundStyle(Theme.cocoaMuted)
                        .multilineTextAlignment(.center)
                }
            }
            VStack(spacing: 10) {
                ForEach(tourItems, id: \.tab) { item in
                    tourRow(icon: item.icon, title: item.tab, body: item.body)
                }
            }
        }
        .padding(.horizontal, 28)
    }

    private func tourRow(icon: String, title: String, body: String) -> some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Theme.canvas)
                    .frame(width: 40, height: 40)
                    .overlay(Circle().strokeBorder(Theme.cocoaBorder, lineWidth: 1))
                Image(systemName: icon)
                    .font(.system(size: 17, weight: .light))
                    .foregroundStyle(Theme.terracotta)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.sans(15, weight: .semibold))
                    .foregroundStyle(Theme.cocoa)
                Text(body)
                    .font(.sans(13))
                    .foregroundStyle(Theme.cocoaMuted)
            }
            Spacer(minLength: 0)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Theme.cream)
                .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(Theme.cocoaBorder, lineWidth: 1))
        )
    }

    // MARK: - Reusable Components

    private func singleSelectPage(icon: String, question: String, hint: String, options: [String], selected: Binding<String>) -> some View {
        VStack(spacing: 20) {
            VStack(spacing: 12) {
                iconBubble(icon)
                VStack(spacing: 6) {
                    Text(question)
                        .font(.serifTitle(24, weight: .semibold))
                        .foregroundStyle(Theme.cocoa)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(hint)
                        .font(.sans(14))
                        .foregroundStyle(Theme.cocoaMuted)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            VStack(spacing: 10) {
                ForEach(options, id: \.self) { option in
                    let isSelected = selected.wrappedValue == option
                    Button {
                        UISelectionFeedbackGenerator().selectionChanged()
                        selected.wrappedValue = option
                    } label: {
                        HStack {
                            Text(option)
                                .font(.sans(15))
                                .foregroundStyle(isSelected ? Theme.cream : Theme.cocoa)
                            Spacer()
                            if isSelected {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundStyle(Theme.cream)
                            }
                        }
                        .padding(.horizontal, 20)
                        .frame(height: 52)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(isSelected ? Theme.terracotta : Theme.cream)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .strokeBorder(isSelected ? Theme.terracotta : Theme.cocoaBorder, lineWidth: 1)
                                )
                        )
                    }
                    .buttonStyle(.plain)
                    .animation(.spring(duration: 0.2), value: isSelected)
                }
            }
        }
        .padding(.horizontal, 28)
    }

    private func multiSelectPage(icon: String, question: String, hint: String, options: [String], selected: Binding<Set<String>>) -> some View {
        VStack(spacing: 20) {
            VStack(spacing: 12) {
                iconBubble(icon)
                VStack(spacing: 6) {
                    Text(question)
                        .font(.serifTitle(24, weight: .semibold))
                        .foregroundStyle(Theme.cocoa)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(hint)
                        .font(.sans(14))
                        .foregroundStyle(Theme.cocoaMuted)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            VStack(spacing: 10) {
                ForEach(stride(from: 0, to: options.count, by: 2).map { $0 }, id: \.self) { i in
                    HStack(spacing: 10) {
                        chipButton(option: options[i], selected: selected)
                        if i + 1 < options.count {
                            chipButton(option: options[i + 1], selected: selected)
                        } else {
                            Spacer().frame(maxWidth: .infinity)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 28)
    }

    private func chipButton(option: String, selected: Binding<Set<String>>) -> some View {
        let isSelected = selected.wrappedValue.contains(option)
        return Button {
            UISelectionFeedbackGenerator().selectionChanged()
            if isSelected {
                selected.wrappedValue.remove(option)
            } else {
                selected.wrappedValue.insert(option)
            }
        } label: {
            Text(option)
                .font(.sans(13))
                .foregroundStyle(isSelected ? Theme.cream : Theme.cocoa)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
                .padding(.horizontal, 12)
                .padding(.vertical, 14)
                .frame(maxWidth: .infinity, minHeight: 52)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(isSelected ? Theme.terracotta : Theme.cream)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .strokeBorder(isSelected ? Theme.terracotta : Theme.cocoaBorder, lineWidth: 1)
                        )
                )
        }
        .buttonStyle(.plain)
        .animation(.spring(duration: 0.2), value: isSelected)
    }

    private func iconBubble(_ name: String) -> some View {
        ZStack {
            Circle()
                .fill(Theme.cream)
                .frame(width: 80, height: 80)
                .overlay(Circle().strokeBorder(Theme.cocoaBorder, lineWidth: 1))
            Image(systemName: name)
                .font(.system(size: 32, weight: .light))
                .foregroundStyle(Theme.terracotta)
        }
    }
}

#Preview {
    OnboardingView(isShowing: .constant(true))
}
