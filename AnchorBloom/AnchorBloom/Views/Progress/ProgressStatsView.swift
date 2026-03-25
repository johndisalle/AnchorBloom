import SwiftUI

// MARK: - Progress & Stats View
/// Tree visualization, streak calendar, badge gallery, weekly summaries
struct ProgressStatsView: View {
    @ObservedObject var viewModel: AppViewModel
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @Environment(\.dismiss) private var dismiss

    @State private var selectedTab = 0
    @State private var showCreateGoal = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Segmented picker
                Picker("", selection: $selectedTab) {
                    Text("Growth").tag(0)
                    Text("Journeys").tag(1)
                    Text("Calendar").tag(2)
                    Text("Badges").tag(3)
                    if subscriptionManager.isPremium {
                        Text("Insights").tag(4)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, ABTheme.paddingMedium)
                .padding(.top, ABTheme.paddingSmall)

                TabView(selection: $selectedTab) {
                    growthTab.tag(0)
                    journeysTab.tag(1)
                    calendarTab.tag(2)
                    badgesTab.tag(3)
                    if subscriptionManager.isPremium {
                        insightsTab.tag(4)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            .abScreenBackground()
            .navigationTitle("Your Growth")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(ABTheme.sageGreen)
                }
            }
        }
    }

    // MARK: - Growth Tab
    private var growthTab: some View {
        ScrollView {
            VStack(spacing: ABTheme.paddingLarge) {
                // Large tree
                BloomingTreeView(
                    growthLevel: viewModel.treeGrowthLevel,
                    bloomCount: viewModel.bloomCount,
                    fruitCount: viewModel.fruitCount,
                    streakDays: viewModel.currentStreak
                )
                .padding(.top, ABTheme.paddingMedium)

                // Stats grid
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ProgressStatCard(
                        title: "Current Streak",
                        value: "\(viewModel.currentStreak) days",
                        icon: "flame.fill",
                        color: .orange
                    )
                    ProgressStatCard(
                        title: "Longest Streak",
                        value: "\(viewModel.longestStreak) days",
                        icon: "trophy.fill",
                        color: ABTheme.warmGold
                    )
                    ProgressStatCard(
                        title: "Total Days",
                        value: "\(viewModel.totalDays)",
                        icon: "calendar",
                        color: ABTheme.sageGreen
                    )
                    ProgressStatCard(
                        title: "Badges Earned",
                        value: "\(viewModel.earnedBadges.count)/\(Badge.allBadges.count)",
                        icon: "star.fill",
                        color: ABTheme.warmGold
                    )
                }
                .padding(.horizontal, ABTheme.paddingMedium)

                // Weekly summary
                weeklyBreakdown
                    .padding(.horizontal, ABTheme.paddingMedium)

                // Spiritual Goals (Premium)
                if subscriptionManager.isPremium {
                    goalsSection
                        .padding(.horizontal, ABTheme.paddingMedium)
                }

                Spacer().frame(height: 40)
            }
        }
    }

    // MARK: - Goals Section
    private var goalsSection: some View {
        VStack(alignment: .leading, spacing: ABTheme.paddingSmall) {
            HStack {
                Image(systemName: "target")
                    .foregroundColor(ABTheme.warmGold)
                Text("Spiritual Goals")
                    .font(ABTheme.subheadlineFont)
                    .foregroundColor(ABTheme.primaryText)

                Spacer()

                Button {
                    showCreateGoal = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(ABTheme.sageGreen)
                }
            }

            let activeGoals = viewModel.spiritualGoals.filter { !$0.isCompleted }
            let completedGoals = viewModel.spiritualGoals.filter { $0.isCompleted }

            if activeGoals.isEmpty && completedGoals.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "target")
                        .font(.title2)
                        .foregroundColor(ABTheme.secondaryText.opacity(0.4))
                    Text("No goals yet")
                        .font(ABTheme.captionFont)
                        .foregroundColor(ABTheme.secondaryText)
                    Button("Set Your First Goal") {
                        showCreateGoal = true
                    }
                    .font(.system(.caption, design: .serif, weight: .semibold))
                    .foregroundColor(ABTheme.sageGreen)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, ABTheme.paddingLarge)
            } else {
                ForEach(activeGoals) { goal in
                    GoalCard(goal: goal, viewModel: viewModel)
                }

                if !completedGoals.isEmpty {
                    Text("Completed")
                        .font(.system(.caption2, design: .serif, weight: .semibold))
                        .foregroundColor(ABTheme.secondaryText)
                        .padding(.top, 4)

                    ForEach(completedGoals.prefix(3)) { goal in
                        GoalCard(goal: goal, viewModel: viewModel)
                    }
                }
            }
        }
        .abCard()
        .sheet(isPresented: $showCreateGoal) {
            CreateGoalView(viewModel: viewModel)
        }
    }

    // MARK: - Insights Tab (Premium)
    private var insightsTab: some View {
        ScrollView {
            VStack(spacing: ABTheme.paddingLarge) {
                Text("Growth Insights")
                    .font(ABTheme.headlineFont)
                    .foregroundColor(ABTheme.primaryText)
                    .padding(.top, ABTheme.paddingMedium)

                // Weekly Summary Card
                weeklySummaryCard
                    .padding(.horizontal, ABTheme.paddingMedium)

                // 14-day activity chart
                activityChart
                    .padding(.horizontal, ABTheme.paddingMedium)

                // Top drift categories
                if !viewModel.topDriftCategories.isEmpty {
                    topDriftSection
                        .padding(.horizontal, ABTheme.paddingMedium)
                }

                // Top bloom roles
                if !viewModel.topBloomRoles.isEmpty {
                    topBloomSection
                        .padding(.horizontal, ABTheme.paddingMedium)
                }

                Spacer().frame(height: 40)
            }
        }
    }

    // MARK: - Weekly Summary Card
    private var weeklySummaryCard: some View {
        let last7 = viewModel.recentEntries.suffix(7)
        let daysCompleted = last7.filter { $0.isFullyCompleted }.count
        let anchors = last7.filter { $0.anchorCompleted }.count
        let blooms = last7.filter { $0.bloomCompleted }.count
        let drifts = last7.flatMap { $0.driftEntries }.count
        let topDrift = viewModel.topDriftCategories.first?.category.rawValue ?? "none"
        let topRole = viewModel.topBloomRoles.first?.role.rawValue ?? "none"

        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "doc.text.fill")
                    .foregroundColor(ABTheme.warmGold)
                Text("This Week's Report")
                    .font(ABTheme.subheadlineFont)
                    .foregroundColor(ABTheme.primaryText)
            }

            Text("You completed \(daysCompleted) of 7 days this week with \(anchors) anchors and \(blooms) blooms. \(drifts > 0 ? "Your most common drift was \(topDrift.lowercased())." : "No drifts logged — standing strong!") \(blooms > 0 ? "You walked most as a \(topRole)." : "")")
                .font(ABTheme.bodyFont)
                .foregroundColor(ABTheme.secondaryText)
                .lineSpacing(4)

            // Completion rate
            HStack {
                Text("Weekly completion")
                    .font(.system(.caption, design: .serif))
                    .foregroundColor(ABTheme.secondaryText)
                Spacer()
                Text("\(daysCompleted)/7 days")
                    .font(.system(.caption, design: .serif, weight: .bold))
                    .foregroundColor(ABTheme.sageGreen)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(ABTheme.sageGreen.opacity(0.12))
                        .frame(height: 6)
                    RoundedRectangle(cornerRadius: 3)
                        .fill(ABTheme.sageGreen)
                        .frame(width: geo.size.width * CGFloat(daysCompleted) / 7.0, height: 6)
                }
            }
            .frame(height: 6)
        }
        .abCard()
        .overlay(
            RoundedRectangle(cornerRadius: ABTheme.cornerRadius)
                .stroke(ABTheme.warmGold.opacity(0.3), lineWidth: 1)
        )
    }

    // MARK: - Activity Chart (Simple bar chart)
    private var activityChart: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .foregroundColor(ABTheme.sageGreen)
                Text("14-Day Activity")
                    .font(ABTheme.subheadlineFont)
                    .foregroundColor(ABTheme.primaryText)
            }

            let last14 = last14DaysActivity()

            HStack(alignment: .bottom, spacing: 4) {
                ForEach(last14, id: \.date) { day in
                    VStack(spacing: 2) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(day.isFullDay ? ABTheme.sageGreen :
                                  day.isPartialDay ? ABTheme.warmGold.opacity(0.6) :
                                  ABTheme.sageGreen.opacity(0.1))
                            .frame(height: CGFloat(day.score) * 12 + 4)

                        Text(day.label)
                            .font(.system(size: 8))
                            .foregroundColor(ABTheme.secondaryText)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 60)

            // Legend
            HStack(spacing: 16) {
                HStack(spacing: 4) {
                    Circle().fill(ABTheme.sageGreen).frame(width: 8, height: 8)
                    Text("Full day").font(.caption2).foregroundColor(ABTheme.secondaryText)
                }
                HStack(spacing: 4) {
                    Circle().fill(ABTheme.warmGold.opacity(0.6)).frame(width: 8, height: 8)
                    Text("Partial").font(.caption2).foregroundColor(ABTheme.secondaryText)
                }
            }
        }
        .abCard()
    }

    // MARK: - Top Drift Section
    private var topDriftSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "water.waves")
                    .foregroundColor(ABTheme.blush)
                Text("Most Common Drifts")
                    .font(ABTheme.subheadlineFont)
                    .foregroundColor(ABTheme.primaryText)
            }

            ForEach(viewModel.topDriftCategories, id: \.category) { item in
                HStack {
                    Image(systemName: item.category.icon)
                        .foregroundColor(ABTheme.blush)
                        .frame(width: 24)
                    Text(item.category.rawValue)
                        .font(.system(.body, design: .serif))
                        .foregroundColor(ABTheme.primaryText)
                    Spacer()
                    Text("\(item.count) times")
                        .font(.system(.caption, design: .serif, weight: .semibold))
                        .foregroundColor(ABTheme.secondaryText)
                }
                .padding(.vertical, 4)
            }

            Text("Awareness is the first step to anchoring. You're doing the work.")
                .font(.system(.caption, design: .serif).italic())
                .foregroundColor(ABTheme.secondaryText.opacity(0.7))
        }
        .abCard()
    }

    // MARK: - Top Bloom Section
    private var topBloomSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "camera.macro")
                    .foregroundColor(ABTheme.sageGreen)
                Text("Your Strongest Callings")
                    .font(ABTheme.subheadlineFont)
                    .foregroundColor(ABTheme.primaryText)
            }

            ForEach(viewModel.topBloomRoles, id: \.role) { item in
                HStack {
                    Image(systemName: item.role.icon)
                        .foregroundColor(ABTheme.sageGreen)
                        .frame(width: 24)
                    Text(item.role.rawValue)
                        .font(.system(.body, design: .serif))
                        .foregroundColor(ABTheme.primaryText)
                    Spacer()
                    Text("\(item.count) days")
                        .font(.system(.caption, design: .serif, weight: .semibold))
                        .foregroundColor(ABTheme.secondaryText)
                }
                .padding(.vertical, 4)
            }

            Text("These roles reveal how God is shaping you. Keep walking in them.")
                .font(.system(.caption, design: .serif).italic())
                .foregroundColor(ABTheme.secondaryText.opacity(0.7))
        }
        .abCard()
    }

    // MARK: - Helper: 14-day activity data
    private struct DayActivity: Hashable {
        let date: Date
        let label: String
        let score: Int // 0 = nothing, 1 = partial, 2 = full
        var isFullDay: Bool { score == 2 }
        var isPartialDay: Bool { score == 1 }
    }

    private func last14DaysActivity() -> [DayActivity] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "d"

        return (0..<14).compactMap { offset -> DayActivity? in
            guard let date = Calendar.current.date(byAdding: .day, value: -13 + offset, to: Date()) else { return nil }
            let dateString = formatter.string(from: date)
            let entry = viewModel.recentEntries.first { $0.dateString == dateString }
            let score: Int
            if entry?.isFullyCompleted == true {
                score = 2
            } else if (entry?.anchorCompleted == true) || (entry?.bloomCompleted == true) {
                score = 1
            } else {
                score = 0
            }
            return DayActivity(date: date, label: dayFormatter.string(from: date), score: score)
        }
    }

    // MARK: - Journeys Tab
    private var journeysTab: some View {
        ScrollView {
            VStack(spacing: ABTheme.paddingLarge) {
                Text("Your Journeys")
                    .font(ABTheme.headlineFont)
                    .foregroundColor(ABTheme.primaryText)
                    .padding(.top, ABTheme.paddingMedium)

                ForEach(Journey.allJourneys) { journey in
                    let progress = viewModel.journeyProgress(for: journey.id)
                    let isActive = viewModel.userProfile?.activeJourneyID == journey.id

                    if progress > 0 || isActive {
                        // Started journey card
                        JourneyProgressCard(
                            journey: journey,
                            progress: progress,
                            isActive: isActive
                        )
                    }
                }

                // Not-started journeys
                let startedIDs = Journey.allJourneys
                    .filter { viewModel.journeyProgress(for: $0.id) > 0 || viewModel.userProfile?.activeJourneyID == $0.id }
                    .map { $0.id }

                let notStarted = Journey.allJourneys.filter { !startedIDs.contains($0.id) }
                if !notStarted.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Available Journeys")
                            .font(ABTheme.subheadlineFont)
                            .foregroundColor(ABTheme.secondaryText)

                        ForEach(notStarted) { journey in
                            HStack(spacing: 12) {
                                Image(systemName: journey.iconName)
                                    .font(.body)
                                    .foregroundColor(ABTheme.secondaryText.opacity(0.5))
                                    .frame(width: 30)

                                VStack(alignment: .leading, spacing: 2) {
                                    HStack {
                                        Text(journey.title)
                                            .font(.system(.subheadline, design: .serif, weight: .medium))
                                            .foregroundColor(ABTheme.secondaryText)
                                        if journey.isPremium {
                                            Image(systemName: "crown.fill")
                                                .font(.caption2)
                                                .foregroundColor(ABTheme.warmGold)
                                        }
                                    }
                                    Text("\(journey.totalDays) days · \(journey.scriptureTheme)")
                                        .font(.caption2)
                                        .foregroundColor(ABTheme.secondaryText.opacity(0.6))
                                }

                                Spacer()

                                Text("Not started")
                                    .font(.caption2)
                                    .foregroundColor(ABTheme.secondaryText.opacity(0.4))
                            }
                            .padding(.vertical, 6)
                        }
                    }
                    .abCard()
                }

                Spacer().frame(height: 40)
            }
            .padding(.horizontal, ABTheme.paddingMedium)
        }
    }

    // MARK: - Calendar Tab
    private var calendarTab: some View {
        ScrollView {
            VStack(spacing: ABTheme.paddingLarge) {
                Text("Streak Calendar")
                    .font(ABTheme.headlineFont)
                    .foregroundColor(ABTheme.primaryText)
                    .padding(.top, ABTheme.paddingMedium)

                // Simple calendar grid showing last 30 days
                StreakCalendarView(entries: viewModel.recentEntries)
                    .padding(.horizontal, ABTheme.paddingMedium)

                // Legend
                HStack(spacing: ABTheme.paddingMedium) {
                    LegendItem(color: ABTheme.sageGreen, label: "Full Day")
                    LegendItem(color: ABTheme.warmGold, label: "Partial")
                    LegendItem(color: ABTheme.sageGreen.opacity(0.15), label: "Missed")
                }
                .font(.caption)

                Spacer().frame(height: 40)
            }
        }
    }

    // MARK: - Badges Tab
    private var badgesTab: some View {
        ScrollView {
            VStack(spacing: ABTheme.paddingLarge) {
                Text("Badge Gallery")
                    .font(ABTheme.headlineFont)
                    .foregroundColor(ABTheme.primaryText)
                    .padding(.top, ABTheme.paddingMedium)

                ForEach(BadgeCategory.allCases, id: \.self) { category in
                    let badges = Badge.allBadges.filter { $0.category == category }
                    if !badges.isEmpty {
                        badgeCategorySection(category: category, badges: badges)
                    }
                }

                Spacer().frame(height: 40)
            }
            .padding(.horizontal, ABTheme.paddingMedium)
        }
    }

    // MARK: - Weekly Breakdown
    private var weeklyBreakdown: some View {
        VStack(alignment: .leading, spacing: ABTheme.paddingSmall) {
            Text("This Week")
                .font(ABTheme.subheadlineFont)
                .foregroundColor(ABTheme.primaryText)

            let last7 = viewModel.recentEntries.suffix(7)
            let anchors = last7.filter { $0.anchorCompleted }.count
            let blooms = last7.filter { $0.bloomCompleted }.count
            let drifts = last7.flatMap { $0.driftEntries }.count

            HStack(spacing: ABTheme.paddingMedium) {
                WeekStatPill(icon: "sunrise.fill", value: "\(anchors)", label: "Anchors", color: ABTheme.warmGold)
                WeekStatPill(icon: "camera.macro", value: "\(blooms)", label: "Blooms", color: ABTheme.blush)
                WeekStatPill(icon: "water.waves", value: "\(drifts)", label: "Drifts", color: ABTheme.sageGreen)
            }
        }
        .abCard()
    }

    // MARK: - Badge Category Section
    private func badgeCategorySection(category: BadgeCategory, badges: [Badge]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: category.icon)
                    .foregroundColor(ABTheme.warmGold)
                Text(category.rawValue)
                    .font(ABTheme.subheadlineFont)
                    .foregroundColor(ABTheme.primaryText)
            }

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(badges) { badge in
                    let isEarned = viewModel.userProfile?.earnedBadgeIDs.contains(badge.id) ?? false
                    BadgeCard(badge: badge, isEarned: isEarned)
                }
            }
        }
    }
}

