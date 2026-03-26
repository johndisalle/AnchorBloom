import Foundation
import FirebaseFirestore

// MARK: - User Profile Model
/// Represents a user's profile in Anchor & Bloom
struct UserProfile: Codable, Identifiable {
    @DocumentID var id: String?
    var email: String
    var displayName: String
    var profileImageURL: String?
    var isPremium: Bool
    var subscriptionExpiresAt: Date?
    var createdAt: Date
    var lastActiveAt: Date

    // Onboarding preferences
    var morningReminderTime: Date?
    var eveningReminderTime: Date?
    var notificationsEnabled: Bool

    // Progress tracking
    var currentStreak: Int
    var longestStreak: Int
    var totalDaysCompleted: Int
    var earnedBadgeIDs: [String]
    var activeJourneyID: String?
    var journeyProgress: [String: Int] // journeyID -> day completed

    // Circle memberships
    var circleIDs: [String]

    // Moderation
    var blockedUserIDs: [String]

    static var empty: UserProfile {
        UserProfile(
            email: "",
            displayName: "",
            isPremium: false,
            createdAt: Date(),
            lastActiveAt: Date(),
            notificationsEnabled: true,
            currentStreak: 0,
            longestStreak: 0,
            totalDaysCompleted: 0,
            earnedBadgeIDs: [],
            journeyProgress: [:],
            circleIDs: [],
            blockedUserIDs: []
        )
    }
}

// MARK: - Subscription Tier
enum SubscriptionTier: String, Codable {
    case free
    case premiumMonthly
    case premiumYearly

    var displayName: String {
        switch self {
        case .free: return "Free"
        case .premiumMonthly: return "Premium Monthly"
        case .premiumYearly: return "Premium Yearly"
        }
    }

    var price: String {
        switch self {
        case .free: return "Free"
        case .premiumMonthly: return "$6.99/month"
        case .premiumYearly: return "$59.99/year"
        }
    }
}
