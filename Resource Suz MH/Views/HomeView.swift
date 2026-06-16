import SwiftUI

struct HomeView: View {
    @Environment(ResourceStore.self) private var store
    @Environment(GamificationStore.self) private var gamification
    @Environment(TabSelection.self) private var tabSelection
    @Environment(PlanStore.self) private var plan
    @AppStorage("pref_area") private var prefArea = ""
    @AppStorage("pref_cost") private var prefCost = ""
    @AppStorage("pref_interests") private var prefInterests = ""
    @AppStorage("pref_access") private var prefAccess = ""
    @AppStorage("pref_distance") private var prefDistance = ""
    @State private var query: String = ""
    @State private var freeOnly: Bool = false
    @State private var selectedCategory: ResourceCategory? = nil
    @State private var selectedArea: ResourceArea? = nil
    @State private var selectedResource: Resource? = nil
    @State private var selectedCopingSkill: CopingSkill? = nil
    @State private var showingCrisis: Bool = false
    @State private var showingHowToUse: Bool = false
    @State private var showingPlanPicker: Bool = false
    @State private var showingFilters: Bool = false

    private var preferredCategories: Set<ResourceCategory> {
        Set(prefInterests.split(separator: ",").compactMap { ResourceCategory(rawValue: String($0)) })
    }

    private static let checkInCategoryMap: [String: [ResourceCategory]] = [
        "Something calming": [.meditation, .soundHealing, .quiet],
        "Getting outside": [.natureWellness, .movement, .fitness],
        "Connecting with others": [.social, .community, .communityEvent, .events, .peer],
        "Quiet time alone": [.quiet, .libraryProgram, .meditation],
        "Just exploring": [],
    ]

    private var checkInCategories: Set<ResourceCategory> {
        Set(Self.checkInCategoryMap[gamification.lastCheckInFollowUp] ?? [])
    }

    private var allPreferredCategories: Set<ResourceCategory> {
        preferredCategories.union(checkInCategories)
    }

    private var maxDistanceMiles: Double? {
        switch prefDistance {
        case "Close to home":        return 1.5
        case "A short trip is fine": return 5.0
        default:                     return nil
        }
    }

    private func accessScore(_ r: Resource) -> Int {
        switch prefAccess {
        case "Solo, on my own terms":
            return (r.access == .dropIn || r.access == .publicAccess) ? 0 : 1
        case "Open to being around others":
            return (r.access == .ongoing || r.access == .rsvp) ? 0 : 1
        default:
            return 0
        }
    }