// MARK: - Progress Stat Card
struct ProgressStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)

            Text(value)
                .font(.system(.title3, design: .serif, weight: .bold))
                .foregroundColor(ABTheme.primaryText)

            Text(title)
                .font(.system(.caption, design: .serif))
                .foregroundColor(ABTheme.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .abCard()
    }
}

// MARK: - Week Stat Pill
struct WeekStatPill: View {
    let icon: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(color)
            Text(value)
                .font(.system(.headline, design: .serif, weight: .bold))
                .foregroundColor(ABTheme.primaryText)
            Text(label)
                .font(.system(.caption2, design: .serif))
                .foregroundColor(ABTheme.secondaryText)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Streak Calendar View
struct StreakCalendarView: View {
    let entries: [DailyEntry]

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)
    private let dayLabels = ["S", "M", "T", "W", "T", "F", "S"]

    var body: some View {
        VStack(spacing: 4) {
            // Day headers
            HStack(spacing: 4) {
                ForEach(dayLabels, id: \.self) { day in
                    Text(day)
                        .font(.system(.caption2, design: .serif, weight: .semibold))
                        .foregroundColor(ABTheme.secondaryText)
                        .frame(maxWidth: .infinity)
                }
            }

            // Last 35 days grid
            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(last35Days(), id: \.self) { date in
                    let entry = entryForDate(date)
                    CalendarDayCell(
                        date: date,
                        isFullyCompleted: entry?.isFullyCompleted ?? false,
                        isPartiallyCompleted: (entry?.anchorCompleted ?? false) || (entry?.bloomCompleted ?? false),
                        isToday: Calendar.current.isDateInToday(date)
                    )
                }
            }
        }
        .abCard()
    }

    private func last35Days() -> [Date] {
        (0..<35).compactMap { offset in
            Calendar.current.date(byAdding: .day, value: -34 + offset, to: Date())
        }
    }

    private func entryForDate(_ date: Date) -> DailyEntry? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: date)
        return entries.first { $0.dateString == dateString }
    }
}

