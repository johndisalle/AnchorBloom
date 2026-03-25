import Foundation
import FirebaseFirestore

// MARK: - Bookmarked Verse Model
/// A scripture verse saved by the user for quick reference
struct BookmarkedVerse: Codable, Identifiable {
    @DocumentID var id: String?
    var userID: String
    var verseText: String
    var reference: String
    var source: VerseSource
    var savedAt: Date

    enum VerseSource: String, Codable {
        case morningAnchor = "Morning Anchor"
        case eveningBloom = "Evening Bloom"
        case journey = "Journey"
        case driftLog = "Drift Log"
    }
}
