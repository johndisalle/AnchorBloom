import Foundation
import Combine
import UserNotifications

// MARK: - Notification Manager
/// Handles local push notifications for morning anchor, evening bloom, and premium scripture reminders
final class NotificationManager: ObservableObject {
    @Published var isAuthorized = false

    static let morningIdentifier = "morning_anchor_reminder"
    static let eveningIdentifier = "evening_bloom_reminder"
    static let scriptureIdentifiers = [
        "scripture_reminder_midmorning",
        "scripture_reminder_afternoon",
        "scripture_reminder_evening"
    ]

    // MARK: - Request Authorization
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .badge, .sound])
            await MainActor.run { isAuthorized = granted }
            return granted
        } catch {
            return false
        }
    }

    // MARK: - Schedule Morning Reminder
    func scheduleMorningReminder(at time: Date) {
        let prompt = DailyPrompt.morningPrompts[
            (Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1 - 1) % DailyPrompt.morningPrompts.count
        ]
        let content = UNMutableNotificationContent()
        content.title = "Good morning, beautiful 🌸"
        content.body = "\(prompt.scripture) — \(prompt.scriptureReference)\n\nOpen to anchor your heart in this truth."
        content.sound = .default
        content.categoryIdentifier = "MORNING_ANCHOR"

        let components = Calendar.current.dateComponents([.hour, .minute], from: time)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

        let request = UNNotificationRequest(
            identifier: Self.morningIdentifier,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }

    // MARK: - Schedule Evening Reminder
    func scheduleEveningReminder(at time: Date) {
        let prompt = DailyPrompt.eveningPrompts[
            (Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1 - 1) % DailyPrompt.eveningPrompts.count
        ]
        let content = UNMutableNotificationContent()
        content.title = "Time to bloom, sister 🌷"
        content.body = "\(prompt.scripture) — \(prompt.scriptureReference)\n\nReflect on how God worked through you today."
        content.sound = .default
        content.categoryIdentifier = "EVENING_BLOOM"

        let components = Calendar.current.dateComponents([.hour, .minute], from: time)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

        let request = UNNotificationRequest(
            identifier: Self.eveningIdentifier,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }

    // MARK: - Premium Scripture Reminders
    /// Schedules 3 scripture-based reminders throughout the day for premium users
    func schedulePremiumScriptureReminders() {
        let times: [(hour: Int, minute: Int)] = [
            (10, 0),   // Mid-morning
            (13, 0),   // Afternoon
            (17, 0)    // Late afternoon
        ]

        let titles = [
            "Scripture for your heart 📖",
            "A word for your afternoon 🌿",
            "Evening truth to carry 🕊️"
        ]

        for (index, identifier) in Self.scriptureIdentifiers.enumerated() {
            let reminder = DailyPrompt.scriptureReminder(for: Date(), slot: index)

            let content = UNMutableNotificationContent()
            content.title = titles[index]
            content.body = "\"\(reminder.scripture)\" — \(reminder.reference)"
            content.sound = .default
            content.categoryIdentifier = "SCRIPTURE_REMINDER"

            var components = DateComponents()
            components.hour = times[index].hour
            components.minute = times[index].minute
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

            let request = UNNotificationRequest(
                identifier: identifier,
                content: content,
                trigger: trigger
            )

            UNUserNotificationCenter.current().add(request)
        }
    }

    /// Cancels only the premium scripture reminders
    func cancelPremiumReminders() {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: Self.scriptureIdentifiers)
    }

    // MARK: - Cancel All Notifications
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    // MARK: - Weekly Summary Notification
    static let weeklySummaryIdentifier = "weekly_summary"

    /// Schedules a weekly summary push for Sunday evening at 7pm
    func scheduleWeeklySummary(streak: Int, anchorCount: Int, totalDays: Int) {
        let content = UNMutableNotificationContent()
        content.title = "Your Week in Bloom 🌿"

        if anchorCount >= 7 {
            content.body = "You anchored every single day this week! \(streak)-day streak and counting. God is doing beautiful things in you, sister."
        } else if anchorCount >= 5 {
            content.body = "You anchored \(anchorCount)/7 days this week. \(streak)-day streak! Keep pressing in — consistency is where growth happens."
        } else if anchorCount > 0 {
            content.body = "You anchored \(anchorCount)/7 days this week. Every day you show up matters. Tomorrow is a new chance to root deeper."
        } else {
            content.body = "Your sisters miss you! Start fresh this week with just one morning anchor. God has a word for you."
        }

        content.sound = .default
        content.categoryIdentifier = "WEEKLY_SUMMARY"

        // Sunday at 7pm
        var components = DateComponents()
        components.weekday = 1 // Sunday
        components.hour = 19
        components.minute = 0
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

        let request = UNNotificationRequest(
            identifier: Self.weeklySummaryIdentifier,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }

    // MARK: - Update Reminders
    func updateReminders(morning: Date?, evening: Date?, enabled: Bool, isPremium: Bool = false, scriptureRemindersEnabled: Bool = true, streak: Int = 0, weeklyAnchors: Int = 0, totalDays: Int = 0) {
        cancelAllNotifications()
        guard enabled else { return }
        if let morningTime = morning { scheduleMorningReminder(at: morningTime) }
        if let eveningTime = evening { scheduleEveningReminder(at: eveningTime) }
        if isPremium && scriptureRemindersEnabled {
            schedulePremiumScriptureReminders()
        }
        // Always schedule weekly summary
        scheduleWeeklySummary(streak: streak, anchorCount: weeklyAnchors, totalDays: totalDays)
    }
}
