import SwiftUI

struct ResourceDetailView: View {
    let resource: Resource
    @Environment(SavedStore.self) private var saved
    @Environment(GamificationStore.self) private var gamification
    @State private var showingCompletionFollowUp = false
    @State private var showingCompletionConfirmation = false
    @State private var completionAwardedPoints = true

    var body: some View {
        ZStack {
            Theme.canvas.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    header
                    infoGrid.padding(.top, 24)
                    description.padding(.top, 24)
                    goodToKnow.padding(.top, 16)
                    Color.clear.frame(height: 130)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
            }
            VStack {
                Spacer()
                actionBar
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Theme.canvas, for: .navigationBar)
        .overlay(alignment: .top) {
            if showingCompletionConfirmation {
                completionConfirmationToast
                    .padding(.top, 12)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.spring(duration: 0.3), value: showingCompletionConfirmation)
        .sheet(isPresented: $showingCompletionFollowUp) {
            ActivityFollowUpSheet { answer in
                showingCompletionFollowUp = false
                completionAwardedPoints = gamification.completeActivity(
                    resourceID: resource.id,
                    title: resource.name,
                    followUp: answer
                )
                showingCompletionConfirmation = true
                Task {
                    try? await Task.sleep(for: .seconds(2.5))
                    showingCompletionConfirmation = false
                }
            }
            .presentationDetents([.medium])
        }
    }

    private var completionConfirmationToast: some View {
        HStack(spacing: 10) {
            Image(systemName: "leaf.fill")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Theme.sage)
            Text(completionAwardedPoints ? "+10 points · Glad you made time for this" : "Logged — thanks for checking in")
                .font(.sans(13, weight: .semibold))
                .foregroundStyle(Theme.cocoa)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Theme.cream)
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(Theme.cocoaBorder, lineWidth: 1)
                )
        )
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(resource.name)
                .font(.serifTitle(28, weight: .semibold))
                .foregroundStyle(Theme.cocoa)
            Text(resource.category.rawValue.uppercased())
                .font(.sans(12, weight: .semibold))
                .tracking(0.6)
                .foregroundStyle(Theme.cocoaMuted)
                .padding(.top, 4)
            Text(resource.distanceText + " • " + resource.neighborhood)
                .font(.sans(14))
                .foregroundStyle(Theme.cocoaMuted)
                .padding(.top, 4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var infoGrid: some View {
        VStack(spacing: 0) {
            infoRow(icon: "dollarsign.circle", label: "Cost", value: resource.cost.rawValue)
            divider
            infoRow(icon: "clock", label: "Schedule", value: resource.schedule.displayText)
            divider
            infoRow(icon: "mappin", label: "Location", value: resource.address)
            divider
            infoRow(icon: "phone", label: "Contact", value: resource.contact)
        }
        .padding(.horizontal, 14)
        .background(RoundedRectangle(cornerRadius: 12).fill(Theme.cream))
        .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(Theme.cocoaBorder, lineWidth: 1))
    }

    private func infoRow(icon: String, label: String, value: String) -> some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(Theme.cocoaMuted)
                .frame(width: 18)
            Text(label.uppercased())
                .font(.sans(11, weight: .semibold))
                .tracking(0.6)
                .foregroundStyle(Theme.cocoaMuted)
                .frame(width: 80, alignment: .leading)
            Text(value)
                .font(.sans(15))
                .foregroundStyle(Theme.cocoa)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .multilineTextAlignment(.trailing)
        }
        .frame(minHeight: 44)
    }

    private var divider: some View {
        Rectangle().fill(Theme.cocoaBorder).frame(height: 1)
    }

    private var description: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("About")
                .font(.serifTitle(18, weight: .semibold))
                .foregroundStyle(Theme.cocoa)
            Text(resource.longDescription)
                .font(.sans(15))
                .foregroundStyle(Theme.cocoa)
                .lineSpacing(6)
        }
    }

    private var goodToKnow: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Good to know")
                .font(.serifTitle(18, weight: .semibold))
                .foregroundStyle(Theme.cocoa)
            VStack(alignment: .leading, spacing: 6) {
                ForEach(resource.goodToKnow, id: \.self) { item in
                    HStack(alignment: .top, spacing: 8) {
                        Text("—").foregroundStyle(Theme.cocoaMuted)
                        Text(item)
                            .font(.sans(14))
                            .foregroundStyle(Theme.cocoa)
                    }
                }
            }
        }
    }

    private var shareText: String {
        var parts = [resource.name, resource.shortDescription]
        if resource.hasPhysicalAddress { parts.append(resource.address) }
        if !resource.contact.isEmpty { parts.append(resource.contact) }
        return parts.joined(separator: "\n")
    }

    private var actionBar: some View {
        VStack(spacing: 8) {
            if resource.category != .crisisSupport {
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    showingCompletionFollowUp = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Mark as done")
                            .font(.sans(15, weight: .semibold))
                    }
                    .foregroundStyle(Theme.cream)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(Capsule().fill(Theme.sage))
                }
                .buttonStyle(.plain)
            }

            if resource.hasPhysicalAddress {
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    if let encoded = resource.address
                        .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                       let url = URL(string: "maps://?q=\(encoded)") {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    Text("Get directions")
                        .font(.sans(15, weight: .semibold))
                        .foregroundStyle(Theme.cream)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(Capsule().fill(Theme.terracotta))
                }
                .buttonStyle(.plain)
            }
            let isSaved = saved.isSaved(resource)
            Button {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                withAnimation(.easeInOut(duration: 0.15)) { saved.toggle(resource) }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: isSaved ? "bookmark.fill" : "bookmark")
                        .font(.system(size: 14, weight: .semibold))
                    Text(isSaved ? "Saved" : "Save for later")
                        .font(.sans(15, weight: .semibold))
                }
                .foregroundStyle(isSaved ? Theme.cream : Theme.cocoa)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(Capsule().fill(isSaved ? Theme.sage : Theme.cream))
                .overlay(Capsule().strokeBorder(isSaved ? Color.clear : Theme.cocoa, lineWidth: 2))
            }
            .buttonStyle(.plain)
            ShareLink(item: shareText) {
                HStack(spacing: 8) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 14, weight: .semibold))
                    Text("Share")
                        .font(.sans(15, weight: .semibold))
                }
                .foregroundStyle(Theme.cocoa)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(Capsule().fill(Theme.cream))
                .overlay(Capsule().strokeBorder(Theme.cocoaBorder, lineWidth: 2))
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 8)
        .background(Theme.canvas)
    }
}

#Preview {
    NavigationStack { ResourceDetailView(resource: SampleData.resources[1]) }
        .environment(SavedStore())
        .environment(GamificationStore())
}
