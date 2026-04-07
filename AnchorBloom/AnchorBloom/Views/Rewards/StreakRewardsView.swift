import SwiftUI

// MARK: - Streak Milestones
enum StreakMilestone: Int, CaseIterable {
    case firstRoots = 7
    case steadyGrowth = 14
    case letterFromGod = 30
    case deepRoots = 60
    case testimonyCard = 90
    case halfYear = 180
    case yearOfBlooming = 365

    var title: String {
        switch self {
        case .firstRoots: return "First Roots"
        case .steadyGrowth: return "Steady Growth"
        case .letterFromGod: return "Letter from God"
        case .deepRoots: return "Deep Roots"
        case .testimonyCard: return "Testimony Card"
        case .halfYear: return "Half Year of Faith"
        case .yearOfBlooming: return "Year of Blooming"
        }
    }

    var description: String {
        switch self {
        case .firstRoots: return "Your faith is taking root. Download your verse wallpaper."
        case .steadyGrowth: return "Two weeks of faithfulness. God sees your consistency."
        case .letterFromGod: return "A personal letter drawn from your journal reflections."
        case .deepRoots: return "60 days anchored. You're becoming unshakeable."
        case .testimonyCard: return "Share your growth journey with a printable testimony card."
        case .halfYear: return "180 days. Your garden is flourishing."
        case .yearOfBlooming: return "One year rooted in Christ. A crown of faithfulness."
        }
    }

    var icon: String {
        switch self {
        case .firstRoots: return "leaf.fill"
        case .steadyGrowth: return "leaf.circle.fill"
        case .letterFromGod: return "envelope.fill"
        case .deepRoots: return "figure.mind.and.body"
        case .testimonyCard: return "star.circle.fill"
        case .halfYear: return "sparkles"
        case .yearOfBlooming: return "crown.fill"
        }
    }

    var color: Color {
        switch self {
        case .firstRoots, .steadyGrowth: return ABTheme.sageGreen
        case .letterFromGod, .testimonyCard, .yearOfBlooming: return ABTheme.warmGold
        case .deepRoots, .halfYear: return ABTheme.blush
        }
    }
}

// MARK: - Streak Rewards View
struct StreakRewardsView: View {
    let currentStreak: Int
    let longestStreak: Int
    let totalDays: Int
    let displayName: String
    let recentEntries: [DailyEntry]