    private var filtered: [Resource] {
        let base = store.resources.filter { r in
            (!freeOnly || r.cost.isFree)
            && (selectedCategory == nil || r.category == selectedCategory)
            && (selectedArea == nil || r.area == selectedArea)
            && (maxDistanceMiles.map { r.distanceMiles <= $0 } ?? true)
            && (query.isEmpty
                || r.name.localizedCaseInsensitiveContains(query)
                || r.shortDescription.localizedCaseInsensitiveContains(query)
                || r.neighborhood.localizedCaseInsensitiveContains(query)
                || r.category.rawValue.localizedCaseInsensitiveContains(query))
        }
        let preferred = allPreferredCategories
        guard !preferred.isEmpty || !prefAccess.isEmpty else { return base }
        return base.sorted { a, b in
            let aInterest = preferred.contains(a.category) ? 0 : 1
            let bInterest = preferred.contains(b.category) ? 0 : 1
            if aInterest != bInterest { return aInterest < bInterest }
            return accessScore(a) < accessScore(b)
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.canvas.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        header.padding(.top, 4)
                        todaySection.padding(.top, 12)
                        if store.hasFetchError {
                            fetchErrorBanner.padding(.top, 12)
                        }
                        searchAndFilters.padding(.top, 16)
                        nearYouSection.padding(.top, 24)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                }
                .scrollDismissesKeyboard(.immediately)
                .refreshable { await store.refresh() }
            }
            .navigationDestination(item: $selectedResource) { r in
                ResourceDetailView(resource: r)
            }
            .navigationDestination(item: $selectedCopingSkill) { skill in
                CopingSkillDetailView(skill: skill)
            }
            .sheet(isPresented: $showingCrisis) {
                CrisisSheet().presentationDetents([.medium, .large])
            }
            .sheet(isPresented: $showingHowToUse) {
                NavigationStack { HowToUseView() }
            }
            .sheet(isPresented: $showingPlanPicker) {
                PlanPickerView()
            }
            .onAppear {
                if selectedArea == nil && selectedCategory == nil && !freeOnly {
                    if prefArea == "San Francisco" { selectedArea = .sf }
                    else if prefArea == "East Bay" { selectedArea = .eastBay }
                    if prefCost == "Free only" { freeOnly = true }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 4) {
                        Button {
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            showingCrisis = true
                        } label: {
                            Image(systemName: "phone.circle")
                                .font(.system(size: 20, weight: .regular))
                                .foregroundStyle(Theme.terracotta)
                        }
                        Button {
                            showingHowToUse = true
                        } label: {
                            Image(systemName: "info.circle")
                                .font(.system(size: 17, weight: .regular))
                                .foregroundStyle(Theme.cocoa)
                        }
                    }
                }
            }
        }
    }

    private var fetchErrorBanner: some View {
        HStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Theme.terracotta)
            Text("Couldn't load live data. Showing sample resources.")
                .font(.sans(13))
                .foregroundStyle(Theme.cocoa)
            Spacer()
            Button {
                Task { await store.refresh() }
            } label: {
                Text("Retry")
                    .font(.sans(13, weight: .semibold))
                    .foregroundStyle(Theme.terracotta)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(RoundedRectangle(cornerRadius: 10).fill(Theme.cream))
        .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(Theme.terracotta.opacity(0.3), lineWidth: 1))
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("roam")
                .font(.serifTitle(28, weight: .semibold))
                .foregroundStyle(Theme.cocoa)
            Text("Small steps, every day. Find what fits your energy today.")
                .font(.sans(13))
                .foregroundStyle(Theme.cocoaMuted)
                .lineSpacing(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    /// Combines the "plan your day" / today's plan checklist with a quick link
    /// into the Coping tab, so the top of Home only has a single card for "today".
    private var todaySection: some View {
        PaperCard(stripeColor: Theme.terracotta) {
            VStack(alignment: .leading, spacing: 12) {
                if plan.plannedSkills.isEmpty {
                    Button {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        showingPlanPicker = true
                    } label: {
                        HStack(spacing: 14) {
                            Image(systemName: "list.bullet.clipboard")
                                .font(.system(size: 18, weight: .light))
                                .foregroundStyle(Theme.terracotta)
                                .frame(width: 28)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Things to try today")
                                    .font(.serifTitle(16, weight: .semibold))
                                    .foregroundStyle(Theme.cocoa)
                                Text("Pick a few coping skills to come back to anytime today.")
                                    .font(.sans(13))
                                    .foregroundStyle(Theme.cocoaMuted)
                            }
                            Spacer(minLength: 8)
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(Theme.cocoaMuted)
                        }
                    }
                    .buttonStyle(.plain)
                } else {
                    HStack {
                        Text("Things to try today")
                            .font(.serifTitle(16, weight: .semibold))
                            .foregroundStyle(Theme.cocoa)
                        Spacer()
                        Button {
                            showingPlanPicker = true
                        } label: {
                            Text("Edit")
                                .font(.sans(13, weight: .semibold))
                                .foregroundStyle(Theme.terracotta)
                        }
                    }
                    VStack(spacing: 10) {
                        ForEach(plan.plannedSkills) { skill in
                            PlanItemRow(
                                skill: skill,
                                isCompleted: plan.isCompleted(skill.id),
                                onToggle: {
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                    plan.toggleCompletion(skill.id)
                                    if plan.isCompleted(skill.id) {
                                        gamification.completeActivity(
                                            resourceID: "plan-\(skill.id)",
                                            title: skill.title,
                                            followUp: skill.category.rawValue
                                        )
                                    }
                                },
                                onTap: { selectedCopingSkill = skill }
                            )
                        }
                    }
                }

                Divider().overlay(Theme.cocoaBorder)

                Button {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    tabSelection.selection = .coping
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(Theme.sage)
                        Text("Need something to try right now?")
                            .font(.sans(13, weight: .medium))
                            .foregroundStyle(Theme.cocoa)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(Theme.cocoaMuted)
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 15, weight: .regular))
                .foregroundStyle(Theme.cocoaMuted)
            TextField("free yoga near me", text: $query)
                .font(.sans(15))
                .foregroundStyle(Theme.cocoa)
                .tint(Theme.terracotta)
                .submitLabel(.search)
            if !query.isEmpty {
                Button {
                    query = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Theme.cocoaMuted)
                }
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 48)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Theme.cream)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(Theme.cocoaBorder, lineWidth: 1)
        )
    }

    private var activeFilterCount: Int {
        (freeOnly ? 1 : 0) + (selectedCategory == nil ? 0 : 1) + (selectedArea == nil ? 0 : 1)
    }

    /// Search and filters live together as one group, since filtering is just
    /// a more specific way of searching.
    private var searchAndFilters: some View {
        VStack(alignment: .leading, spacing: 10) {
            searchBar
            filtersSection
        }
    }

    private var filtersSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                withAnimation(.easeInOut(duration: 0.2)) { showingFilters.toggle() }
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: 14, weight: .medium))
                    Text(activeFilterCount == 0 ? "Filters" : "Filters · \(activeFilterCount) active")
                        .font(.sans(15, weight: .medium))
                    Spacer()
                    Image(systemName: showingFilters ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                }
                .foregroundStyle(Theme.cocoa)
                .padding(.horizontal, 16)
                .frame(height: 48)
                .frame(maxWidth: .infinity)
                .background(RoundedRectangle(cornerRadius: 8).fill(Theme.cream))
                .overlay(RoundedRectangle(cornerRadius: 8).strokeBorder(Theme.cocoaBorder, lineWidth: 1))
            }
            .buttonStyle(.plain)

            if showingFilters {
                VStack(alignment: .leading, spacing: 12) {
                    freeToggle
                    filterChips
                    areaChips
                }
            }
        }
    }

    private var freeToggle: some View {
        Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            withAnimation(.easeInOut(duration: 0.2)) { freeOnly.toggle() }
        } label: {
            HStack(spacing: 10) {
                Image(systemName: freeOnly ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 18, weight: .regular))
                Text("Show only free resources")
                    .font(.sans(15, weight: .medium))
                Spacer()
            }
            .foregroundStyle(freeOnly ? Theme.cream : Theme.cocoa)
            .padding(.horizontal, 16)
            .frame(height: 48)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(freeOnly ? Theme.sage : Theme.cream)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(freeOnly ? Color.clear : Theme.cocoaBorder, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterChip(label: "All", isSelected: selectedCategory == nil) {
                    selectedCategory = nil
                }
                ForEach(ResourceCategory.allCases) { cat in
                    FilterChip(label: cat.rawValue, isSelected: selectedCategory == cat) {
                        selectedCategory = (selectedCategory == cat) ? nil : cat
                    }
                }
            }
        }
        .scrollClipDisabled()
    }

    private var areaChips: some View {
        HStack(spacing: 8) {
            ForEach(ResourceArea.allCases) { area in
                FilterChip(label: area.rawValue, isSelected: selectedArea == area) {
                    selectedArea = (selectedArea == area) ? nil : area
                }
            }
        }
    }

    private var resultsHeader: some View {
        HStack(alignment: .firstTextBaseline) {
            Text("Near you")
                .font(.serifTitle(20, weight: .semibold))
                .foregroundStyle(Theme.cocoa)
            Spacer()
            if store.isLoading {
                ProgressView()
                    .scaleEffect(0.75)
                    .tint(Theme.cocoaMuted)
            } else {
                Text("\(filtered.count) result\(filtered.count == 1 ? "" : "s")")
                    .font(.sans(12))
                    .foregroundStyle(Theme.cocoaMuted)
            }
        }
    }

    private let nearYouPreviewCount = 4

    /// A short preview of nearby resources, with the full browsable list (plus
    /// the map) living on the Map tab so Home doesn't need to show everything.
    private var nearYouSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            resultsHeader
            if filtered.isEmpty {
                emptyState
            } else {
                VStack(spacing: 12) {
                    ForEach(filtered.prefix(nearYouPreviewCount)) { r in
                        ResourceCard(resource: r) { selectedResource = r }
                    }
                }
                seeAllButton
            }
        }
    }

    private var seeAllButton: some View {
        Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            tabSelection.selection = .map
        } label: {
            HStack(spacing: 6) {
                Text("See all on map")
                    .font(.sans(14, weight: .semibold))
                Image(systemName: "arrow.right")
                    .font(.system(size: 12, weight: .semibold))
            }
            .foregroundStyle(Theme.terracotta)
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background(RoundedRectangle(cornerRadius: 8).fill(Theme.cream))
            .overlay(RoundedRectangle(cornerRadius: 8).strokeBorder(Theme.cocoaBorder, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray")
                .font(.system(size: 28, weight: .light))
                .foregroundStyle(Theme.cocoaMuted)
            Text("No results found.")
                .font(.serifTitle(18, weight: .semibold))
                .foregroundStyle(Theme.cocoa)
            Text("Try adjusting filters or your search.")
                .font(.sans(14))
                .foregroundStyle(Theme.cocoaMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 48)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Theme.cream.opacity(0.6))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(Theme.cocoaBorder, lineWidth: 1)
        )
    }
}