// MARK: - Calendar Day Cell
struct CalendarDayCell: View {
    let date: Date
    let isFullyCompleted: Bool
    let isPartiallyCompleted: Bool
    let isToday: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 6)
                .fill(cellColor)
                .frame(height: 36)

            VStack(spacing: 1) {
                Text("\(Calendar.current.component(.day, from: date))")
                    .font(.system(.caption2, weight: isToday ? .bold : .regular))
                    .foregroundColor(cellTextColor)

                if isFullyCompleted {
                    Circle()
                        .fill(Color.white.opacity(0.8))
                        .frame(width: 4, height: 4)
                }
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(isToday ? ABTheme.sageGreen : Color.clear, lineWidth: 2)
        )
    }

    private var cellColor: Color {
        if isFullyCompleted { return ABTheme.sageGreen }
        if isPartiallyCompleted { return ABTheme.warmGold.opacity(0.5) }
        return ABTheme.sageGreen.opacity(0.08)
    }

    private var cellTextColor: Color {
        if isFullyCompleted { return .white }
        if isPartiallyCompleted { return ABTheme.primaryText }
        return ABTheme.secondaryText
    }
}

// MARK: - Legend Item
struct LegendItem: View {
    let color: Color
    let label: String

    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)
            Text(label)
                .foregroundColor(ABTheme.secondaryText)
        }
    }
}

