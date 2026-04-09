import SwiftUI

// MARK: - Dashboard View
/// Main home screen with blooming tree, streak, daily actions, and badges
struct DashboardView: View {
    @EnvironmentObject var firestoreService: FirestoreService
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @StateObject private var viewModel = AppViewModel(firestoreService: FirestoreService())
    @State private var showAnchorSheet = false
    @State private var showBloomSheet = false
    @State private var showProgressView = false
    @State private var showJourneyProgress = false
    @State private var showStreakRewards = false
    @State private var showScriptureMemory = false
    @State private var showYearInBloom = false
    @State private var showTopicalLibrary = false

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12: return "Good morning, beautiful"
        case 12..<17: return "Good afternoon, sister"
        default: return "Good evening, beloved"
        }
    }

    private var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: Date())
    }

    private var timeBasedAction: String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 14 {
            return "anchor" // morning/early afternoon = anchor time
        } else {
            return "bloom" // afternoon/evening = bloom time
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: ABTheme.paddingLarge) {
                    // Header
                    headerSection

                    // TODAY'S SCRIPTURE
                    todayScriptureCard

                    // Tree visualization (growth meter)
                    treeSection

                    // PRIMARY ACTION — what they should do NOW
                    if timeBasedAction == "anchor" && !(viewModel.todayEntry?.anchorCompleted ?? false) {
                        urgentActionCard(
                            title: "Anchor Your Morning",
                            message: "Start your day rooted in truth. Don't let the enemy set the tone — God already has a word for you.",
                            icon: "sunrise.fill",
                            color: ABTheme.warmGold
                        ) {
                            showAnchorSheet = true
                        }
                    } else if timeBasedAction == "bloom" && !(viewModel.todayEntry?.bloomCompleted ?? false) {
                        urgentActionCard(
                            title: "Time to Bloom",
                            message: "Before this day ends, reflect on how God worked through you. Celebrate who He's making you.",
                            icon: "camera.macro",
                            color: ABTheme.blush
                        ) {
                            showBloomSheet = true
                        }
                    }

                    // Morning Anchor card
                    DailyActionCard(
                        title: "Morning Anchor",
                        subtitle: "Root yourself in God's truth",
                        icon: "sunrise.fill",
                        color: ABTheme.warmGold,
                        isCompleted: viewModel.todayEntry?.anchorCompleted ?? false,
                        completedText: "Anchored"
                    ) {
                        showAnchorSheet = true
                    }

                    // Evening Bloom card
                    DailyActionCard(
                        title: "Evening Bloom",
                        subtitle: "Reflect on how you bloomed today",
                        icon: "camera.macro",
                        color: ABTheme.blush,
                        isCompleted: viewModel.todayEntry?.bloomCompleted ?? false,
                        completedText: "Bloomed"
                    ) {
                        showBloomSheet = true
                    }

                    // Active journey card
                    if let journey = viewModel.activeJourney {
                        activeJourneyCard(journey)
                    }

                    // Active goals (premium)
                    if subscriptionManager.isPremium {
                        let activeGoals = viewModel.spiritualGoals.filter { !$0.isCompleted }
                        if !activeGoals.isEmpty {
                            VStack(alignment: .leading, spacing: ABTheme.paddingSmall) {
                                HStack {
                                    Image(systemName: "target")
                                        .foregroundColor(ABTheme.warmGold)
                                    Text("Active Goals")
                                        .font(ABTheme.subheadlineFont)
                                        .foregroundColor(ABTheme.primaryText)
                                }

                                ForEach(activeGoals.prefix(2)) { goal in
                                    HStack(spacing: 10) {
                                        Image(systemName: goal.category.icon)
                                            .foregroundColor(ABTheme.sageGreen)
                                            .frame(width: 20)

                                        Text(goal.title)
                                            .font(.system(.caption, design: .serif))
                                            .foregroundColor(ABTheme.primaryText)
                                            .lineLimit(1)

                                        Spacer()

                                        Text("\(goal.completedDays)/\(goal.targetDays)")
                                            .font(.system(.caption2, design: .serif, weight: .bold))
                                            .foregroundColor(ABTheme.sageGreen)
                                    }
                                    .padding(.vertical, 6)
                                }
                            }
                            .abCard()
                        }
                    }

                    // Streak Rewards card
                    streakRewardsCard

                    // Scripture Memory card
                    Button { showScriptureMemory = true } label: {
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(ABTheme.sageGreen.opacity(0.15))
                                    .frame(width: 40, height: 40)
                                Image(systemName: "brain.head.profile")
                                    .font(.system(size: 16))
                                    .foregroundColor(ABTheme.sageGreen)
                            }
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Scripture Memory")
                                    .font(.system(.body, design: .serif, weight: .semibold))
                                    .foregroundColor(ABTheme.primaryText)
                                Text("Memorize verses through spaced repetition")
                                    .font(.caption2)
                                    .foregroundColor(ABTheme.secondaryText)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(ABTheme.secondaryText)
                        }
                        .abCard()
                    }
                    .buttonStyle(.plain)

                    // Topical Library card
                    Button { showTopicalLibrary = true } label: {
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(ABTheme.blush.opacity(0.15))
                                    .frame(width: 40, height: 40)
                                Image(systemName: "books.vertical.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(ABTheme.blush)
                            }
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Devotional Library")
                                    .font(.system(.body, design: .serif, weight: .semibold))
                                    .foregroundColor(ABTheme.primaryText)
                                Text("Devotionals for every season of life")
                                    .font(.caption2)
                                    .foregroundColor(ABTheme.secondaryText)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(ABTheme.secondaryText)
                        }
                        .abCard()
                    }
                    .buttonStyle(.plain)

                    // Year in Bloom — show in Dec/Jan
                    let month = Calendar.current.component(.month, from: Date())
                    if month == 12 || month == 1 {
                        Button { showYearInBloom = true } label: {
                            HStack(spacing: 12) {
                                ZStack {
                                    Circle()
                                        .fill(ABTheme.warmGold.opacity(0.15))
                                        .frame(width: 40, height: 40)
                                    Image(systemName: "sparkles")
                                        .font(.system(size: 16))
                                        .foregroundColor(ABTheme.warmGold)
                                }
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Your Year in Bloom")
                                        .font(.system(.body, design: .serif, weight: .semibold))
                                        .foregroundColor(ABTheme.primaryText)
                                    Text("See your faith journey this year — share your story")
                                        .font(.caption2)
                                        .foregroundColor(ABTheme.secondaryText)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(ABTheme.warmGold)
                            }
                            .padding(ABTheme.paddingMedium)
                            .background(
                                LinearGradient(
                                    colors: [ABTheme.warmGold.opacity(0.08), ABTheme.blush.opacity(0.08)],
                                    startPoint: .leading, endPoint: .trailing
                                )
                            )
                            .cornerRadius(ABTheme.cornerRadius)
                            .overlay(
                                RoundedRectangle(cornerRadius: ABTheme.cornerRadius)
                                    .stroke(ABTheme.warmGold.opacity(0.15), lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                    }

                    // Quick stats row
                    statsRow

                    // Recent badges
                    if !viewModel.earnedBadges.isEmpty {
                        recentBadgesSection
                    }

                    Spacer().frame(height: 20)
                }
                .padding(.horizontal, ABTheme.paddingMedium)
            }
            .abScreenBackground()
            .refreshable {
                await viewModel.loadUserData()
            }
            .task {
                await viewModel.loadUserData()
            }
            .sheet(isPresented: $showAnchorSheet) {
                AnchorView(viewModel: viewModel)
            }
            .sheet(isPresented: $showBloomSheet) {
                BloomView(viewModel: viewModel)
            }
            .sheet(isPresented: $showProgressView) {
                ProgressStatsView(viewModel: viewModel)
            }
            .fullScreenCover(isPresented: $showJourneyProgress) {
                if let journey = viewModel.activeJourney {
                    JourneyProgressView(journey: journey, viewModel: viewModel)
                }
            }
            .sheet(isPresented: $showScriptureMemory) {
                ScriptureMemoryView()
            }
            .sheet(isPresented: $showTopicalLibrary) {
                TopicalLibraryView()
            }
            .fullScreenCover(isPresented: $showYearInBloom) {
                YearInBloomView()
            }
            .sheet(isPresented: $showStreakRewards) {
                StreakRewardsView(
                    currentStreak: viewModel.userProfile?.currentStreak ?? 0,
                    longestStreak: viewModel.userProfile?.longestStreak ?? 0,
                    totalDays: viewModel.userProfile?.totalDaysCompleted ?? 0,
                    displayName: viewModel.userProfile?.displayName ?? "Sister",
                    recentEntries: viewModel.recentEntries
                )
            }
        }
    }

    // MARK: - Streak Rewards Card
    private var streakRewardsCard: some View {
        let streak = viewModel.userProfile?.currentStreak ?? 0
        let nextMilestone = [7, 14, 30, 60, 90, 180, 365].first(where: { $0 > streak }) ?? 365
        let progress = streak > 0 ? min(Double(streak) / Double(nextMilestone), 1.0) : 0

        return Button {
            showStreakRewards = true
        } label: {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: "flame.fill")
                        .foregroundColor(ABTheme.warmGold)
                    Text("\(streak)-Day Streak")
                        .font(.system(.body, design: .serif, weight: .semibold))
                        .foregroundColor(ABTheme.primaryText)
                    Spacer()
                    Text("View Rewards")
                        .font(.system(.caption, design: .serif, weight: .medium))
                        .foregroundColor(ABTheme.sageGreen)
                    Image(systemName: "chevron.right")
                        .font(.caption2)
                        .foregroundColor(ABTheme.sageGreen)
                }

                // Progress to next milestone
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Next reward at \(nextMilestone) days")
                            .font(.caption2)
                            .foregroundColor(ABTheme.secondaryText)
                        Spacer()
                        Text("\(streak)/\(nextMilestone)")
                            .font(.system(.caption2, design: .serif, weight: .bold))
                            .foregroundColor(ABTheme.warmGold)
                    }

                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(ABTheme.sageGreen.opacity(0.15))
                                .frame(height: 6)

                            RoundedRectangle(cornerRadius: 4)
                                .fill(ABTheme.warmGold)
                                .frame(width: geo.size.width * progress, height: 6)
                        }
                    }
                    .frame(height: 6)
                }
            }
            .abCard()
        }
        .buttonStyle(.plain)
    }

    // MARK: - Active Journey Card
    private func activeJourneyCard(_ journey: Journey) -> some View {
        let progress = viewModel.journeyProgress(for: journey.id)
        let nextDay = min(progress + 1, journey.totalDays)

        return Button {
            showJourneyProgress = true
        } label: {
            HStack(spacing: ABTheme.paddingMedium) {
                // Journey icon
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(ABTheme.sageGreen.opacity(0.15))
                        .frame(width: 50, height: 50)

                    Image(systemName: journey.iconName)
                        .font(.title2)
                        .foregroundColor(ABTheme.sageGreen)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(journey.title)
                        .font(.system(.body, design: .serif, weight: .semibold))
                        .foregroundColor(ABTheme.primaryText)

                    if progress >= journey.totalDays {
                        Text("Journey Complete!")
                            .font(.caption)
                            .foregroundColor(ABTheme.warmGold)
                    } else {
                        Text("Continue Day \(nextDay) of \(journey.totalDays)")
                            .font(.caption)
                            .foregroundColor(ABTheme.sageGreen)
                    }

                    // Mini progress bar
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(ABTheme.sageGreen.opacity(0.12))
                                .frame(height: 4)

                            RoundedRectangle(cornerRadius: 2)
                                .fill(ABTheme.sageGreen)
                                .frame(width: journey.totalDays > 0 ? geo.size.width * CGFloat(progress) / CGFloat(journey.totalDays) : 0, height: 4)
                        }
                    }
                    .frame(height: 4)
                }

                Spacer()

                Image(systemName: "arrow.right.circle.fill")
                    .font(.title3)
                    .foregroundColor(ABTheme.sageGreen)
            }
            .abCard()
        }
        .buttonStyle(.plain)
    }

    // MARK: - Today's Scripture Card
    private var todayScriptureCard: some View {
        let prompt = DailyPrompt.morningPrompts[
            (Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1 - 1) % DailyPrompt.morningPrompts.count
        ]
        return VStack(spacing: 10) {
            Text(prompt.scripture)
                .font(.system(size: 15, design: .serif).italic())
                .foregroundColor(ABTheme.sageGreenDark)
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            Text("— \(prompt.scriptureReference)")
                .font(.system(size: 12, weight: .semibold, design: .serif))
                .foregroundColor(ABTheme.sageGreen)
        }
        .padding(ABTheme.paddingMedium)
        .frame(maxWidth: .infinity)
        .background(ABTheme.sageGreen.opacity(0.08))
        .cornerRadius(ABTheme.cornerRadius)
    }

    // MARK: - Urgent Action Card
    private func urgentActionCard(title: String, message: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(color.opacity(0.15))
                            .frame(width: 44, height: 44)

                        Image(systemName: icon)
                            .font(.title3)
                            .foregroundColor(color)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(title)
                            .font(.system(.body, design: .serif, weight: .bold))
                            .foregroundColor(ABTheme.primaryText)

                        Text("Tap to begin")
                            .font(.system(.caption2, design: .serif))
                            .foregroundColor(color)
                    }

                    Spacer()

                    Image(systemName: "arrow.right.circle.fill")
                        .font(.title2)
                        .foregroundColor(color)
                }

                Text(message)
                    .font(.system(size: 14, design: .serif))
                    .foregroundColor(ABTheme.secondaryText)
                    .lineSpacing(3)
            }
            .padding(ABTheme.paddingMedium)
            .background(
                RoundedRectangle(cornerRadius: ABTheme.cornerRadius)
                    .fill(ABTheme.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: ABTheme.cornerRadius)
                            .stroke(color.opacity(0.3), lineWidth: 1.5)
                    )
            )
            .shadow(color: color.opacity(0.15), radius: 8, y: 3)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Header
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(greeting)
                .font(ABTheme.headlineFont)
                .foregroundColor(ABTheme.primaryText)

            Text(dateString)
                .font(ABTheme.captionFont)
                .foregroundColor(ABTheme.secondaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, ABTheme.paddingMedium)
    }

    // MARK: - Tree Section
    private var treeSection: some View {
        VStack(spacing: ABTheme.paddingSmall) {
            BloomingTreeView(
                growthLevel: viewModel.treeGrowthLevel,
                bloomCount: viewModel.bloomCount,
                fruitCount: viewModel.fruitCount,
                streakDays: viewModel.currentStreak
            )

            Button {
                showProgressView = true
            } label: {
                HStack(spacing: 6) {
                    Text("View Growth")
                        .font(.system(.caption, design: .serif, weight: .medium))
                    Image(systemName: "chart.bar.fill")
                        .font(.caption2)
                }
                .foregroundColor(ABTheme.sageGreen)
            }
        }
        .abCard()
    }


    // MARK: - Stats Row
    private var statsRow: some View {
        HStack(spacing: ABTheme.paddingMedium) {
            StatCard(
                value: "\(viewModel.currentStreak)",
                label: "Day Streak",
                icon: "flame.fill",
                color: .orange
            )

            StatCard(
                value: "\(viewModel.totalDays)",
                label: "Total Days",
                icon: "calendar",
                color: ABTheme.sageGreen
            )

            StatCard(
                value: "\(viewModel.earnedBadges.count)",
                label: "Badges",
                icon: "star.fill",
                color: ABTheme.warmGold
            )
        }
    }

    // MARK: - Recent Badges
    private var recentBadgesSection: some View {
        VStack(alignment: .leading, spacing: ABTheme.paddingSmall) {
            Text("Recent Badges")
                .font(ABTheme.subheadlineFont)
                .foregroundColor(ABTheme.primaryText)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.earnedBadges.suffix(5)) { badge in
                        BadgeCardSmall(badge: badge)
                    }
                }
            }
        }
    }
}

