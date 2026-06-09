import SwiftUI

struct ResourceCard: View {
    let resource: Resource
    var onTap: () -> Void = {}

    @State private var pressed = false

    var body: some View {
        Button(action: {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            onTap()
        }) {
            PaperCard(stripeColor: resource.category.stripe) {
                VStack(alignment: .leading, spacing: 0) {
                    topRow
                    secondRow.padding(.top, 8)
                    Text(resource.shortDescription)
                        .font(.sans(14))
                        .foregroundStyle(Theme.cocoa)
                        .lineLimit(2)
                        .padding(.top, 4)
                    scheduleRow.padding(.top, 4)
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .fill(pressed ? Theme.cocoaTapState : .clear)
            )
        }
        .buttonStyle(.plain)
        .frame(minHeight: 44)
        .onLongPressGesture(minimumDuration: 0, pressing: { pressed = $0 }, perform: {})
    }

    private var topRow: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text(resource.name)
                .font(.serifTitle(18, weight: .semibold))
                .foregroundStyle(Theme.cocoa)
                .lineLimit(2)
            Spacer(minLength: 8)
            costPill
        }
    }

    private var secondRow: some View {
        HStack(spacing: 6) {
            Text(resource.category.rawValue.uppercased())
                .font(.sans(11, weight: .semibold))
                .tracking(0.6)
                .foregroundStyle(Theme.cocoaMuted)
            Text("•").foregroundStyle(Theme.cocoaMuted)
            Text(resource.distanceText)
                .font(.sans(12))
                .foregroundStyle(Theme.cocoaMuted)
            if resource.access == .dropIn {
                Text("•").foregroundStyle(Theme.cocoaMuted)
                Text("Drop-in")
                    .font(.sans(11, weight: .medium))
                    .foregroundStyle(Theme.sage)
            }
        }
    }

    private var scheduleRow: some View {
        HStack(spacing: 6) {
            Image(systemName: "clock")
                .font(.system(size: 11, weight: .regular))
                .foregroundStyle(Theme.cocoaMuted)
            Text(resource.schedule.displayText)
                .font(.sans(12))
                .foregroundStyle(Theme.cocoaMuted)
        }
    }

    @ViewBuilder
    private var costPill: some View {
        let isFree = resource.cost.isFree
        Text(resource.cost.rawValue)
            .font(.sans(10, weight: .semibold))
            .tracking(0.4)
            .foregroundStyle(isFree ? Theme.cream : Theme.cocoa)
            .padding(.vertical, 6)
            .padding(.horizontal, 12)
            .background(
                Capsule(style: .continuous)
                    .fill(isFree ? Theme.sage : Color.clear)
            )
            .overlay(
                Capsule(style: .continuous)
                    .strokeBorder(isFree ? Color.clear : Theme.cocoa.opacity(0.5), lineWidth: 1)
            )
            .fixedSize()
    }
}
