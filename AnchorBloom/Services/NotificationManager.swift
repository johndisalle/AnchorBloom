import Foundation
import Combine
import UserNotifications

// MARK: - Notification Manager
/// Handles local push notifications for morning anchor and evening bloom reminders
final class NotificationManager: ObservableObject {
    @Published var isAuthorized = false

    static let morningIdentifier = "morning_anchor_reminder"
    static let eveningIdentifier = "evening_bloom_reminder"

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
        let content = UNMutableNotificationContent()
        content.title = "Good morning, beautiful 🌸"
        content.body = "Time to anchor your heart in God's truth. Your morning reflection is waiting."
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
        let content = UNMutableNotificationContent()
        content.title = "Time to bloom, sister 🌷"
        content.body = "Reflect on how God worked through you today. Your evening bloom is ready."
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

    // MARK: - Schedule Weekly Summary (Sunday at 7pm)
    static let weeklySummaryIdentifier = "weekly_spiritual_summary"

    func scheduleWeeklySummary(
        anchorDays: Int,
        bloomDays: Int,
        topDrift: String?,
        topRole: String?,
        streak: Int
    ) {
        let content = UNMutableNotificationContent()
        content.title = "Your Week in Review"

        var bodyParts: [String] = []
        bodyParts.append("You anchored \(anchorDays) days and bloomed \(bloomDays) days this week.")
        if let drift = topDrift {
            bodyParts.append("Top drift: \(drift).")
        }
        if let role = topRole {
            bodyParts.append("Top role: \(role).")
        }
        if streak > 0 {
            bodyParts.append("Current streak: \(streak) days!")
        }
        bodyParts.append("Keep growing, sister!")

        content.body = bodyParts.joined(separator: " ")
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

    // MARK: - Cancel All Notifications
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    // MARK: - Update Reminders
    func updateReminders(morning: Date?, evening: Date?, enabled: Bool) {
        cancelAllNotifications()
        guard enabled else { return }
        if let morningTime = morning { scheduleMorningReminder(at: morningTime) }
        if let eveningTime = evening { scheduleEveningReminder(at: eveningTime) }
    }
}
