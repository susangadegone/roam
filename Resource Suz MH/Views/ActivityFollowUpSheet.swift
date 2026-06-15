import SwiftUI

/// Shown after "Mark as done" — a warm, low-stakes check on how the activity felt.
/// Points are only awarded once the user picks one of these options.
struct ActivityFollowUpSheet: View {
    var onAnswer: (String) -> Void

    private let options = ["A little better", "About the same", "I'm not sure"]

    var body: some View {
        ZStack {
            Theme.canvas.ignoresSafeArea()
            VStack(spacing: 24) {
                ZStack {
                    Circle()
                        .fill(Theme.cream)
                        .frame(width: 72, height: 72)
                        .overlay(Circle().strokeBorder(Theme.cocoaBorder, lineWidth: 1))
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 28, weight: .light))
                        .foregroundStyle(Theme.sage)
                }
                .padding(.top, 40)

                VStack(spacing: 6) {
                    Text("Nice work")
                        .font(.serifTitle(22, weight: .semibold))
                        .foregroundStyle(Theme.cocoa)
                    Text("How do you feel compared to before?")
                        .font(.sans(15))
                        .foregroundStyle(Theme.cocoaMuted)
                        .multilineTextAlignment(.center)
                }

                VStack(spacing: 10) {
                    ForEach(options, id: \.self) { option in
                        Button {
                            UISelectionFeedbackGenerator().selectionChanged()
                            onAnswer(option)
                        } label: {
                            Text(option)
                                .font(.sans(15, weight: .medium))
                                .foregroundStyle(Theme.cocoa)
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Theme.cream)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .strokeBorder(Theme.cocoaBorder, lineWidth: 1)
                                        )
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 28)

                Spacer()
            }
        }
    }
}
