import SwiftUI
import FirebaseFirestore
import FirebaseAuth

// MARK: - Year in Bloom View (Spotify Wrapped for Faith)
struct YearInBloomView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var firestoreService: FirestoreService

    @State private var stats: BloomYearStats?
    @State private var isLoading = true
    @State private var currentCard = 0

    private let cardCount = 8

    var body: some View {
        ZStack {
            // Background gradient per card
            backgroundGradient
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.5), value: currentCard)

            VStack(spacing: 0) {
                // Close button
                HStack {
                    Spacer()
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .padding()
                }

                if isLoading {
                    Spacer()
                    ProgressView().tint(.white)
                    Spacer()
                } else if let stats {
                    // Card content
                    TabView(selection: $currentCard) {
                        titleCard.tag(0)
                        anchorsCard(stats).tag(1)
                        streakCard(stats).tag(2)
                        driftCard(stats).tag(3)
                        roleCard(stats).tag(4)
                        prayerCard(stats).tag(5)
                        journeyCard(stats).tag(6)
                        closingCard(stats).tag(7)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))

                    // Progress dots
                    HStack(spacing: 6) {
                        ForEach(0..<cardCount, id: \.self) { i in
                            Circle()
                                .fill(i == currentCard ? .white : .white.opacity(0.3))
                                .frame(width: i == currentCard ? 8 : 6, height: i == currentCard ? 8 : 6)
                        }
                    }
                    .padding(.bottom, 16)

                    // Share button
                    if let image = renderCurrentCard(stats) {
                        ShareLink(item: image, preview: SharePreview("My Year in Bloom", image: image)) {
                            HStack(spacing: 6) {
                                Image(systemName: "square.and.arrow.up")
                                Text("Share This Card")
                            }
                            .font(.system(.body, design: .serif, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.vertical, 14)
                            .frame(maxWidth: .infinity)
                            .background(.white.opacity(0.2))
                            .cornerRadius(ABTheme.cornerRadius)
                        }
                        .padding(.horizontal, ABTheme.paddingLarge)
                        .padding(.bottom, ABTheme.paddingLarge)
                    }
                }
            }
        }
        .task { await loadStats() }
    }

    // MARK: - Background

    private var backgroundGradient: some View {
        let colors: [Color] = {
            switch currentCard {
            case 0: return [Color(red: 0.15, green: 0.20, blue: 0.35), Color(red: 0.25, green: 0.30, blue: 0.50)]
            case 1: return [Color(red: 0.56, green: 0.68, blue: 0.58), Color(red: 0.40, green: 0.52, blue: 0.42)]
            case 2: return [Color(red: 0.85, green: 0.65, blue: 0.35), Color(red: 0.75, green: 0.55, blue: 0.25)]
            case 3: return [Color(red: 0.78, green: 0.55, blue: 0.55), Color(red: 0.65, green: 0.40, blue: 0.40)]
            case 4: return [Color(red: 0.56, green: 0.68, blue: 0.58), Color(red: 0.35, green: 0.50, blue: 0.38)]
            case 5: return [Color(red: 0.85, green: 0.75, blue: 0.55), Color(red: 0.70, green: 0.60, blue: 0.40)]
            case 6: return [Color(red: 0.55, green: 0.50, blue: 0.70), Color(red: 0.40, green: 0.35, blue: 0.55)]
            default: return [Color(red: 0.15, green: 0.20, blue: 0.35), Color(red: 0.56, green: 0.68, blue: 0.58)]
            }
        }()
        return LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    // MARK: - Cards

    private var titleCard: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "sparkles")
                .font(.system(size: 48))
                .foregroundColor(.white.opacity(0.8))

            Text("Your Year\nin Bloom")
                .font(.system(size: 40, weight: .bold, design: .serif))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)

            Text(String(Calendar.current.component(.year, from: Date())))
                .font(.system(size: 24, weight: .light, design: .serif))
                .foregroundColor(.white.opacity(0.7))

            Text("Swipe to see your story →")
                .font(.system(.caption, design: .serif))
                .foregroundColor(.white.opacity(0.5))
            Spacer()
        }
        .padding(ABTheme.paddingLarge)
    }

    private func anchorsCard(_ s: BloomYearStats) -> some View {
        VStack(spacing: 20) {
            Spacer()
            Text("You anchored")
                .font(.system(.title3, design: .serif))
                .foregroundColor(.white.opacity(0.8))

            Text("\(s.totalAnchors)")
                .font(.system(size: 72, weight: .bold, design: .serif))
                .foregroundColor(.white)

            Text("times this year")
                .font(.system(.title3, design: .serif))
                .foregroundColor(.white.opacity(0.8))

            Text("That's \(s.totalAnchors) mornings you chose God's truth\nbefore the world could speak.")
                .font(.system(.caption, design: .serif).italic())
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)
            Spacer()
        }
        .padding(ABTheme.paddingLarge)
    }

    private func streakCard(_ s: BloomYearStats) -> some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "flame.fill")
                .font(.system(size: 40))
                .foregroundColor(.white.opacity(0.8))

            Text("Your longest streak")
                .font(.system(.title3, design: .serif))
                .foregroundColor(.white.opacity(0.8))

            Text("\(s.longestStreak) days")
                .font(.system(size: 56, weight: .bold, design: .serif))
                .foregroundColor(.white)

            Text("of showing up, day after day,\nanchored in His Word.")
                .font(.system(.body, design: .serif).italic())
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
            Spacer()
        }
        .padding(ABTheme.paddingLarge)
    }

    private func driftCard(_ s: BloomYearStats) -> some View {
        VStack(spacing: 20) {
            Spacer()
            Text("Your biggest drift was")
                .font(.system(.title3, design: .serif))
                .foregroundColor(.white.opacity(0.8))

            Text(s.topDrift)
                .font(.system(size: 36, weight: .bold, design: .serif))
                .foregroundColor(.white)

            Text("But you fought it \(s.topDriftCount) times.")
                .font(.system(.title3, design: .serif))
                .foregroundColor(.white.opacity(0.8))

            Text("Every time you named it and brought it to God,\nthe enemy lost ground.")
                .font(.system(.caption, design: .serif).italic())
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)
            Spacer()
        }
        .padding(ABTheme.paddingLarge)
    }

    private func roleCard(_ s: BloomYearStats) -> some View {
        VStack(spacing: 20) {
            Spacer()
            Text("Your most-lived role")
                .font(.system(.title3, design: .serif))
                .foregroundColor(.white.opacity(0.8))

            Text(s.topRole)
                .font(.system(size: 36, weight: .bold, design: .serif))
                .foregroundColor(.white)

            Text("This is who God made you to be.\nAnd you walked in it beautifully.")
                .font(.system(.body, design: .serif).italic())
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
            Spacer()
        }
        .padding(ABTheme.paddingLarge)
    }

    private func prayerCard(_ s: BloomYearStats) -> some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "hands.sparkles.fill")
                .font(.system(size: 40))
                .foregroundColor(.white.opacity(0.8))

            Text("You prayed for")
                .font(.system(.title3, design: .serif))
                .foregroundColor(.white.opacity(0.8))

            Text("\(s.prayersPrayed)")
                .font(.system(size: 56, weight: .bold, design: .serif))
                .foregroundColor(.white)

            Text("sisters on the Prayer Wall")
                .font(.system(.title3, design: .serif))
                .foregroundColor(.white.opacity(0.8))

            Text("Every tap was a real prayer.\nGod heard every one.")
                .font(.system(.caption, design: .serif).italic())
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)
            Spacer()
        }
        .padding(ABTheme.paddingLarge)
    }

    private func journeyCard(_ s: BloomYearStats) -> some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "map.fill")
                .font(.system(size: 40))
                .foregroundColor(.white.opacity(0.8))

            if s.journeysCompleted > 0 {
                Text("You completed")
                    .font(.system(.title3, design: .serif))
                    .foregroundColor(.white.opacity(0.8))

                Text("\(s.journeysCompleted) journey\(s.journeysCompleted == 1 ? "" : "s")")
                    .font(.system(size: 48, weight: .bold, design: .serif))
                    .foregroundColor(.white)

                Text("That's \(s.journeysCompleted * 30) days of guided growth\nin God's Word.")
                    .font(.system(.body, design: .serif).italic())
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
            } else {
                Text("Your journey\nis just beginning")
                    .font(.system(size: 32, weight: .bold, design: .serif))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)

                Text("Every great story has a first chapter.\nYours starts now.")
                    .font(.system(.body, design: .serif).italic())
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
            Spacer()
        }
        .padding(ABTheme.paddingLarge)
    }

    private func closingCard(_ s: BloomYearStats) -> some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "crown.fill")
                .font(.system(size: 44))
                .foregroundColor(.white.opacity(0.8))

            Text("Keep blooming,\nsister.")
                .font(.system(size: 36, weight: .bold, design: .serif))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)

            Text("\(s.totalDays) days rooted. \(s.totalBlooms) evenings bloomed.\nGod is doing something beautiful in you.")
                .font(.system(.body, design: .serif).italic())
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)

            HStack(spacing: 6) {
                Image(systemName: "anchor")
                    .font(.caption)
                Text("Anchor & Bloom")
                    .font(.system(.caption, design: .serif, weight: .medium))
            }
            .foregroundColor(.white.opacity(0.4))
            Spacer()
        }
        .padding(ABTheme.paddingLarge)
    }

    // MARK: - Rendering for Share

    @MainActor
    private func renderCurrentCard(_ stats: BloomYearStats) -> Image? {
        let cardView: AnyView
        switch currentCard {
        case 0: cardView = AnyView(titleCard)
        case 1: cardView = AnyView(anchorsCard(stats))
        case 2: cardView = AnyView(streakCard(stats))
        case 3: cardView = AnyView(driftCard(stats))
        case 4: cardView = AnyView(roleCard(stats))
        case 5: cardView = AnyView(prayerCard(stats))
        case 6: cardView = AnyView(journeyCard(stats))
        default: cardView = AnyView(closingCard(stats))
        }

        let renderer = ImageRenderer(
            content: ZStack {
                backgroundGradient
                cardView
                // Watermark
                VStack {
                    Spacer()
                    HStack(spacing: 6) {
                        Image(systemName: "anchor")
                            .font(.system(size: 10))
                        Text("Anchor & Bloom")
                            .font(.system(.caption2, design: .serif, weight: .medium))
                    }
                    .foregroundColor(.white.opacity(0.3))
                    .padding(.bottom, 20)
                }
            }
            .frame(width: 1080, height: 1920)
        )
        renderer.scale = 1.0
        guard let uiImage = renderer.uiImage else { return nil }
        return Image(uiImage: uiImage)
    }

    // MARK: - Load Stats

    private func loadStats() async {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        isLoading = true
        defer { isLoading = false }

        do {
            let year = Calendar.current.component(.year, from: Date())
            let startOfYear = Calendar.current.date(from: DateComponents(year: year, month: 1, day: 1)) ?? Date()
            let entries = try await firestoreService.fetchEntries(from: startOfYear, to: Date())
            let profile = try await firestoreService.fetchUserProfile()

            let totalAnchors = entries.filter { $0.anchorCompleted }.count
            let totalBlooms = entries.filter { $0.bloomCompleted }.count
            let allDrifts = entries.flatMap { $0.driftEntries }
            let driftCounts = Dictionary(grouping: allDrifts, by: { $0.category }).mapValues { $0.count }
            let topDriftEntry = driftCounts.max(by: { $0.value < $1.value })
            let allRoles = entries.flatMap { $0.bloomRoles }
            let roleCounts = Dictionary(grouping: allRoles, by: { $0 }).mapValues { $0.count }
            let topRoleEntry = roleCounts.max(by: { $0.value < $1.value })

            // Count prayers prayed on prayer wall
            let prayerSnapshot = try? await Firestore.firestore().collection("prayerRequests")
                .whereField("prayedByIDs", arrayContains: userID)
                .getDocuments()
            let prayersPrayed = prayerSnapshot?.documents.count ?? 0

            let journeysCompleted = profile?.journeyProgress.values.filter { $0 >= 30 }.count ?? 0

            stats = BloomYearStats(
                totalAnchors: totalAnchors,
                totalBlooms: totalBlooms,
                totalDays: entries.filter { $0.isFullyCompleted }.count,
                longestStreak: profile?.longestStreak ?? 0,
                topDrift: topDriftEntry?.key.rawValue ?? "None",
                topDriftCount: topDriftEntry?.value ?? 0,
                topRole: topRoleEntry?.key.rawValue ?? "None",
                prayersPrayed: prayersPrayed,
                journeysCompleted: journeysCompleted
            )
        } catch { }
    }
}

// MARK: - Year Stats Model
struct BloomYearStats {
    let totalAnchors: Int
    let totalBlooms: Int
    let totalDays: Int
    let longestStreak: Int
    let topDrift: String
    let topDriftCount: Int
    let topRole: String
    let prayersPrayed: Int
    let journeysCompleted: Int
}
