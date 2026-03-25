import Foundation
import Combine
import FirebaseFirestore
import FirebaseAuth

// MARK: - Firestore Service
/// Handles all Firestore CRUD operations for the app
@MainActor
final class FirestoreService: ObservableObject {
    private let db = Firestore.firestore()

    // Collection references
    private var usersCollection: CollectionReference { db.collection("users") }
    private var entriesCollection: CollectionReference { db.collection("entries") }
    private var circlesCollection: CollectionReference { db.collection("circles") }
    private var postsCollection: CollectionReference { db.collection("posts") }

    private var currentUserID: String? { Auth.auth().currentUser?.uid }

    // MARK: - User Profile Operations

    /// Creates or updates a user profile in Firestore
    func saveUserProfile(_ profile: UserProfile) async throws {
        guard let userID = currentUserID else { return }
        try usersCollection.document(userID).setData(from: profile, merge: true)
    }

    /// Fetches the current user's profile
    func fetchUserProfile() async throws -> UserProfile? {
        guard let userID = currentUserID else { return nil }
        let document = try await usersCollection.document(userID).getDocument()
        return try document.data(as: UserProfile.self)
    }

    /// Creates initial profile after sign up
    func createInitialProfile(displayName: String, email: String) async throws {
        guard let userID = currentUserID else { return }
        var profile = UserProfile.empty
        profile.displayName = displayName
        profile.email = email
        profile.morningReminderTime = Calendar.current.date(from: DateComponents(hour: 7, minute: 0))
        profile.eveningReminderTime = Calendar.current.date(from: DateComponents(hour: 20, minute: 0))
        try usersCollection.document(userID).setData(from: profile)
    }

    // MARK: - Daily Entry Operations