    @Environment(\.dismiss) private var dismiss
    @State private var showWallpaper = false
    @State private var showLetter = false
    @State private var showTestimony = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: ABTheme.paddingLarge) {
                    // Streak header
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(ABTheme.warmGold.opacity(0.15))
                                .frame(width: 100, height: 100)

                            VStack(spacing: 2) {
                                Text("\(currentStreak)")
                                    .font(.system(size: 36, weight: .bold, design: .serif))
                                    .foregroundColor(ABTheme.warmGold)
                                Text("days")
                                    .font(.system(.caption, design: .serif, weight: .medium))
                                    .foregroundColor(ABTheme.secondaryText)
                            }
                        }

                        Text("Your Growth Journey")
                            .font(ABTheme.headlineFont)
                            .foregroundColor(ABTheme.primaryText)

                        Text("Every day you show up, God grows something beautiful in you")
                            .font(ABTheme.captionFont)
                            .foregroundColor(ABTheme.secondaryText)
                            .multilineTextAlignment(.center)

                        HStack(spacing: 24) {
                            VStack(spacing: 2) {
                                Text("\(longestStreak)")
                                    .font(.system(.body, design: .serif, weight: .bold))
                                    .foregroundColor(ABTheme.sageGreen)
                                Text("longest")
                                    .font(.caption2)
                                    .foregroundColor(ABTheme.secondaryText)
                            }
                            VStack(spacing: 2) {
                                Text("\(totalDays)")
                                    .font(.system(.body, design: .serif, weight: .bold))
                                    .foregroundColor(ABTheme.blush)
                                Text("total days")
                                    .font(.caption2)
                                    .foregroundColor(ABTheme.secondaryText)
                            }
                        }
                    }
                    .padding(.top, ABTheme.paddingSmall)

                    // Milestone timeline
                    VStack(spacing: 0) {
                        ForEach(StreakMilestone.allCases, id: \.rawValue) { milestone in
                            milestoneRow(milestone)
                        }
                    }

                    Spacer().frame(height: 40)
                }
                .padding(.horizontal, ABTheme.paddingMedium)
            }
            .abScreenBackground()
            .navigationTitle("Streak Rewards")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(ABTheme.sageGreen)
                }
            }
            .sheet(isPresented: $showWallpaper) {
                VerseWallpaperView(recentEntries: recentEntries)
            }
            .sheet(isPresented: $showLetter) {
                LetterFromGodView(
                    displayName: displayName,
                    topDriftCategory: topDrift,
                    topBloomRole: topRole,
                    streakDays: longestStreak
                )
            }
            .sheet(isPresented: $showTestimony) {
                TestimonyCardView(
                    displayName: displayName,
                    totalDays: totalDays,
                    longestStreak: longestStreak,
                    totalAnchors: recentEntries.filter { $0.anchorCompleted }.count,
                    totalBlooms: recentEntries.filter { $0.bloomCompleted }.count,
                    favoriteVerse: recentEntries.compactMap { $0.anchorScriptureRef }.first ?? "Psalm 139:14"
                )
            }
        }
    }

    private var topDrift: String? {
        let drifts = recentEntries.flatMap { $0.driftEntries }
        let counts = Dictionary(grouping: drifts, by: { $0.category }).mapValues { $0.count }
        return counts.max(by: { $0.value < $1.value })?.key.rawValue
    }

    private var topRole: String? {
        let roles = recentEntries.flatMap { $0.bloomRoles }
        let counts = Dictionary(grouping: roles, by: { $0 }).mapValues { $0.count }
        return counts.max(by: { $0.value < $1.value })?.key.rawValue
    }

    private func milestoneRow(_ milestone: StreakMilestone) -> some View {
        let isUnlocked = longestStreak >= milestone.rawValue
        let isNext = !isUnlocked && (StreakMilestone.allCases.first(where: { longestStreak < $0.rawValue }) == milestone)

        return HStack(alignment: .top, spacing: ABTheme.paddingMedium) {
            // Timeline line + circle
            VStack(spacing: 0) {
                Circle()
                    .fill(isUnlocked ? milestone.color : ABTheme.secondaryText.opacity(0.2))
                    .frame(width: 36, height: 36)
                    .overlay(
                        Image(systemName: isUnlocked ? milestone.icon : "lock.fill")
                            .font(.system(size: 14))
                            .foregroundColor(isUnlocked ? .white : ABTheme.secondaryText.opacity(0.5))
                    )

                if milestone != StreakMilestone.allCases.last {
                    Rectangle()
                        .fill(isUnlocked ? milestone.color.opacity(0.3) : ABTheme.secondaryText.opacity(0.1))
                        .frame(width: 2, height: 50)
                }
            }

            // Content
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(milestone.title)
                        .font(.system(.body, design: .serif, weight: .semibold))
                        .foregroundColor(isUnlocked ? ABTheme.primaryText : ABTheme.secondaryText)

                    Spacer()

                    Text("\(milestone.rawValue) days")
                        .font(.system(.caption2, design: .serif, weight: .medium))
                        .foregroundColor(isUnlocked ? milestone.color : ABTheme.secondaryText.opacity(0.5))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(isUnlocked ? milestone.color.opacity(0.1) : ABTheme.secondaryText.opacity(0.05))
                        .cornerRadius(8)
                }

                Text(milestone.description)
                    .font(.caption)
                    .foregroundColor(ABTheme.secondaryText)
                    .opacity(isUnlocked ? 1 : 0.6)

                if isUnlocked {
                    rewardButton(for: milestone)
                } else if isNext {
                    let daysLeft = milestone.rawValue - longestStreak
                    Text("\(daysLeft) more day\(daysLeft == 1 ? "" : "s") to unlock")
                        .font(.system(.caption2, design: .serif, weight: .medium))
                        .foregroundColor(ABTheme.warmGold)
                }
            }
            .padding(.bottom, 16)
        }
    }

    @ViewBuilder
    private func rewardButton(for milestone: StreakMilestone) -> some View {
        switch milestone {
        case .firstRoots:
            Button { showWallpaper = true } label: {
                rewardButtonLabel(icon: "photo.fill", text: "Get Wallpaper", color: ABTheme.sageGreen)
            }
        case .letterFromGod:
            Button { showLetter = true } label: {
                rewardButtonLabel(icon: "envelope.open.fill", text: "Read Letter", color: ABTheme.warmGold)
            }
        case .testimonyCard:
            Button { showTestimony = true } label: {
                rewardButtonLabel(icon: "star.fill", text: "View Testimony", color: ABTheme.warmGold)
            }
        default:
            HStack(spacing: 4) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.caption2)
                Text("Unlocked")
                    .font(.system(.caption, design: .serif, weight: .medium))
            }
            .foregroundColor(milestone.color)
        }
    }

    private func rewardButtonLabel(icon: String, text: String, color: Color) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption2)
            Text(text)
                .font(.system(.caption, design: .serif, weight: .medium))
        }
        .foregroundColor(.white)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(color)
        .cornerRadius(12)
    }
}

