import Foundation

// MARK: - Journey Model
/// 30-day guided spiritual growth journeys
struct Journey: Codable, Identifiable {
    var id: String
    var title: String
    var subtitle: String
    var description: String
    var iconName: String
    var coverColorName: String
    var totalDays: Int
    var isPremium: Bool
    var days: [JourneyDay]
    var scriptureTheme: String

    var isCompleted: Bool { false } // Computed from user progress
}

struct JourneyDay: Codable, Identifiable {
    var id: String { "\(journeyID)_day\(dayNumber)" }
    var journeyID: String
    var dayNumber: Int
    var title: String
    var scripture: String
    var scriptureReference: String
    var reflection: String
    var prompt: String
    var actionStep: String
    var prayer: String
}

// MARK: - Available Journeys
extension Journey {
    static let allJourneys: [Journey] = [
        // Free journeys
        Journey(
            id: "rooted_identity",
            title: "Rooted in Identity",
            subtitle: "Know who you are in Christ",
            description: "A 30-day journey to anchor your identity in God's truth, not the world's lies. Discover who He says you are — chosen, beloved, set apart — and let that truth transform how you live.",
            iconName: "tree.fill",
            coverColorName: "sageGreen",
            totalDays: 30,
            isPremium: false,
            days: [], // Populated in content phases
            scriptureTheme: "Ephesians 1-3"
        ),
        Journey(
            id: "armor_of_grace",
            title: "The Armor of Grace",
            subtitle: "Stand firm with gentle strength",
            description: "Put on the full armor of God — reimagined through the lens of biblical womanhood. Each piece protects you to stand firm while blooming with grace, truth, and love.",
            iconName: "shield.checkered",
            coverColorName: "warmGold",
            totalDays: 30,
            isPremium: false,
            days: [],
            scriptureTheme: "Ephesians 6:10-18"
        ),

        // Premium journeys
        Journey(
            id: "proverbs31",
            title: "The Proverbs 31 Life",
            subtitle: "Strength, dignity, and wisdom",
            description: "Go beyond the Pinterest version of Proverbs 31. Discover a woman of fierce faith, wise stewardship, and quiet confidence — and see how God is shaping you into the same.",
            iconName: "crown.fill",
            coverColorName: "blush",
            totalDays: 30,
            isPremium: true,
            days: [],
            scriptureTheme: "Proverbs 31:10-31"
        ),
        Journey(
            id: "prayer_warrior",
            title: "Becoming a Prayer Warrior",
            subtitle: "Fight your battles on your knees",
            description: "Learn to wield prayer as your most powerful weapon. This journey transforms your prayer life from routine to revolutionary — interceding with boldness and tenderness.",
            iconName: "hands.sparkles.fill",
            coverColorName: "darkNavy",
            totalDays: 30,
            isPremium: true,
            days: [],
            scriptureTheme: "James 5:16, Philippians 4:6-7"
        ),
        Journey(
            id: "gentle_strength",
            title: "Gentle Strength",
            subtitle: "Power under God's control",
            description: "Meekness isn't weakness — it's strength surrendered to God. Discover how gentleness, patience, and self-control make you an unstoppable force for His kingdom.",
            iconName: "leaf.fill",
            coverColorName: "sageGreen",
            totalDays: 30,
            isPremium: true,
            days: [],
            scriptureTheme: "1 Peter 3:3-4, Galatians 5:22-23"
        ),
        Journey(
            id: "freedom_from_comparison",
            title: "Freedom from Comparison",
            subtitle: "Run your own race with joy",
            description: "Break free from the comparison trap that steals your peace and purpose. Learn to celebrate others without diminishing yourself, rooted in God's unique calling for your life.",
            iconName: "figure.run",
            coverColorName: "warmGold",
            totalDays: 30,
            isPremium: true,
            days: [],
            scriptureTheme: "Galatians 6:4-5, Psalm 139"
        ),
        Journey(
            id: "cultivating_peace",
            title: "Cultivating Peace",
            subtitle: "Creating calm in the chaos",
            description: "In a world that glorifies busyness, learn to cultivate deep peace — in your heart, your home, and your relationships. Let God's shalom reign in every season.",
            iconName: "leaf.circle.fill",
            coverColorName: "cream",
            totalDays: 30,
            isPremium: true,
            days: [],
            scriptureTheme: "John 14:27, Philippians 4:6-7"
        ),
    ]
}