// MARK: - Badge Card
struct BadgeCard: View {
    let badge: Badge
    let isEarned: Bool

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: badge.iconName)
                .font(.title2)
                .foregroundColor(isEarned ? ABTheme.warmGold : ABTheme.secondaryText.opacity(0.3))

            Text(badge.name)
                .font(.system(.caption2, design: .serif, weight: .medium))
                .foregroundColor(isEarned ? ABTheme.primaryText : ABTheme.secondaryText.opacity(0.5))
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Text(badge.description)
                .font(.system(size: 10))
                .foregroundColor(ABTheme.secondaryText.opacity(isEarned ? 0.8 : 0.3))
                .lineLimit(2)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .padding(.horizontal, 4)
        .background(isEarned ? ABTheme.warmGoldLight.opacity(0.2) : ABTheme.cardBackground)
        .cornerRadius(ABTheme.cornerRadiusSmall)
        .overlay(
            RoundedRectangle(cornerRadius: ABTheme.cornerRadiusSmall)
                .stroke(isEarned ? ABTheme.warmGold.opacity(0.3) : Color.clear, lineWidth: 1)
        )
        .opacity(isEarned ? 1 : 0.5)
    }
}

// MARK: - Journey Progress Card
struct JourneyProgressCard: View {
    let journey: Journey
    let progress: Int
    let isActive: Bool