private struct PlanItemRow: View {
    let skill: CopingSkill
    let isCompleted: Bool
    var onToggle: () -> Void
    var onTap: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            Button(action: onToggle) {
                Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22, weight: .regular))
                    .foregroundStyle(isCompleted ? Theme.sage : Theme.cocoaMuted)
            }
            .buttonStyle(.plain)
            .frame(width: 28)

            Button {
                onTap()
            } label: {
                HStack(spacing: 14) {
                    Image(systemName: skill.icon)
                        .font(.system(size: 16, weight: .light))
                        .foregroundStyle(Theme.sage)
                        .frame(width: 22)
                    Text(skill.title)
                        .font(.sans(15, weight: .medium))
                        .foregroundStyle(isCompleted ? Theme.cocoaMuted : Theme.cocoa)
                        .strikethrough(isCompleted)
                    Spacer(minLength: 8)
                    Text("\(skill.estimatedMinutes)m")
                        .font(.sans(12, weight: .semibold))
                        .foregroundStyle(Theme.cocoaMuted)
                }
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 14)
        .frame(height: 52)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Theme.cream)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Theme.cocoaBorder, lineWidth: 1)
                )
        )
        .animation(.spring(duration: 0.2), value: isCompleted)
    }
}

struct FilterChip: View {
    let label: String
    let isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            action()
        } label: {
            Text(label)
                .font(.sans(13, weight: .medium))
                .foregroundStyle(isSelected ? Theme.cream : Theme.cocoa)
                .padding(.vertical, 10)
                .padding(.horizontal, 16)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isSelected ? Theme.cocoa : Theme.cream)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(isSelected ? Color.clear : Theme.cocoaBorder, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
        .frame(minHeight: 44)
    }
}