    /// Fetches today's entry, creating one if it doesn't exist
    func fetchOrCreateTodayEntry() async throws -> DailyEntry {
        guard let userID = currentUserID else {
            throw FirestoreError.notAuthenticated
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let todayString = formatter.string(from: Date())

        // Query for today's entry
        let snapshot = try await entriesCollection
            .whereField("userID", isEqualTo: userID)
            .whereField("dateString", isEqualTo: todayString)
            .limit(to: 1)
            .getDocuments()

        if let document = snapshot.documents.first {
            return try document.data(as: DailyEntry.self)
        }

        // Create new entry for today
        var entry = DailyEntry.new(userID: userID, date: Date())
        let docRef = entriesCollection.document()
        try docRef.setData(from: entry)
        entry.id = docRef.documentID
        return entry
    }

    /// Saves/updates a daily entry
    func saveDailyEntry(_ entry: DailyEntry) async throws {
        guard let entryID = entry.id else { return }
        try entriesCollection.document(entryID).setData(from: entry, merge: true)
    }

    /// Fetches entries for a date range (for progress/stats)
    func fetchEntries(from startDate: Date, to endDate: Date) async throws -> [DailyEntry] {
        guard let userID = currentUserID else { return [] }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let startString = formatter.string(from: startDate)
        let endString = formatter.string(from: endDate)

        let snapshot = try await entriesCollection
            .whereField("userID", isEqualTo: userID)
            .whereField("dateString", isGreaterThanOrEqualTo: startString)
            .whereField("dateString", isLessThanOrEqualTo: endString)
            .order(by: "dateString", descending: false)
            .getDocuments()

        return snapshot.documents.compactMap { try? $0.data(as: DailyEntry.self) }
    }

    /// Fetches all entries for the current user (for calendar view)
    func fetchAllEntries() async throws -> [DailyEntry] {
        guard let userID = currentUserID else { return [] }

        let snapshot = try await entriesCollection
            .whereField("userID", isEqualTo: userID)
            .order(by: "dateString", descending: true)
            .getDocuments()

        return snapshot.documents.compactMap { try? $0.data(as: DailyEntry.self) }
    }

    // MARK: - Streak Operations

    /// Updates user streak after completing a day
    func updateStreak(for profile: inout UserProfile) async throws {
        var streak = Streak(
            currentStreak: profile.currentStreak,
            longestStreak: profile.longestStreak,
            totalDaysCompleted: profile.totalDaysCompleted,
            weeklyCompletions: [:]
        )
        streak.recordCompletion(for: Date())
        profile.currentStreak = streak.currentStreak
        profile.longestStreak = streak.longestStreak
        profile.totalDaysCompleted = streak.totalDaysCompleted
        try await saveUserProfile(profile)
    }

    // MARK: - Circle Operations

    /// Creates a new sister circle
    func createCircle(_ circle: SisterCircle) async throws -> String {
        let docRef = try circlesCollection.addDocument(from: circle)
        return docRef.documentID
    }

    /// Fetches circles the user belongs to
    func fetchUserCircles() async throws -> [SisterCircle] {
        guard let userID = currentUserID else { return [] }

        let snapshot = try await circlesCollection
            .whereField("memberIDs", arrayContains: userID)
            .getDocuments()

        return snapshot.documents.compactMap { try? $0.data(as: SisterCircle.self) }
    }

    /// Joins a circle by invite code
    func joinCircle(inviteCode: String) async throws -> SisterCircle? {
        guard let userID = currentUserID else { return nil }

        let snapshot = try await circlesCollection
            .whereField("inviteCode", isEqualTo: inviteCode)
            .limit(to: 1)
            .getDocuments()

        guard let document = snapshot.documents.first,
              var circle = try? document.data(as: SisterCircle.self) else {
            throw FirestoreError.circleNotFound
        }

        guard !circle.isFull else { throw FirestoreError.circleFull }
        guard !circle.memberIDs.contains(userID) else { return circle }

        circle.memberIDs.append(userID)
        try circlesCollection.document(document.documentID).setData(from: circle, merge: true)
        return circle
    }

    // MARK: - Circle Posts

    /// Creates a post in a circle
    func createPost(_ post: CirclePost) async throws {
        try postsCollection.addDocument(from: post)
    }

    /// Fetches posts for a circle
    func fetchCirclePosts(circleID: String, limit: Int = 50) async throws -> [CirclePost] {
        let snapshot = try await postsCollection
            .whereField("circleID", isEqualTo: circleID)
            .order(by: "createdAt", descending: true)
            .limit(to: limit)
            .getDocuments()

        return snapshot.documents.compactMap { try? $0.data(as: CirclePost.self) }
    }

    /// Toggles like on a post
    func toggleLike(postID: String) async throws {
        guard let userID = currentUserID else { return }
        let docRef = postsCollection.document(postID)
        let document = try await docRef.getDocument()
        guard var post = try? document.data(as: CirclePost.self) else { return }

        if post.likedByIDs.contains(userID) {
            post.likedByIDs.removeAll { $0 == userID }
        } else {
            post.likedByIDs.append(userID)
        }
        try docRef.setData(from: post, merge: true)
    }

    // MARK: - Comment Operations

    private var commentsCollection: CollectionReference {
        db.collection("comments")
    }

    /// Add a comment to a post
    func addComment(postID: String, content: String) async throws {
        guard let userID = currentUserID else { return }
        let profile = try await fetchUserProfile()
        let comment = CircleComment(
            postID: postID,
            authorID: userID,
            authorName: profile?.displayName ?? "Sister",
            content: content,
            createdAt: Date()
        )
        try commentsCollection.addDocument(from: comment)

        // Increment comment count on the post
        let postRef = postsCollection.document(postID)
        try await postRef.updateData(["commentCount": FieldValue.increment(Int64(1))])
    }

    /// Fetch comments for a post
    func fetchComments(postID: String) async throws -> [CircleComment] {
        let snapshot = try await commentsCollection
            .whereField("postID", isEqualTo: postID)
            .order(by: "createdAt", descending: false)
            .getDocuments()

        return snapshot.documents.compactMap { try? $0.data(as: CircleComment.self) }
    }

    // MARK: - Badge Operations

    /// Checks and awards badges based on current progress
    func checkAndAwardBadges(profile: inout UserProfile, totalAnchors: Int, totalBlooms: Int, driftPrayers: Int) {
        for badge in Badge.allBadges {
            guard !profile.earnedBadgeIDs.contains(badge.id) else { continue }

            var earned = false
            switch badge.requirement.type {
            case .streakDays:
                earned = profile.longestStreak >= badge.requirement.count
            case .totalAnchors:
                earned = totalAnchors >= badge.requirement.count
            case .totalBlooms:
                earned = totalBlooms >= badge.requirement.count
            case .driftPrayers:
                earned = driftPrayers >= badge.requirement.count
            case .journeyCompleted:
                earned = profile.journeyProgress.values.filter { $0 >= 30 }.count >= badge.requirement.count
            case .circleJoined:
                earned = profile.circleIDs.count >= badge.requirement.count
            case .totalEntries:
                earned = profile.totalDaysCompleted >= badge.requirement.count
            }

            if earned {
                profile.earnedBadgeIDs.append(badge.id)
            }
        }
    }
}

// MARK: - Firestore Errors
enum FirestoreError: LocalizedError {
    case notAuthenticated
    case circleNotFound
    case circleFull
    case documentNotFound

    var errorDescription: String? {
        switch self {
        case .notAuthenticated: return "Please sign in to continue."
        case .circleNotFound: return "Circle not found. Check your invite code."
        case .circleFull: return "This circle is full."
        case .documentNotFound: return "Data not found."
        }
    }
}
