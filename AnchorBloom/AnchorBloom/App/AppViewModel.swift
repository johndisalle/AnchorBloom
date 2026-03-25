import Foundation
import Combine
import FirebaseAuth

// MARK: - App View Model
/// Central view model managing app state and daily entry lifecycle
@MainActor
final class AppViewModel: ObservableObject {
    @Published var userProfile: UserProfile?
    @Published var todayEntry: DailyEntry?
    @Published var recentEntries: [DailyEntry] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let firestoreService: FirestoreService

    init(firestoreService: FirestoreService) {
        self.firestoreService = firestoreService
    }

    // MARK: - Load User Data
    func loadUserData() async {
        isLoading = true
        defer { isLoading = false }

        do {
            userProfile = try await firestoreService.fetchUserProfile()
            todayEntry = try await firestoreService.fetchOrCreateTodayEntry()

            // Load recent entries for progress
            let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
            recentEntries = try await firestoreService.fetchEntries(from: thirtyDaysAgo, to: Date())
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Save Morning Anchor
    func saveMorningAnchor(reflection: String?, tags: [AnchorTag], scriptureRef: String?) async {
        guard var entry = todayEntry else { return }

        entry.anchorCompleted = true
        entry.anchorReflection = reflection
        entry.anchorTags = tags
        entry.anchorScriptureRef = scriptureRef
        entry.anchorCompletedAt = Date()

        do {
            try await firestoreService.saveDailyEntry(entry)
            todayEntry = entry
            await checkDayCompletion()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Save Evening Bloom
    func saveEveningBloom(reflection: String?, roles: [BloomRole]) async {
        guard var entry = todayEntry else { return }

        entry.bloomCompleted = true
        entry.bloomReflection = reflection
        entry.bloomRoles = roles
        entry.bloomCompletedAt = Date()

        do {
            try await firestoreService.saveDailyEntry(entry)
            todayEntry = entry
            await checkDayCompletion()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Log Drift Entry
    /// Saves drift to Firestore WITHOUT updating @Published properties,
    /// so no parent re-render occurs and the UI stays stable.
    func logDrift(category: DriftCategory, note: String?, prayerPlayed: Bool) async {
        guard var entry = todayEntry else { return }

        var drift = DriftEntry(category: category, note: note)
        drift.prayerPlayed = prayerPlayed
        entry.driftEntries.append(drift)

        try? await firestoreService.saveDailyEntry(entry)
        // NOT setting self.todayEntry here — that would trigger a
        // re-render which resets local @State in the view
    }

    // MARK: - Check Day Completion & Update Streak
    private func checkDayCompletion() async {
        guard let entry = todayEntry, entry.isFullyCompleted,
              var profile = userProfile else { return }

        do {
            try await firestoreService.updateStreak(for: &profile)

            // Count totals for badge checking
            let totalAnchors = recentEntries.filter { $0.anchorCompleted }.count + 1
            let totalBlooms = recentEntries.filter { $0.bloomCompleted }.count + 1
            let totalDriftPrayers = recentEntries.flatMap { $0.driftEntries }.filter { $0.prayerPlayed }.count

            firestoreService.checkAndAwardBadges(
                profile: &profile,
                totalAnchors: totalAnchors,
                totalBlooms: totalBlooms,
                driftPrayers: totalDriftPrayers
            )

            try await firestoreService.saveUserProfile(profile)
            userProfile = profile
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Computed Properties
    var currentStreak: Int { userProfile?.currentStreak ?? 0 }
    var longestStreak: Int { userProfile?.longestStreak ?? 0 }
    var totalDays: Int { userProfile?.totalDaysCompleted ?? 0 }
    var earnedBadges: [Badge] {
        let earnedIDs = userProfile?.earnedBadgeIDs ?? []
        return Badge.allBadges.filter { earnedIDs.contains($0.id) }
    }

    /// Tree growth level (0.0 - 1.0) based on streak
    var treeGrowthLevel: Double {
        let streak = Double(currentStreak)
        // Growth curve: rapid early growth, slower later
        return min(1.0, streak / 100.0 + (streak > 0 ? 0.1 : 0.0))
    }

    /// Number of blooming flowers based on recent bloom completions
    var bloomCount: Int {
        let recentBlooms = recentEntries.suffix(7).filter { $0.bloomCompleted }.count
        return recentBlooms
    }

    /// Number of fruit based on total entries
    var fruitCount: Int {
        min(12, totalDays / 5)
    }

    // MARK: - Journey Progression

    /// Get the current day completed for a journey (0 = not started)
    func journeyProgress(for journeyID: String) -> Int {
        userProfile?.journeyProgress[journeyID] ?? 0
    }

    /// The user's currently active journey, if any
    var activeJourney: Journey? {
        guard let activeID = userProfile?.activeJourneyID else { return nil }
        return Journey.allJourneys.first { $0.id == activeID }
    }

    /// Begin a new journey — saves to Firestore WITHOUT updating @Published
    /// properties, so no parent re-render occurs and the UI stays stable.
    func beginJourney(_ journeyID: String) async {
        guard var profile = userProfile else { return }

        profile.activeJourneyID = journeyID
        if profile.journeyProgress[journeyID] == nil {
            profile.journeyProgress[journeyID] = 0
        }

        try? await firestoreService.saveUserProfile(profile)
        // NOT setting self.userProfile here — that would trigger a
        // re-render which dismisses sheets / pops navigation
    }

    /// Mark a journey day as complete and advance progress
    func completeJourneyDay(journeyID: String, day: Int) async {
        guard var profile = userProfile else { return }

        let currentProgress = profile.journeyProgress[journeyID] ?? 0
        // Only advance if completing the next sequential day
        if day == currentProgress + 1 {
            profile.journeyProgress[journeyID] = day
        }

        do {
            try await firestoreService.saveUserProfile(profile)
            userProfile = profile
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
