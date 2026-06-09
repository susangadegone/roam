import SwiftUI

enum Theme {
    // Core palette
    static let terracotta = Color(red: 0xD4/255, green: 0x81/255, blue: 0x6E/255)
    static let cream = Color(red: 0xF5/255, green: 0xF1/255, blue: 0xE8/255)
    static let creamDeep = Color(red: 0xEE/255, green: 0xE8/255, blue: 0xDA/255)
    static let cocoa = Color(red: 0x4A/255, green: 0x39/255, blue: 0x33/255)
    static let sage = Color(red: 0x8B/255, green: 0x9D/255, blue: 0x83/255)

    // Backgrounds
    static let canvas = Color(red: 0xFA/255, green: 0xF7/255, blue: 0xF0/255)

    // Opacities
    static var cocoaMuted: Color { cocoa.opacity(0.6) }
    static var cocoaBorder: Color { cocoa.opacity(0.20) }
    static var cocoaTapState: Color { cocoa.opacity(0.05) }
}

// MARK: - Typography
extension Font {
    static func serifTitle(_ size: CGFloat, weight: Font.Weight = .semibold) -> Font {
        .system(size: size, weight: weight, design: .serif)
    }
    static func sans(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .default)
    }
}

// MARK: - Linen texture overlay
struct LinenOverlay: View {
    var opacity: Double = 0.06
    var body: some View {
        Canvas { context, size in
            // Subtle paper-grain noise via short crossing strokes
            let cols = Int(size.width / 6)
            let rows = Int(size.height / 6)
            for r in 0...rows {
                for c in 0...cols {
                    let x = CGFloat(c) * 6 + CGFloat((c &+ r) % 3)
                    let y = CGFloat(r) * 6 + CGFloat((r &+ c) % 2)
                    let rect = CGRect(x: x, y: y, width: 1, height: 1)
                    let alpha = (Double((c &* 31 &+ r &* 17) % 100) / 100.0) * opacity
                    context.fill(Path(rect), with: .color(Theme.cocoa.opacity(alpha)))
                }
            }
        }
        .allowsHitTesting(false)
    }
}

// MARK: - Card surface
struct PaperCard<Content: View>: View {
    var stripeColor: Color
    @ViewBuilder var content: () -> Content

    var body: some View {
        HStack(spacing: 0) {
            Rectangle()
                .fill(stripeColor)
                .frame(width: 4)
            content()
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(
            ZStack {
                Theme.cream
                LinenOverlay(opacity: 0.05)
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(Theme.cocoaBorder, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.06), radius: 2, x: 0, y: 1)
    }
}
