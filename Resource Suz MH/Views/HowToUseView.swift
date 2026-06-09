import SwiftUI

struct HowToUseView: View {
    var body: some View {
        ZStack {
            Theme.canvas.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 20) {
                    heroHeader
                    ForEach(steps) { step in
                        stepCard(step)
                    }
                    tipsCard
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 40)
            }
        }
        .navigationTitle("How to use Roam")
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(Theme.canvas, for: .navigationBar)
    }

    // MARK: - Hero

    private var heroHeader: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(Theme.cream)
                    .frame(width: 72, height: 72)
                    .overlay(Circle().strokeBorder(Theme.cocoaBorder, lineWidth: 1))
                Image(systemName: "leaf.fill")
                    .font(.system(size: 30, weight: .light))
                    .foregroundStyle(Theme.terracotta)
            }
            Text("Find what's good nearby")
                .font(.serifTitle(22, weight: .semibold))
                .foregroundStyle(Theme.cocoa)
            Text("Roam shows you free and low-cost activities across the SF Bay Area. No account, no sign-up.")
                .font(.sans(14))
                .foregroundStyle(Theme.cocoaMuted)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .padding(.horizontal, 8)
    }

    // MARK: - Steps

    private struct Step: Identifiable {
        let id = UUID()
        let icon: String
        let title: String
        let body: String
    }

    private let steps: [Step] = [
        Step(icon: "house",
             title: "Browse the Home tab",
             body: "Scroll through curated resources. Pull down to refresh for the latest listings from Airtable."),
        Step(icon: "line.3.horizontal.decrease.circle",
             title: "Filter by category or area",
             body: "Tap a chip — Events, Fitness, Creative, and more — to narrow results. Tap \"All\" to reset. Switch between San Francisco and East Bay with the area row."),
        Step(icon: "magnifyingglass",
             title: "Search by keyword",
             body: "Type anything in the search bar: a neighborhood, activity type, or resource name. Results update instantly."),
        Step(icon: "bookmark",
             title: "Save your favorites",
             body: "Tap the bookmark icon on any resource card or detail page to save it. Find everything saved under the Saved tab — no account needed."),
        Step(icon: "map",
             title: "See it on the map",
             body: "Switch to the Map tab to see all resources as pins. Tap a pin to preview the resource, then tap again to open the full detail."),
        Step(icon: "arrow.up.right",
             title: "Get directions",
             body: "Inside any resource detail, tap the address to open Maps and get turn-by-turn directions straight there.")
    ]

    private func stepCard(_ step: Step) -> some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                Circle()
                    .fill(Theme.cream)
                    .frame(width: 44, height: 44)
                    .overlay(Circle().strokeBorder(Theme.cocoaBorder, lineWidth: 1))
                Image(systemName: step.icon)
                    .font(.system(size: 18, weight: .light))
                    .foregroundStyle(Theme.terracotta)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(step.title)
                    .font(.sans(15, weight: .semibold))
                    .foregroundStyle(Theme.cocoa)
                Text(step.body)
                    .font(.sans(14))
                    .foregroundStyle(Theme.cocoaMuted)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Theme.cream)
                .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(Theme.cocoaBorder, lineWidth: 1))
        )
    }

    // MARK: - Tips

    private var tipsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: "lightbulb")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(Theme.cocoaMuted)
                Text("GOOD TO KNOW")
                    .font(.sans(11, weight: .semibold))
                    .tracking(0.6)
                    .foregroundStyle(Theme.cocoaMuted)
            }
            tipRow("Resources update live from Airtable — pull to refresh anytime.")
            tipRow("The Crisis support button is always one tap away from the Home tab.")
            tipRow("All data is free to browse — no account needed, no tracking.")
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Theme.cream)
                .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(Theme.cocoaBorder, lineWidth: 1))
        )
    }

    private func tipRow(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Circle()
                .fill(Theme.terracotta)
                .frame(width: 5, height: 5)
                .padding(.top, 6)
            Text(text)
                .font(.sans(14))
                .foregroundStyle(Theme.cocoa)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#Preview {
    NavigationStack {
        HowToUseView()
    }
}
