import Foundation

// MARK: - Preview Data
/// Sample data for SwiftUI previews and development
struct PreviewData {

    // MARK: - Sample User
    static let sampleUser = UserProfile(
        email: "grace@example.com",
        displayName: "Grace",
        isPremium: true,
        createdAt: Calendar.current.date(byAdding: .day, value: -45, to: Date())!,
        lastActiveAt: Date(),
        notificationsEnabled: true,
        currentStreak: 14,
        longestStreak: 21,
        totalDaysCompleted: 38,
        earnedBadgeIDs: ["first_root", "seedling", "rooted", "flourishing", "first_anchor", "anchor_10", "first_bloom", "bloom_10", "first_prayer"],
        journeyProgress: [:],
        circleIDs: ["circle_1"],
        blockedUserIDs: []
    )

    static let freeUser = UserProfile(
        email: "hope@example.com",
        displayName: "Hope",
        isPremium: false,
        createdAt: Calendar.current.date(byAdding: .day, value: -7, to: Date())!,
        lastActiveAt: Date(),
        notificationsEnabled: true,
        currentStreak: 5,
        longestStreak: 5,
        totalDaysCompleted: 5,
        earnedBadgeIDs: ["first_root", "seedling", "first_anchor", "first_bloom"],
        journeyProgress: [:],
        circleIDs: [],
        blockedUserIDs: []
    )

    // MARK: - Sample Daily Entries
    static let completedEntry: DailyEntry = {
        var entry = DailyEntry.new(userID: "user_1", date: Date())
        entry.anchorCompleted = true
        entry.anchorScriptureRef = "Proverbs 31:25"
        entry.anchorReflection = "I realized today that the lie of perfectionism has been stealing my peace. I'm choosing to rest in God's grace instead of striving for a standard He never set."
        entry.anchorTags = [.perfectionism, .comparison]
        entry.anchorCompletedAt = Calendar.current.date(from: DateComponents(hour: 7, minute: 30))
        entry.bloomCompleted = true
        entry.bloomRoles = [.nurturer, .prayerWarrior, .gracefulSpeaker]
        entry.bloomReflection = "I spoke encouragement over my friend who was struggling. I prayed with my kids before bed. I chose gentleness when I wanted to snap. God is growing something beautiful in these small moments."
        entry.bloomCompletedAt = Calendar.current.date(from: DateComponents(hour: 20, minute: 15))
        entry.driftEntries = [
            DriftEntry(category: .comparison, note: "Scrolled Instagram and felt behind"),
        ]
        return entry
    }()

    static let partialEntry: DailyEntry = {
        var entry = DailyEntry.new(userID: "user_1", date: Date())
        entry.anchorCompleted = true
        entry.anchorTags = [.anxiety]
        entry.anchorReflection = "Anxiety about the future was loud this morning. But God reminded me He holds tomorrow."
        return entry
    }()

    // MARK: - Sample Circle
    static let sampleCircle = SisterCircle(
        name: "Rooted Mamas",
        description: "Moms growing deeper roots in Christ while raising the next generation",
        creatorID: "user_1",
        memberIDs: ["user_1", "user_2", "user_3", "user_4", "user_5"],
        memberNames: [
            "user_1": "Grace",
            "user_2": "Hope",
            "user_3": "Faith",
            "user_4": "Joy",
            "user_5": "Mercy"
        ],
        adminIDs: ["user_1"],
        createdAt: Calendar.current.date(byAdding: .day, value: -30, to: Date())!,
        isPrivate: true,
        inviteCode: "BLOOM7",
        maxMembers: 12,
        coverImageName: "default"
    )

    // MARK: - Sample Posts
    static let samplePosts: [CirclePost] = [
        CirclePost(
            circleID: "circle_1",
            authorID: "user_2",
            authorName: "Hope",
            type: .praise,
            content: "My daughter asked to pray with me before school today. All those nights of bedtime prayers are bearing fruit! God is so faithful.",
            scriptureReference: "Proverbs 22:6",
            createdAt: Calendar.current.date(byAdding: .hour, value: -3, to: Date())!,
            likedByIDs: ["user_1", "user_3", "user_4"],
            commentCount: 2,
            isAnonymous: false
        ),
        CirclePost(
            circleID: "circle_1",
            authorID: "user_3",
            authorName: "Faith",
            type: .prayerRequest,
            content: "Sisters, please pray for my marriage. We're going through a really hard season and I need God to move. I'm standing firm but I'm weary.",
            createdAt: Calendar.current.date(byAdding: .hour, value: -8, to: Date())!,
            likedByIDs: ["user_1", "user_2", "user_4", "user_5"],
            commentCount: 5,
            isAnonymous: true
        ),
        CirclePost(
            circleID: "circle_1",
            authorID: "user_1",
            authorName: "Grace",
            type: .encouragement,
            content: "Reminder for all my sisters today: You are not behind. You are not too much. You are not too little. You are exactly where God has you, and He is doing a beautiful work. Keep blooming.",
            scriptureReference: "Philippians 1:6",
            createdAt: Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
            likedByIDs: ["user_2", "user_3"],
            commentCount: 1,
            isAnonymous: false
        ),
    ]

    // MARK: - Sample Week of Entries
    static let weekOfEntries: [DailyEntry] = (0..<7).map { offset in
        let date = Calendar.current.date(byAdding: .day, value: -offset, to: Date())!
        var entry = DailyEntry.new(userID: "user_1", date: date)
        // Vary completion for realistic preview
        if offset % 3 != 2 { // Most days completed
            entry.anchorCompleted = true
            entry.anchorTags = [AnchorTag.allCases.randomElement()!]
        }
        if offset % 4 != 3 { // Most evenings completed
            entry.bloomCompleted = true
            entry.bloomRoles = [BloomRole.allCases.randomElement()!]
        }
        if offset % 2 == 0 { // Some drifts
            entry.driftEntries = [DriftEntry(category: DriftCategory.allCases.randomElement()!)]
        }
        return entry
    }
}
