import Foundation
import FirebaseFirestore

// MARK: - Spiritual Goal Model
/// Custom spiritual goals for premium users
struct SpiritualGoal: Codable, Identifiable {
    @DocumentID var id: String?
    var userID: String
    var title: String
    var category: GoalCategory
    var targetDays: Int
    var completedDays: Int
    var startDate: Date
    var isCompleted: Bool
    var completedAt: Date?
    var createdAt: Date

    var progressPercentage: Double {
        guard targetDays > 0 else { return 0 }
        return min(1.0, Double(completedDays) / Double(targetDays))
    }

    var daysRemaining: Int {
        max(0, targetDays - completedDays)
    }
}

// MARK: - Goal Category
enum GoalCategory: String, Codable, CaseIterable {
    case prayer = "Prayer"
    case scripture = "Scripture Reading"
    case journaling = "Journaling"
    case service = "Service"
    case worship = "Worship"
    case fasting = "Fasting"
    case custom = "Custom"

    var icon: String {
        switch self {
        case .prayer: return "hands.sparkles.fill"
        case .scripture: return "book.fill"
        case .journaling: return "pencil.line"
        case .service: return "heart.fill"
        case .worship: return "music.note"
        case .fasting: return "leaf.fill"
        case .custom: return "star.fill"
        }
    }

    var color: String {
        switch self {
        case .prayer: return "warmGold"
        case .scripture: return "sageGreen"
        case .journaling: return "blush"
        case .service: return "sageGreen"
        case .worship: return "warmGold"
        case .fasting: return "blush"
        case .custom: return "sageGreen"
        }
    }
}
