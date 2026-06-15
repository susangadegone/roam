import SwiftUI

/// A single point-earning moment, shown in the Profile "recent activity" history.
struct ActivityLogEntry: Codable, Identifiable, Hashable {
    let id: UUID
    let title: String
    let points: Int
    let date: Date

    init(id: UUID = UUID(), title: String, points: Int, date: Date = Date()) {
        self.id = id
        self.title = title
        self.points = points
        self.date = date
    }
}

/// Tracks points and daily check-in streaks. Surfaced only on the Profile tab.
@Observable
final class GamificationStore {
    private static let pointsKey = "totalPoints"
    private static let streakKey = "currentStreak"
    private static let lastActivityDateKey = "lastActivityDate"
    private static let lastCheckInFollowUpKey = "lastCheckInFollowUp"
    private static let historyKey = "activityHistory"
    private static let completionDatesKey = "activityCompletionDates"
    private static let maxHistory = 10

    private(set) var totalPoints: Int
    private(set) var currentStreak: Int
    private(set) var lastActivityDate: Date?
    private(set) var lastCheckInFollowUp: String
    private(set) var recentActivity: [ActivityLogEntry]
    private var lastCompletionDates: [String: Date]

    init() {
        let defaults = UserDefaults.standard
        totalPoints = defaults.integer(forKey: Self.pointsKey)
        currentStreak = defaults.integer(forKey: Self.streakKey)
        let timestamp = defaults.double(forKey: Self.lastActivityDateKey)
        lastActivityDate = timestamp > 0 ? Date(timeIntervalSince1970: timestamp) : nil
        lastCheckInFollowUp = defaults.string(forKey: Self.lastCheckInFollowUpKey) ?? ""
        if let data = defaults.data(forKey: Self.historyKey),
           let entries = try? JSONDecoder().decode([ActivityLogEntry].self, from: data) {
            recentActivity = entries
        } else {
            recentActivity = []
        }
        if let data = defaults.data(forKey: Self.completionDatesKey),
           let dates = try? JSONDecoder().decode([String: Date].self, from: data) {
            lastCompletionDates = dates
        } else {
            lastCompletionDates = [:]
        }
    }

    /// +5 points for completing the mood check-in (once per day), and updates the daily streak.
    @discardableResult
    func completeMoodCheckIn(followUp: String) -> Bool {
        let alreadyCheckedInToday = lastActivityDate.map { Calendar.current.isDateInToday($0) } ?? false
        lastCheckInFollowUp = followUp
        UserDefaults.standard.set(followUp, forKey: Self.lastCheckInFollowUpKey)
        updateStreak()
        guard !alreadyCheckedInToday else { return false }
        addPoints(5, title: "Mood check-in")
        return true
    }

    /// +10 points after the user answers the post-activity follow-up question, once per resource per day.
    @discardableResult
    func completeActivity(resourceID: String, title: String, followUp: String) -> Bool {
        if let last = lastCompletionDates[resourceID], Calendar.current.isDateInToday(last) {
            return false
        }
        lastCompletionDates[resourceID] = Date()
        if let data = try? JSONEncoder().encode(lastCompletionDates) {
            UserDefaults.standard.set(data, forKey: Self.completionDatesKey)
        }
        addPoints(10, title: title)
        return true
    }

    private func updateStreak() {
        let calendar = Calendar.current
        let now = Date()
        if let last = lastActivityDate {
            if calendar.isDateInToday(last) {
                // Already checked in today — streak unchanged.
            } else if calendar.isDateInYesterday(last) {
                currentStreak += 1
            } else {
                currentStreak = 1
            }
        } else {
            currentStreak = 1
        }
        lastActivityDate = now
        UserDefaults.standard.set(currentStreak, forKey: Self.streakKey)
        UserDefaults.standard.set(now.timeIntervalSince1970, forKey: Self.lastActivityDateKey)
    }

    private func addPoints(_ amount: Int, title: String) {
        totalPoints += amount
        UserDefaults.standard.set(totalPoints, forKey: Self.pointsKey)

        recentActivity.insert(ActivityLogEntry(title: title, points: amount), at: 0)
        if recentActivity.count > Self.maxHistory {
            recentActivity.removeLast(recentActivity.count - Self.maxHistory)
        }
        if let data = try? JSONEncoder().encode(recentActivity) {
            UserDefaults.standard.set(data, forKey: Self.historyKey)
        }
    }
}
