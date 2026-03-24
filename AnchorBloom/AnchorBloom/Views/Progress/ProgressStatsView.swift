import SwiftUI

// MARK: - Progress & Stats View
/// Tree visualization, streak calendar, badge gallery, weekly summaries
struct ProgressStatsView: View {
    @ObservedObject var viewModel: AppViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var selectedTab = 0

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Segmented picker
                Picker("", selection: $selectedTab) {
                    Text("Growth").tag(0)
                    Text("Calendar").tag(1)
                    Text("Badges").tag(2)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, ABTheme.paddingMedium)
                .padding(.top, ABTheme.paddingSmall)

                TabView(selection: $selectedTab) {
                    growthTab.tag(0)
                    calendarTab.tag(1)
                    badgesTab.tag(2)
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

                Spacer().frame(height: 40)
            }
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
                WeekStatPill(icon: "anchor.circle.fill", value: "\(drifts)", label: "Drifts", color: ABTheme.sageGreen)
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
                .font(.system(size: 8))
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

#Preview {
    ProgressStatsView(viewModel: AppViewModel(firestoreService: FirestoreService()))
}
