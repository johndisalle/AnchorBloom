import Foundation
import FirebaseFirestore

// MARK: - Sister Circle Model
/// Private small groups for encouragement and accountability
struct SisterCircle: Codable, Identifiable {
    @DocumentID var id: String?
    var name: String
    var description: String
    var creatorID: String
    var memberIDs: [String]
    var memberNames: [String: String] // userID -> displayName
    var adminIDs: [String] // userIDs with admin privileges (creator auto-included)
    var createdAt: Date
    var isPrivate: Bool
    var inviteCode: String?
    var maxMembers: Int
    var coverImageName: String
    var driftCategory: String? // Links circle to a DriftCategory (e.g. "Anxiety", "Comparison")

    var memberCount: Int { memberIDs.count }
    var isFull: Bool { memberIDs.count >= maxMembers }

    /// Check if a user is an admin (creator or explicit admin)
    func isAdmin(_ userID: String) -> Bool {
        creatorID == userID || adminIDs.contains(userID)
    }

    /// Returns the linked DriftCategory if one exists
    var linkedDriftCategory: DriftCategory? {
        guard let raw = driftCategory else { return nil }
        return DriftCategory(rawValue: raw)
    }

    static let maxFreeCircles = 2
    static let defaultMaxMembers = 12
}

// MARK: - Circle Post
/// A post within a sister circle
struct CirclePost: Codable, Identifiable {
    @DocumentID var id: String?
    var circleID: String
    var authorID: String
    var authorName: String
    var type: CirclePostType
    var content: String
    var scriptureReference: String?
    var createdAt: Date
    var likedByIDs: [String]
    var commentCount: Int
    var isAnonymous: Bool?

    var likeCount: Int { likedByIDs.count }

    var displayName: String {
        (isAnonymous ?? false) ? "A Sister in Christ" : authorName
    }
}

// MARK: - Daily Circle Prompts
/// Rotating prompts shown when creating a new post
enum CirclePrompts {
    static let prompts: [String] = [
        "What truth is God teaching you in this season?",
        "How did you see God's faithfulness today?",
        "What scripture has been on your heart this week?",
        "Share a moment of grace you experienced recently.",
        "What area of growth is God working on in your life?",
        "How can your sisters pray for you today?",
        "What lie have you been replacing with God's truth?",
        "Share something that made you grateful this week.",
        "What worship song has been ministering to your spirit?",
        "How has God surprised you recently?",
        "What is one way you stepped out in faith this week?",
        "Share an encouragement for a sister who is struggling.",
        "What does God's love look like in your life right now?",
        "What fear are you surrendering to God today?",
        "How has community strengthened your walk with Christ?",
        "What promise of God are you standing on this week?",
        "Share a testimony of answered prayer.",
        "What is God whispering to your heart today?",
        "How are you choosing joy in a hard season?",
        "What does blooming in purpose look like for you right now?",
        "Share a lesson you learned the hard way.",
        "What is one thing you want your sisters to know today?",
        "How has forgiveness set you free recently?",
        "What role are you growing into as a woman of God?",
        "Share a verse that changed your perspective this week.",
        "What act of kindness did you witness or give today?",
        "How are you resting in God's timing?",
        "What battle has God already won for you?",
        "Share a prayer for the women in this circle.",
        "What is one word God has placed on your heart for this season?",
    ]

    /// Returns today's prompt based on the day of the year
    static var todayPrompt: String {
        let day = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        return prompts[(day - 1) % prompts.count]
    }
}

enum CirclePostType: String, Codable, CaseIterable {
    case praise = "Praise"
    case prayerRequest = "Prayer Request"
    case encouragement = "Encouragement"
    case testimony = "Testimony"
    case question = "Question"

    var icon: String {
        switch self {
        case .praise: return "hands.clap.fill"
        case .prayerRequest: return "hands.sparkles.fill"
        case .encouragement: return "heart.fill"
        case .testimony: return "star.fill"
        case .question: return "questionmark.bubble.fill"
        }
    }
}

// MARK: - Circle Comment
struct CircleComment: Codable, Identifiable {
    @DocumentID var id: String?
    var postID: String
    var authorID: String
    var authorName: String
    var content: String
    var createdAt: Date
}

// MARK: - Content Report
/// A report filed by a user against a post, comment, or user
struct ContentReport: Codable, Identifiable {
    @DocumentID var id: String?
    var reporterID: String
    var reportedUserID: String
    var contentID: String?       // post or comment ID (nil for user-level reports)
    var contentType: ReportContentType
    var reason: ReportReason
    var details: String?         // optional free-text description
    var circleID: String?
    var status: ReportStatus
    var createdAt: Date
}

enum ReportContentType: String, Codable {
    case post
    case comment
    case user
}

enum ReportReason: String, Codable, CaseIterable {
    case inappropriate = "Inappropriate Content"
    case harassment = "Harassment or Bullying"
    case spam = "Spam"
    case hateSpeech = "Hate Speech"
    case other = "Other"

    var icon: String {
        switch self {
        case .inappropriate: return "exclamationmark.triangle.fill"
        case .harassment: return "hand.raised.fill"
        case .spam: return "xmark.bin.fill"
        case .hateSpeech: return "exclamationmark.bubble.fill"
        case .other: return "ellipsis.circle.fill"
        }
    }
}

enum ReportStatus: String, Codable {
    case pending
    case reviewed
    case dismissed
}