// MARK: - Verse Wallpaper View
struct VerseWallpaperView: View {
    let recentEntries: [DailyEntry]
    @Environment(\.dismiss) private var dismiss
    @State private var selectedStyle: WallpaperStyle = .dawn
    @State private var savedToPhotos = false

    enum WallpaperStyle: String, CaseIterable {
        case dawn = "Dawn"
        case garden = "Garden"
        case twilight = "Twilight"
        case blossom = "Blossom"

        var colors: [Color] {
            switch self {
            case .dawn: return [Color(red: 0.95, green: 0.85, blue: 0.65), Color(red: 0.98, green: 0.93, blue: 0.80), Color(red: 1.0, green: 0.97, blue: 0.92)]
            case .garden: return [Color(red: 0.45, green: 0.58, blue: 0.48), Color(red: 0.56, green: 0.68, blue: 0.58), Color(red: 0.75, green: 0.82, blue: 0.76)]
            case .twilight: return [Color(red: 0.12, green: 0.14, blue: 0.28), Color(red: 0.22, green: 0.24, blue: 0.40), Color(red: 0.15, green: 0.18, blue: 0.30)]
            case .blossom: return [Color(red: 0.95, green: 0.82, blue: 0.82), Color(red: 0.89, green: 0.72, blue: 0.72), Color(red: 0.95, green: 0.85, blue: 0.85)]
            }
        }

        var textColor: Color {
            self == .twilight ? .white : Color(red: 0.15, green: 0.18, blue: 0.27)
        }

        var accentColor: Color {
            switch self {
            case .dawn: return Color(red: 0.85, green: 0.65, blue: 0.35)
            case .garden: return Color(red: 0.35, green: 0.50, blue: 0.38)
            case .twilight: return Color(red: 0.65, green: 0.60, blue: 0.80)
            case .blossom: return Color(red: 0.78, green: 0.50, blue: 0.50)
            }
        }

        var icon: String {
            switch self {
            case .dawn: return "sunrise.fill"
            case .garden: return "leaf.fill"
            case .twilight: return "moon.stars.fill"
            case .blossom: return "camera.macro"
            }
        }
    }

    private var verse: String {
        recentEntries.first(where: { $0.anchorScriptureRef != nil })?.anchorScriptureRef ?? "\"Be still, and know that I am God.\" — Psalm 46:10"
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: ABTheme.paddingLarge) {
                    Text("Choose Your Wallpaper")
                        .font(ABTheme.headlineFont)
                        .foregroundColor(ABTheme.primaryText)

                    HStack(spacing: 12) {
                        ForEach(WallpaperStyle.allCases, id: \.self) { style in
                            Button { selectedStyle = style } label: {
                                VStack(spacing: 4) {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(LinearGradient(colors: style.colors, startPoint: .top, endPoint: .bottom))
                                        .frame(width: 50, height: 70)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(selectedStyle == style ? ABTheme.sageGreen : Color.clear, lineWidth: 2)
                                        )
                                    Text(style.rawValue)
                                        .font(.caption2)
                                        .foregroundColor(selectedStyle == style ? ABTheme.sageGreen : ABTheme.secondaryText)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    WallpaperImage(verse: verse, style: selectedStyle)
                        .frame(width: 200, height: 433)
                        .cornerRadius(20)
                        .shadow(color: ABTheme.cardShadow, radius: 10, x: 0, y: 4)

                    if savedToPhotos {
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.circle.fill").foregroundColor(ABTheme.sageGreen)
                            Text("Saved to Photos!").font(.system(.body, design: .serif, weight: .semibold)).foregroundColor(ABTheme.sageGreen)
                        }
                    } else {
                        Button { saveWallpaper() } label: {
                            HStack { Image(systemName: "square.and.arrow.down"); Text("Save to Photos") }
                        }
                        .buttonStyle(ABPrimaryButtonStyle())
                    }

                    Spacer().frame(height: 20)
                }
                .padding(.horizontal, ABTheme.paddingLarge)
            }
            .abScreenBackground()
            .navigationTitle("Verse Wallpaper")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }.foregroundColor(ABTheme.sageGreen)
                }
            }
        }
    }

    @MainActor
    private func saveWallpaper() {
        let renderer = ImageRenderer(content: WallpaperImage(verse: verse, style: selectedStyle).frame(width: 1170, height: 2532))
        renderer.scale = 1.0
        guard let uiImage = renderer.uiImage else { return }
        UIImageWriteToSavedPhotosAlbum(uiImage, nil, nil, nil)
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        savedToPhotos = true
    }
}

