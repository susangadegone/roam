import SwiftUI

enum ResourceCategory: String, CaseIterable, Identifiable, Hashable {
    case events = "Events"
    case fitness = "Fitness & movement"
    case creative = "Creative & art"
    case social = "Social & community"
    case learning = "Learning"
    case quiet = "Quiet spaces"
    case healthcare = "Health Center"
    case peer = "Peer Support"
    case counseling = "Counseling"
    case publicHealth = "Public Health"
    case youthHealth = "Youth Health"
    case libraryProgram = "Library Program"
    case libraryEvent = "Library Event"
    case meditation = "Meditation"
    case movement = "Movement"
    case soundHealing = "Sound Healing"
    case communityEvent = "Community Event"
    case resource = "Resource"
    case community = "Community"
    case seniorWellness = "Senior Wellness"
    case natureWellness = "Nature/Wellness"
    case talks = "Talks"
    case talksCulture = "Talks/Culture"
    case crisisSupport = "Crisis Support"

    var id: String { rawValue }

    var stripe: Color {
        switch self {
        case .events, .communityEvent, .libraryEvent:
            return Color(red: 0xE8/255, green: 0xB4/255, blue: 0x6E/255) // amber
        case .creative, .crisisSupport:
            return Theme.terracotta
        default:
            return Theme.sage
        }
    }
}

struct CostTier: Hashable {
    let rawValue: String
    var isFree: Bool { rawValue.lowercased().hasPrefix("free") }

    static let free = CostTier(rawValue: "Free")
    static let lowCost = CostTier(rawValue: "Low-cost")
    static let slidingScale = CostTier(rawValue: "Sliding scale")
}

enum ResourceArea: String, CaseIterable, Identifiable, Hashable {
    case sf = "San Francisco"
    case eastBay = "East Bay"

    var id: String { rawValue }
}

enum AccessKind: String, Hashable {
    case dropIn = "Drop-in"
    case ongoing = "Ongoing program"
    case crisis = "Crisis"
    case appointment = "By appointment"
    case publicAccess = "Public"
    case variousAccess = "Various Access Options"
    case rsvp = "RSVP"
}

struct Schedule: Hashable {
    var summary: String?
    var displayText: String { summary ?? "Check site for times" }
}

struct Resource: Identifiable, Hashable {
    let id: String           // stable slug, e.g. "dolores-park-yoga"
    let name: String
    let category: ResourceCategory
    let area: ResourceArea?
    let cost: CostTier
    let access: AccessKind
    let distanceMiles: Double
    let neighborhood: String
    let address: String
    let contact: String
    let shortDescription: String
    let longDescription: String
    let goodToKnow: [String]
    var schedule: Schedule = Schedule(summary: nil)
    var latitude: Double? = nil
    var longitude: Double? = nil

    var distanceText: String { String(format: "%.1f mi", distanceMiles) }
    var hasCoordinates: Bool { latitude != nil && longitude != nil }

    // False for resources with no single physical location (e.g. "Various parks")
    var hasPhysicalAddress: Bool {
        let lower = address.lowercased()
        return !lower.contains("various") && !lower.contains("branch location")
    }
}
