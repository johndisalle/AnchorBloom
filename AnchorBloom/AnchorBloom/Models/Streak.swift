import Foundation
import FirebaseFirestore

// MARK: - Streak Model
/// Tracks user consistency and daily completion
struct Streak: Codable {
    var currentStreak: Int
    var longestStreak: Int
    var lastCompletedDate: Date?
    var totalDaysCompleted: Int
    var weeklyCompletions: [String: Bool] // "yyyy-MM-dd" -> completed

    static var empty: Streak {
        Streak(
            currentStreak: 0,
            longestStreak: 0,
            totalDaysCompleted: 0,
            weeklyCompletions: [:]
        )
    }

    /// Updates streak based on a new completed day
    mutating func recordCompletion(for date: Date) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateKey = formatter.string(from: date)

        guard weeklyCompletions[dateKey] != true else { return }

        weeklyCompletions[dateKey] = true
        totalDaysCompleted += 1

        // Check if yesterday was completed to continue streak
        guard let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: date) else { return }
        let yesterdayKey = formatter.string(from: yesterday)

        if weeklyCompletions[yesterdayKey] == true || currentStreak == 0 {
            currentStreak += 1
        } else {
            currentStreak = 1
        }

        longestStreak = max(longestStreak, currentStreak)
        lastCompletedDate = date
    }

    /// Checks if streak should be reset (missed a day)
    mutating func checkStreakContinuity() {
        guard let lastDate = lastCompletedDate else { return }
        let daysSince = Calendar.current.dateComponents([.day], from: lastDate, to: Date()).day ?? 0
        if daysSince > 1 {
            currentStreak = 0
        }
    }
}

// MARK: - Weekly Summary
struct WeeklySummary: Codable, Identifiable {
    var id: String { weekStartDate }
    var weekStartDate: String // "yyyy-MM-dd" of Monday
    var daysCompleted: Int
    var anchorsCompleted: Int
    var bloomsCompleted: Int
    var driftCount: Int
    var topDriftCategories: [String]
    var topBloomRoles: [String]
    var reflectionHighlight: String?
}
