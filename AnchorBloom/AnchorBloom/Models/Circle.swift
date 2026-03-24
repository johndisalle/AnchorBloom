import Foundation
import FirebaseFirestore

// MARK: - Sister Circle Model
/// Private small groups for encouragement and accountability
struct Circle: Codable, Identifiable {
    @DocumentID var id: String?
    var name: String
    var description: String
    var creatorID: String
    var memberIDs: [String]
    var memberNames: [String: String] // userID -> displayName
    var createdAt: Date
    var isPrivate: Bool
    var inviteCode: String?
    var maxMembers: Int
    var coverImageName: String

    var memberCount: Int { memberIDs.count }
    var isFull: Bool { memberIDs.count >= maxMembers }

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

    var likeCount: Int { likedByIDs.count }
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