    private var percentage: Int {
        guard journey.totalDays > 0 else { return 0 }
        return Int(Double(progress) / Double(journey.totalDays) * 100)
    }

    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: journey.iconName)
                    .font(.title3)
                    .foregroundColor(ABTheme.sageGreen)
                    .frame(width: 36)

                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text(journey.title)
                            .font(.system(.body, design: .serif, weight: .semibold))
                            .foregroundColor(ABTheme.primaryText)

                        if isActive {
                            Text("ACTIVE")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(ABTheme.sageGreen)
                                .cornerRadius(4)
                        }
                    }

                    Text(progress >= journey.totalDays
                         ? "Completed!"
                         : "Day \(progress) of \(journey.totalDays)")
                        .font(.system(.caption, design: .serif))
                        .foregroundColor(progress >= journey.totalDays ? ABTheme.warmGold : ABTheme.secondaryText)
                }

                Spacer()

                Text("\(percentage)%")
                    .font(.system(.headline, design: .serif, weight: .bold))
                    .foregroundColor(ABTheme.sageGreen)
            }

            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(ABTheme.sageGreen.opacity(0.12))
                        .frame(height: 6)

                    RoundedRectangle(cornerRadius: 3)
                        .fill(progress >= journey.totalDays ? ABTheme.warmGold : ABTheme.sageGreen)
                        .frame(width: journey.totalDays > 0 ? geo.size.width * CGFloat(progress) / CGFloat(journey.totalDays) : 0, height: 6)
                }
            }
            .frame(height: 6)
        }
        .abCard()
    }
}

