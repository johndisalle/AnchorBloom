import Foundation

// MARK: - Badge Model
/// Achievement badges earned through consistent spiritual growth
struct Badge: Codable, Identifiable {
    var id: String
    var name: String
    var description: String
    var iconName: String
    var category: BadgeCategory
    var requirement: BadgeRequirement
    var earnedAt: Date?

    var isEarned: Bool { earnedAt != nil }
}

enum BadgeCategory: String, Codable, CaseIterable {
    case streak = "Consistency"
    case anchor = "Anchored"
    case bloom = "Blooming"
    case drift = "Overcomer"
    case journey = "Journey"
    case community = "Sisterhood"

    var icon: String {
        switch self {
        case .streak: return "flame.fill"
        case .anchor: return "anchor.circle.fill"
        case .bloom: return "camera.macro"
        case .drift: return "shield.checkered"
        case .journey: return "map.fill"
        case .community: return "heart.circle.fill"
        }
    }
}

struct BadgeRequirement: Codable {
    var type: BadgeRequirementType
    var count: Int
}

enum BadgeRequirementType: String, Codable {
    case streakDays
    case totalAnchors
    case totalBlooms
    case driftPrayers
    case journeyCompleted
    case circleJoined
    case totalEntries
}

// MARK: - Default Badges
extension Badge {
    static let allBadges: [Badge] = [
        // Streak badges
        Badge(id: "first_root", name: "First Root", description: "Complete your first full day", iconName: "leaf.circle.fill", category: .streak, requirement: BadgeRequirement(type: .streakDays, count: 1)),
        Badge(id: "seedling", name: "Seedling", description: "3-day streak — your roots are growing!", iconName: "leaf.fill", category: .streak, requirement: BadgeRequirement(type: .streakDays, count: 3)),
        Badge(id: "rooted", name: "Rooted", description: "7-day streak — deeply planted in truth", iconName: "tree.fill", category: .streak, requirement: BadgeRequirement(type: .streakDays, count: 7)),
        Badge(id: "flourishing", name: "Flourishing", description: "14-day streak — blooming beautifully", iconName: "camera.macro", category: .streak, requirement: BadgeRequirement(type: .streakDays, count: 14)),
        Badge(id: "unshakeable", name: "Unshakeable", description: "30-day streak — deeply anchored", iconName: "mountain.2.fill", category: .streak, requirement: BadgeRequirement(type: .streakDays, count: 30)),
        Badge(id: "oak_of_righteousness", name: "Oak of Righteousness", description: "60-day streak — Isaiah 61:3", iconName: "tree.circle.fill", category: .streak, requirement: BadgeRequirement(type: .streakDays, count: 60)),
        Badge(id: "century_bloom", name: "Century Bloom", description: "100-day streak — a garden of faithfulness", iconName: "sparkles", category: .streak, requirement: BadgeRequirement(type: .streakDays, count: 100)),

        // Anchor badges
        Badge(id: "first_anchor", name: "Morning Light", description: "Complete your first morning anchor", iconName: "sunrise.fill", category: .anchor, requirement: BadgeRequirement(type: .totalAnchors, count: 1)),
        Badge(id: "anchor_10", name: "Firm Foundation", description: "10 morning anchors completed", iconName: "building.columns.fill", category: .anchor, requirement: BadgeRequirement(type: .totalAnchors, count: 10)),
        Badge(id: "anchor_50", name: "Truth Bearer", description: "50 morning anchors — you know His Word", iconName: "book.closed.fill", category: .anchor, requirement: BadgeRequirement(type: .totalAnchors, count: 50)),

        // Bloom badges
        Badge(id: "first_bloom", name: "First Petal", description: "Complete your first evening bloom", iconName: "camera.macro", category: .bloom, requirement: BadgeRequirement(type: .totalBlooms, count: 1)),
        Badge(id: "bloom_10", name: "Garden Tender", description: "10 evening blooms completed", iconName: "leaf.arrow.circlepath", category: .bloom, requirement: BadgeRequirement(type: .totalBlooms, count: 10)),
        Badge(id: "bloom_50", name: "Proverbs 31 Woman", description: "50 evening blooms — she is clothed in strength", iconName: "crown.fill", category: .bloom, requirement: BadgeRequirement(type: .totalBlooms, count: 50)),

        // Drift badges
        Badge(id: "first_prayer", name: "Surrendered", description: "Play your first anchoring prayer", iconName: "hands.sparkles.fill", category: .drift, requirement: BadgeRequirement(type: .driftPrayers, count: 1)),
        Badge(id: "prayer_10", name: "Overcomer", description: "10 anchoring prayers — you fight on your knees", iconName: "shield.checkered", category: .drift, requirement: BadgeRequirement(type: .driftPrayers, count: 10)),

        // Journey badges
        Badge(id: "first_journey", name: "Pilgrim", description: "Complete your first 30-day journey", iconName: "map.fill", category: .journey, requirement: BadgeRequirement(type: .journeyCompleted, count: 1)),

        // Community badges
        Badge(id: "first_circle", name: "Sister", description: "Join your first circle", iconName: "person.2.fill", category: .community, requirement: BadgeRequirement(type: .circleJoined, count: 1)),
    ]
}
