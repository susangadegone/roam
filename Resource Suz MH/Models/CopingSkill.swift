import SwiftUI

/// Categories mirror the mood check-in's "what sounds good right now" answers,
/// so a check-in response can directly surface matching coping skills.
enum CopingCategory: String, CaseIterable, Identifiable, Hashable {
    case calming = "Something calming"
    case outside = "Getting outside"
    case social = "Connecting with others"
    case quiet = "Quiet time alone"
    case exploring = "Just exploring"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .calming:   return "wind"
        case .outside:   return "leaf"
        case .social:    return "message"
        case .quiet:     return "book"
        case .exploring: return "map"
        }
    }
}

/// A self-guided activity or coping skill the user can do on their own,
/// at home or out and about, without needing to travel to a resource.
struct CopingSkill: Identifiable, Hashable {
    let id: String
    let title: String
    let category: CopingCategory
    let icon: String
    let estimatedMinutes: Int
    let summary: String
    let steps: [String]
}

extension CopingSkill {
    static let all: [CopingSkill] = [
        CopingSkill(
            id: "breathing-4-7-8",
            title: "4-7-8 breathing",
            category: .calming,
            icon: "wind",
            estimatedMinutes: 3,
            summary: "A slow breathing pattern that helps calm your nervous system.",
            steps: [
                "Get comfortable, sitting or lying down.",
                "Breathe in quietly through your nose for 4 seconds.",
                "Hold your breath for 7 seconds.",
                "Exhale slowly through your mouth for 8 seconds.",
                "Repeat 4 times.",
            ]
        ),
        CopingSkill(
            id: "body-scan",
            title: "Body scan",
            category: .calming,
            icon: "figure.mind.and.body",
            estimatedMinutes: 5,
            summary: "Notice and release tension, one part of your body at a time.",
            steps: [
                "Sit or lie down somewhere comfortable.",
                "Close your eyes and take a few slow breaths.",
                "Bring attention to your feet, then slowly move up through your legs, stomach, chest, arms, and head.",
                "At each spot, notice any tension and let it soften as you exhale.",
            ]
        ),
        CopingSkill(
            id: "5-4-3-2-1-grounding",
            title: "5-4-3-2-1 grounding",
            category: .calming,
            icon: "eye",
            estimatedMinutes: 3,
            summary: "Use your senses to settle into the present moment.",
            steps: [
                "Name 5 things you can see.",
                "Name 4 things you can feel/touch.",
                "Name 3 things you can hear.",
                "Name 2 things you can smell.",
                "Name 1 thing you can taste.",
            ]
        ),
        CopingSkill(
            id: "walk-the-block",
            title: "Walk around the block",
            category: .outside,
            icon: "figure.walk",
            estimatedMinutes: 10,
            summary: "A short walk to shift your environment and get moving.",
            steps: [
                "Step outside, no destination needed.",
                "Walk at an easy pace for 10 minutes or so.",
                "Notice a few things along the way — colors, sounds, smells.",
            ]
        ),
        CopingSkill(
            id: "sit-in-a-park",
            title: "Sit in a park",
            category: .outside,
            icon: "tree",
            estimatedMinutes: 15,
            summary: "Find a bench or patch of grass and just be outside for a while.",
            steps: [
                "Find a nearby park, plaza, or green space.",
                "Sit somewhere comfortable — bring a book, music, or just yourself.",
                "Let yourself stay for at least 15 minutes without rushing.",
            ]
        ),
        CopingSkill(
            id: "cloud-watching",
            title: "Watch the sky",
            category: .outside,
            icon: "cloud",
            estimatedMinutes: 10,
            summary: "Slow down and watch the clouds, sunset, or stars for a bit.",
            steps: [
                "Find a spot where you can see the sky — a yard, rooftop, or open street.",
                "Get comfortable and look up.",
                "Just watch for a few minutes — no goal, just noticing.",
            ]
        ),
        CopingSkill(
            id: "text-a-friend",
            title: "Text a friend",
            category: .social,
            icon: "message",
            estimatedMinutes: 5,
            summary: "A small check-in can go a long way for both of you.",
            steps: [
                "Think of someone you haven't talked to in a bit.",
                "Send a short message — a hello, a memory, or how you're doing.",
                "No pressure for a long conversation, just an open door.",
            ]
        ),
        CopingSkill(
            id: "give-a-compliment",
            title: "Give a genuine compliment",
            category: .social,
            icon: "hand.thumbsup",
            estimatedMinutes: 2,
            summary: "Brighten someone's day — and yours — with a small kind word.",
            steps: [
                "Think of someone nearby or someone you're in touch with.",
                "Notice something genuine you appreciate about them.",
                "Say or send it — keep it simple and specific.",
            ]
        ),
        CopingSkill(
            id: "journal-it-out",
            title: "Journal it out",
            category: .quiet,
            icon: "pencil.and.scribble",
            estimatedMinutes: 10,
            summary: "Write freely about what's on your mind — no editing needed.",
            steps: [
                "Find a quiet spot with a notebook, notes app, or scrap paper.",
                "Set a timer for 10 minutes.",
                "Write whatever comes to mind — thoughts, feelings, or a prompt like \"Right now I feel...\"",
                "Don't worry about grammar or making sense — just let it out.",
            ]
        ),
        CopingSkill(
            id: "read-for-a-bit",
            title: "Read for a bit",
            category: .quiet,
            icon: "book",
            estimatedMinutes: 15,
            summary: "Lose yourself in a book, article, or comic for a while.",
            steps: [
                "Pick something you're currently reading, or grab something new.",
                "Find a comfortable, quiet spot — inside or out.",
                "Read for at least 15 minutes, just for yourself.",
            ]
        ),
        CopingSkill(
            id: "doodle-or-sketch",
            title: "Doodle or sketch",
            category: .quiet,
            icon: "scribble.variable",
            estimatedMinutes: 10,
            summary: "Draw without pressure — patterns, objects, or whatever comes out.",
            steps: [
                "Grab any paper and a pen or pencil.",
                "Draw whatever's nearby, a pattern, or just let your hand wander.",
                "There's no right way to do this — it's just for you.",
            ]
        ),
        CopingSkill(
            id: "explore-a-new-spot",
            title: "Explore a new spot nearby",
            category: .exploring,
            icon: "map",
            estimatedMinutes: 20,
            summary: "Visit somewhere close by that you haven't been before.",
            steps: [
                "Think of a street, park, café, or shop near you that you've never checked out.",
                "Head over with no real agenda.",
                "Take it in — you might find a new favorite spot.",
            ]
        ),
        CopingSkill(
            id: "try-something-new",
            title: "Try something new",
            category: .exploring,
            icon: "sparkles",
            estimatedMinutes: 15,
            summary: "A small new experience can shift your whole day.",
            steps: [
                "Pick one small thing you haven't tried — a new drink, route, song, or recipe.",
                "Give it a go, even if it feels minor.",
                "Notice how it felt afterward.",
            ]
        ),
    ]
}