// MARK: - Wallpaper Image (Renderable)
struct WallpaperImage: View {
    let verse: String
    let style: VerseWallpaperView.WallpaperStyle

    var body: some View {
        ZStack {
            LinearGradient(colors: style.colors, startPoint: .top, endPoint: .bottom)

            VStack {
                HStack {
                    Spacer()
                    Image(systemName: "leaf.fill").font(.system(size: 60))
                        .foregroundColor(style.accentColor.opacity(0.12)).rotationEffect(.degrees(-30)).offset(x: -20, y: 40)
                }
                Spacer()
                HStack {
                    Image(systemName: "leaf.fill").font(.system(size: 45))
                        .foregroundColor(style.accentColor.opacity(0.10)).rotationEffect(.degrees(150)).offset(x: 20, y: -30)
                    Spacer()
                }
            }

            VStack(spacing: 24) {
                Spacer(); Spacer()
                Image(systemName: "quote.opening").font(.system(size: 28)).foregroundColor(style.accentColor.opacity(0.5))
                Text(verse).font(.system(.title3, design: .serif).italic()).foregroundColor(style.textColor)
                    .multilineTextAlignment(.center).lineSpacing(8).padding(.horizontal, 40)
                Spacer(); Spacer()
                HStack(spacing: 6) {
                    Image(systemName: "anchor").font(.caption)
                    Text("Anchor & Bloom").font(.system(.caption, design: .serif, weight: .medium))
                }.foregroundColor(style.textColor.opacity(0.4)).padding(.bottom, 60)
            }
        }
    }
}

// MARK: - Letter from God View
struct LetterFromGodView: View {
    let displayName: String
    let topDriftCategory: String?
    let topBloomRole: String?
    let streakDays: Int

    @Environment(\.dismiss) private var dismiss

    private var letter: String {
        let drift = topDriftCategory ?? "comparison"
        let role = topBloomRole ?? "Nurturer"
        let firstName = displayName.components(separatedBy: " ").first ?? displayName

        return """
        My Dearest \(firstName),

        I've been watching you. Not from a distance — but right here, as close as your breath.

        For \(streakDays) days, you've chosen to turn to Me before the world could speak. Do you know what that means? It means you're learning to hear My voice above the noise. And I am so proud of you.

        I know about the \(drift.lowercased()). I know about the days it felt louder than My truth. But here's what you need to understand — every single time you brought it to Me instead of carrying it alone, something shifted in the heavens. The enemy lost ground. Your roots grew deeper.

        And I've seen you bloom as a \(role). That's not an accident. I placed that gift inside you before you were born. When you walk in it, you look exactly like who I created you to be.

        There will be harder days ahead. Days when you want to quit, when the comparison creeps back in, when you feel unseen. But remember this: I have never looked away from you. Not once.

        You are not behind. You are not too much. You are not too little.

        You are Mine. And that has always been enough.

        Keep growing, keep blooming, keep anchoring in My Word. The woman you're becoming will change the world around her — and she won't even realize it, because she'll be too busy looking at Me.

        With all the love in the universe,

        Your Father
        """
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: ABTheme.paddingLarge) {
                    Image(systemName: "envelope.open.fill").font(.system(size: 36)).foregroundColor(ABTheme.warmGold)
                        .padding(.top, ABTheme.paddingMedium)

                    Text("A Letter for You").font(ABTheme.headlineFont).foregroundColor(ABTheme.primaryText)

                    VStack(alignment: .leading) {
                        Text(letter)
                            .font(.system(.body, design: .serif).italic())
                            .foregroundColor(ABTheme.primaryText)
                            .lineSpacing(6)
                    }
                    .padding(ABTheme.paddingLarge)
                    .background(
                        RoundedRectangle(cornerRadius: ABTheme.cornerRadius).fill(ABTheme.cardBackground)
                            .shadow(color: ABTheme.cardShadow, radius: 10, x: 0, y: 4)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: ABTheme.cornerRadius).stroke(ABTheme.warmGold.opacity(0.2), lineWidth: 1)
                    )