// MARK: - Goal Card
struct GoalCard: View {
    let goal: SpiritualGoal
    @ObservedObject var viewModel: AppViewModel
    @State private var showDeleteConfirm = false

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 10) {
                Image(systemName: goal.category.icon)
                    .foregroundColor(goal.isCompleted ? ABTheme.warmGold : ABTheme.sageGreen)
                    .frame(width: 24)

                VStack(alignment: .leading, spacing: 2) {
                    Text(goal.title)
                        .font(.system(.subheadline, design: .serif, weight: .semibold))
                        .foregroundColor(ABTheme.primaryText)
                        .strikethrough(goal.isCompleted)

                    Text(goal.isCompleted
                         ? "Completed!"
                         : "\(goal.completedDays)/\(goal.targetDays) days")
                        .font(.caption2)
                        .foregroundColor(goal.isCompleted ? ABTheme.warmGold : ABTheme.secondaryText)
                }

                Spacer()

                if !goal.isCompleted {
                    Button {
                        guard let id = goal.id else { return }
                        Task { await viewModel.incrementGoal(id) }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                            .foregroundColor(ABTheme.sageGreen)
                    }
                } else {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundColor(ABTheme.warmGold)
                }
            }

            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(ABTheme.sageGreen.opacity(0.12))
                        .frame(height: 4)
                    RoundedRectangle(cornerRadius: 2)
                        .fill(goal.isCompleted ? ABTheme.warmGold : ABTheme.sageGreen)
                        .frame(width: geo.size.width * CGFloat(goal.progressPercentage), height: 4)
                }
            }
            .frame(height: 4)
        }
        .padding(10)
        .background(ABTheme.cardBackground)
        .cornerRadius(ABTheme.cornerRadiusSmall)
        .contextMenu {
            Button(role: .destructive) {
                guard let id = goal.id else { return }
                Task { await viewModel.deleteGoal(id) }
            } label: {
                Label("Delete Goal", systemImage: "trash")
            }
        }
    }
}