// MARK: - Daily Action Card
struct DailyActionCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let isCompleted: Bool
    let completedText: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: ABTheme.paddingMedium) {
                // Icon
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 50, height: 50)

                    if isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(ABTheme.sageGreen)
                    } else {
                        Image(systemName: icon)
                            .font(.title2)
                            .foregroundColor(color)
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(.body, design: .serif, weight: .semibold))
                        .foregroundColor(ABTheme.primaryText)

                    Text(isCompleted ? completedText : subtitle)
                        .font(.caption)
                        .foregroundColor(isCompleted ? ABTheme.sageGreen : ABTheme.secondaryText)
                }

                Spacer()

                Image(systemName: isCompleted ? "checkmark" : "chevron.right")
                    .foregroundColor(isCompleted ? ABTheme.sageGreen : ABTheme.secondaryText)
                    .font(.caption)
            }
            .abCard()
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Stat Card
struct StatCard: View {
    let value: String
    let label: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title3)

            Text(value)
                .font(.system(.title2, design: .serif, weight: .bold))
                .foregroundColor(ABTheme.primaryText)

            Text(label)
                .font(.system(.caption2, design: .serif))
                .foregroundColor(ABTheme.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, ABTheme.paddingMedium)
        .background(ABTheme.cardBackground)
        .cornerRadius(ABTheme.cornerRadiusSmall)
        .shadow(color: ABTheme.cardShadow, radius: 4, x: 0, y: 1)
    }
}

// MARK: - Small Badge Card
struct BadgeCardSmall: View {
    let badge: Badge

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: badge.iconName)
                .font(.title2)
                .foregroundColor(ABTheme.warmGold)

            Text(badge.name)
                .font(.system(.caption2, design: .serif, weight: .medium))
                .foregroundColor(ABTheme.primaryText)
                .lineLimit(1)
        }
        .frame(width: 70)
        .padding(.vertical, 10)
        .background(ABTheme.warmGoldLight.opacity(0.3))
        .cornerRadius(ABTheme.cornerRadiusSmall)
    }
}

#Preview {
    let service = FirestoreService()
    DashboardView()
        .environmentObject(service)
        .environmentObject(SubscriptionManager())
        .environmentObject(AppViewModel(firestoreService: service))
}