                    ShareLink(item: letter) {
                        HStack { Image(systemName: "square.and.arrow.up"); Text("Share Letter") }
                    }
                    .buttonStyle(ABSecondaryButtonStyle())

                    Spacer().frame(height: 40)
                }
                .padding(.horizontal, ABTheme.paddingMedium)
            }
            .abScreenBackground()
            .navigationTitle("Letter from God")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }.foregroundColor(ABTheme.sageGreen)
                }
            }
        }
    }
}

// MARK: - Testimony Card View
struct TestimonyCardView: View {
    let displayName: String
    let totalDays: Int
    let longestStreak: Int
    let totalAnchors: Int
    let totalBlooms: Int
    let favoriteVerse: String

    @Environment(\.dismiss) private var dismiss
    @State private var savedToPhotos = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: ABTheme.paddingLarge) {
                    Text("Your Growth Testimony").font(ABTheme.headlineFont).foregroundColor(ABTheme.primaryText)

                    TestimonyCardImage(displayName: displayName, totalDays: totalDays, longestStreak: longestStreak,
                                       totalAnchors: totalAnchors, totalBlooms: totalBlooms, favoriteVerse: favoriteVerse)
                        .frame(maxWidth: 340)

                    if savedToPhotos {
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.circle.fill").foregroundColor(ABTheme.sageGreen)
                            Text("Saved to Photos!").font(.system(.body, design: .serif, weight: .semibold)).foregroundColor(ABTheme.sageGreen)
                        }
                    }

                    if let image = renderCard() {
                        ShareLink(item: image, preview: SharePreview("My Growth Testimony — Anchor & Bloom", image: image)) {
                            HStack { Image(systemName: "square.and.arrow.up"); Text("Share Testimony") }
                        }
                        .buttonStyle(ABPrimaryButtonStyle())
                    }

                    Button { saveToPhotos() } label: {
                        HStack { Image(systemName: "square.and.arrow.down"); Text("Save to Photos") }
                    }
                    .buttonStyle(ABSecondaryButtonStyle())

                    Spacer().frame(height: 40)
                }
                .padding(.horizontal, ABTheme.paddingLarge)
            }
            .abScreenBackground()
            .navigationTitle("Testimony Card")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }.foregroundColor(ABTheme.sageGreen)
                }
            }
        }
    }

    @MainActor private func renderCard() -> Image? {
        let renderer = ImageRenderer(content: TestimonyCardImage(displayName: displayName, totalDays: totalDays, longestStreak: longestStreak, totalAnchors: totalAnchors, totalBlooms: totalBlooms, favoriteVerse: favoriteVerse).frame(width: 600, height: 600))
        renderer.scale = 3.0
        guard let uiImage = renderer.uiImage else { return nil }
        return Image(uiImage: uiImage)
    }

    @MainActor private func saveToPhotos() {
        let renderer = ImageRenderer(content: TestimonyCardImage(displayName: displayName, totalDays: totalDays, longestStreak: longestStreak, totalAnchors: totalAnchors, totalBlooms: totalBlooms, favoriteVerse: favoriteVerse).frame(width: 1080, height: 1080))
        renderer.scale = 2.0
        guard let uiImage = renderer.uiImage else { return }
        UIImageWriteToSavedPhotosAlbum(uiImage, nil, nil, nil)
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        savedToPhotos = true
    }
}