// MARK: - Create Goal View
struct CreateGoalView: View {
    @ObservedObject var viewModel: AppViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var selectedCategory: GoalCategory = .prayer
    @State private var targetDays = 7
    @State private var isSaving = false

    private let targetOptions = [7, 14, 21, 30, 40, 60, 90]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: ABTheme.paddingLarge) {
                    // Category picker
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Category")
                            .font(ABTheme.subheadlineFont)
                            .foregroundColor(ABTheme.primaryText)

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                            ForEach(GoalCategory.allCases, id: \.self) { category in
                                Button {
                                    selectedCategory = category
                                } label: {
                                    VStack(spacing: 4) {
                                        Image(systemName: category.icon)
                                            .font(.title3)
                                        Text(category.rawValue)
                                            .font(.system(.caption2, design: .serif))
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.8)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(selectedCategory == category ? ABTheme.sageGreen : ABTheme.cardBackground)
                                    .foregroundColor(selectedCategory == category ? .white : ABTheme.primaryText)
                                    .cornerRadius(ABTheme.cornerRadiusSmall)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    // Goal title
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Your Goal")
                            .font(ABTheme.subheadlineFont)
                            .foregroundColor(ABTheme.primaryText)

                        TextField("e.g., Pray for 10 minutes daily", text: $title)
                            .font(ABTheme.bodyFont)
                            .padding()
                            .background(ABTheme.softWhite)
                            .cornerRadius(ABTheme.cornerRadiusSmall)
                            .overlay(
                                RoundedRectangle(cornerRadius: ABTheme.cornerRadiusSmall)
                                    .stroke(ABTheme.sageGreen.opacity(0.2), lineWidth: 1)
                            )
                    }

                    // Target days
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Duration")
                            .font(ABTheme.subheadlineFont)
                            .foregroundColor(ABTheme.primaryText)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(targetOptions, id: \.self) { days in
                                    Button {
                                        targetDays = days
                                    } label: {
                                        Text("\(days) days")
                                            .font(.system(.caption, design: .serif, weight: .semibold))
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 10)
                                            .background(targetDays == days ? ABTheme.sageGreen : ABTheme.cardBackground)
                                            .foregroundColor(targetDays == days ? .white : ABTheme.primaryText)
                                            .cornerRadius(20)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }

                    // Create button
                    Button {
                        isSaving = true
                        Task {
                            await viewModel.createGoal(
                                title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                                category: selectedCategory,
                                targetDays: targetDays
                            )
                            dismiss()
                        }
                    } label: {
                        HStack {
                            Image(systemName: "target")
                            Text("Set This Goal")
                        }
                    }
                    .buttonStyle(ABPrimaryButtonStyle())
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSaving)
                }
                .padding(ABTheme.paddingLarge)
            }
            .abScreenBackground()
            .navigationTitle("New Spiritual Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(ABTheme.sageGreen)
                }
            }
        }
    }
}

#Preview {
    ProgressStatsView(viewModel: AppViewModel(firestoreService: FirestoreService()))
        .environmentObject(SubscriptionManager())
}