struct CrisisSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Theme.canvas.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("Crisis support")
                        .font(.serifTitle(24, weight: .semibold))
                        .foregroundStyle(Theme.cocoa)
                    Spacer()
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Theme.cocoa)
                            .padding(8)
                            .background(Circle().fill(Theme.cream))
                    }
                }
                Text("If you're in immediate danger, call 911. Otherwise, these lines are free, confidential, and available now.")
                    .font(.sans(15))
                    .foregroundStyle(Theme.cocoa)
                    .lineSpacing(4)

                crisisRow(title: "988 Suicide & Crisis Lifeline", subtitle: "Call or text 988", icon: "phone", url: "tel://988")
                crisisRow(title: "Crisis Text Line", subtitle: "Text HOME to 741741", icon: "message", url: "sms://741741")
                crisisRow(title: "SF Warmline", subtitle: "(855) 845-7415 — non-emergency", icon: "phone", url: "tel://8558457415")

                Spacer()
            }
            .padding(20)
        }
    }

    private func crisisRow(title: String, subtitle: String, icon: String, url: String) -> some View {
        Link(destination: URL(string: url)!) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(Theme.terracotta)
                    .frame(width: 32, height: 32)
                    .background(Circle().fill(Theme.canvas))
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.sans(15, weight: .semibold))
                        .foregroundStyle(Theme.cocoa)
                    Text(subtitle)
                        .font(.sans(13))
                        .foregroundStyle(Theme.cocoaMuted)
                }
                Spacer()
                Image(systemName: "arrow.up.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Theme.cocoaMuted)
            }
            .padding(14)
            .background(RoundedRectangle(cornerRadius: 12).fill(Theme.cream))
            .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(Theme.cocoaBorder, lineWidth: 1))
        }
    }
}

#Preview { HomeView().environment(SavedStore()).environment(ResourceStore()).environment(GamificationStore()).environment(TabSelection()).environment(PlanStore()) }