// MARK: - Testimony Card Image (Renderable)
struct TestimonyCardImage: View {
    let displayName: String
    let totalDays: Int
    let longestStreak: Int
    let totalAnchors: Int
    let totalBlooms: Int
    let favoriteVerse: String

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.97, green: 0.95, blue: 0.91), Color(red: 0.93, green: 0.87, blue: 0.73).opacity(0.4), Color(red: 0.97, green: 0.95, blue: 0.91)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )

            RoundedRectangle(cornerRadius: 16).stroke(ABTheme.warmGold.opacity(0.3), lineWidth: 2).padding(12)

            VStack(spacing: 16) {
                Spacer()
                Image(systemName: "crown.fill").font(.system(size: 28)).foregroundColor(ABTheme.warmGold)
                Text("My Growth Testimony").font(.system(.headline, design: .serif, weight: .bold)).foregroundColor(ABTheme.darkNavy)
                Text(displayName).font(.system(.subheadline, design: .serif, weight: .semibold)).foregroundColor(ABTheme.sageGreen)

                Rectangle().fill(ABTheme.warmGold.opacity(0.3)).frame(width: 60, height: 1)

                HStack(spacing: 24) {
                    statItem(value: "\(totalDays)", label: "Days")
                    statItem(value: "\(longestStreak)", label: "Streak")
                    statItem(value: "\(totalAnchors)", label: "Anchors")
                    statItem(value: "\(totalBlooms)", label: "Blooms")
                }

                VStack(spacing: 6) {
                    Image(systemName: "quote.opening").font(.caption).foregroundColor(ABTheme.warmGold.opacity(0.5))
                    Text(favoriteVerse).font(.system(.caption, design: .serif).italic())
                        .foregroundColor(ABTheme.darkNavy.opacity(0.7)).multilineTextAlignment(.center).lineSpacing(3).padding(.horizontal, 30)
                }

                Spacer()

                HStack(spacing: 6) {
                    Image(systemName: "anchor").font(.system(size: 10))
                    Text("Anchor & Bloom").font(.system(.caption2, design: .serif, weight: .medium))
                }.foregroundColor(ABTheme.secondaryText.opacity(0.4)).padding(.bottom, 16)
            }
            .padding(ABTheme.paddingLarge)
        }
        .aspectRatio(1, contentMode: .fit)
        .cornerRadius(20)
        .shadow(color: ABTheme.cardShadow, radius: 10, x: 0, y: 4)
    }

    private func statItem(value: String, label: String) -> some View {
        VStack(spacing: 2) {
            Text(value).font(.system(.title3, design: .serif, weight: .bold)).foregroundColor(ABTheme.darkNavy)
            Text(label).font(.system(size: 9, weight: .medium, design: .serif)).foregroundColor(ABTheme.secondaryText)
        }
    }
}

// MARK: - Streak Loss Encouragement View
struct StreakLossEncouragementView: View {
    let previousStreak: Int
    let onStartFresh: () -> Void

    var body: some View {
        VStack(spacing: ABTheme.paddingMedium) {
            Image(systemName: "leaf.fill").font(.system(size: 32))
                .foregroundColor(ABTheme.warmGold.opacity(0.6)).rotationEffect(.degrees(-15))

            Text("Your garden is waiting for you")
                .font(.system(.body, design: .serif, weight: .semibold)).foregroundColor(ABTheme.primaryText)

            Text("Every master gardener has seasons of rest. Your roots are still there, sister. Come back and watch what God grows next.")
                .font(ABTheme.captionFont).foregroundColor(ABTheme.secondaryText).multilineTextAlignment(.center).lineSpacing(3)

            if previousStreak > 0 {
                Text("Your \(previousStreak)-day streak planted seeds that still bloom.")
                    .font(.system(.caption2, design: .serif).italic()).foregroundColor(ABTheme.warmGold)
            }

            Button { onStartFresh() } label: {
                HStack { Image(systemName: "leaf.fill"); Text("Start Fresh") }
            }
            .buttonStyle(ABPrimaryButtonStyle())
        }
        .padding(ABTheme.paddingLarge)
        .background(ABTheme.cardBackground)
        .cornerRadius(ABTheme.cornerRadius)
        .shadow(color: ABTheme.cardShadow, radius: ABTheme.cardShadowRadius, x: 0, y: 2)
    }
}
