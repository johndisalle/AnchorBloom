import SwiftUI

// MARK: - Drift History View
/// Shows drift patterns and trends over time
struct DriftHistoryView: View {
    @EnvironmentObject var firestoreService: FirestoreService

    @State private var entries: [DailyEntry] = []
    @State private var isLoading = false
    @State private var selectedPeriod: TimePeriod = .week

    enum TimePeriod: String, CaseIterable {
        case week = "7 Days"
        case month = "30 Days"
        case allTime = "All Time"

        var days: Int {
            switch self {
            case .week: return 7
            case .month: return 30
            case .allTime: return 365
            }
        }
    }

    private var allDrifts: [DriftEntry] {
        entries.flatMap { $0.driftEntries }
    }

    private var categoryBreakdown: [(category: DriftCategory, count: Int, percentage: Double)] {
        let total = max(allDrifts.count, 1)
        var counts: [DriftCategory: Int] = [:]
        for drift in allDrifts {
            counts[drift.category, default: 0] += 1
        }
        return counts
            .map { (category: $0.key, count: $0.value, percentage: Double($0.value) / Double(total) * 100) }
            .sorted { $0.count > $1.count }
    }

    private var driftsByDay: [(date: String, count: Int)] {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        var dayCounts: [String: Int] = [:]
        for entry in entries {
            let dayName = formatter.string(from: entry.date)
            dayCounts[dayName, default: 0] += entry.driftEntries.count
        }
        let dayOrder = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        return dayOrder.map { (date: $0, count: dayCounts[$0] ?? 0) }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: ABTheme.paddingLarge) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "chart.bar.fill")
                        .font(.title)
                        .foregroundColor(ABTheme.blush)

                    Text("Drift Patterns")
                        .font(ABTheme.headlineFont)
                        .foregroundColor(ABTheme.primaryText)

                    Text("Understanding your patterns helps you grow")
                        .font(ABTheme.captionFont)
                        .foregroundColor(ABTheme.secondaryText)
                }
                .padding(.top, ABTheme.paddingSmall)

                // Period selector
                Picker("Period", selection: $selectedPeriod) {
                    ForEach(TimePeriod.allCases, id: \.self) { period in
                        Text(period.rawValue).tag(period)
                    }
                }
                .pickerStyle(.segmented)
                .onChange(of: selectedPeriod) {
                    Task { await loadEntries() }
                }

                if isLoading {
                    ProgressView()
                        .tint(ABTheme.sageGreen)
                        .padding(.top, 30)
                } else if allDrifts.isEmpty {
                    emptyState
                } else {
                    // Summary stat
                    summaryCard

                    // Category breakdown
                    categoryBreakdownCard

                    // Day-of-week pattern
                    dayPatternCard

                    // Recent drift timeline
                    recentDriftsCard
                }

                Spacer().frame(height: 40)
            }
            .padding(.horizontal, ABTheme.paddingMedium)
        }
        .abScreenBackground()
        .navigationTitle("Drift History")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadEntries()
        }
    }

    // MARK: - Summary Card
    private var summaryCard: some View {
        HStack(spacing: 0) {
            statItem(
                value: "\(allDrifts.count)",
                label: "Total Drifts",
                icon: "water.waves"
            )

            divider

            statItem(
                value: categoryBreakdown.first?.category.rawValue ?? "—",
                label: "Top Drift",
                icon: "arrow.up.circle.fill"
            )

            divider

            statItem(
                value: String(format: "%.0f%%", categoryBreakdown.first?.percentage ?? 0),
                label: "of Total",
                icon: "chart.pie.fill"
            )
        }
        .abCard()
    }

    private func statItem(value: String, label: String, icon: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(ABTheme.blush)
            Text(value)
                .font(.system(.subheadline, design: .serif, weight: .bold))
                .foregroundColor(ABTheme.primaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(label)
                .font(.caption2)
                .foregroundColor(ABTheme.secondaryText)
        }
        .frame(maxWidth: .infinity)
    }

    private var divider: some View {
        Rectangle()
            .fill(ABTheme.secondaryText.opacity(0.15))
            .frame(width: 1, height: 40)
    }

    // MARK: - Category Breakdown
    private var categoryBreakdownCard: some View {
        VStack(alignment: .leading, spacing: ABTheme.paddingMedium) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .foregroundColor(ABTheme.blush)
                Text("Where You Drift Most")
                    .font(ABTheme.subheadlineFont)
                    .foregroundColor(ABTheme.primaryText)
            }

            ForEach(categoryBreakdown.prefix(5), id: \.category) { item in
                HStack(spacing: 12) {
                    Image(systemName: item.category.icon)
                        .font(.caption)
                        .foregroundColor(ABTheme.blush)
                        .frame(width: 20)

                    Text(item.category.rawValue)
                        .font(.system(.caption, design: .serif, weight: .medium))
                        .foregroundColor(ABTheme.primaryText)
                        .frame(width: 90, alignment: .leading)

                    // Progress bar
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(ABTheme.blush.opacity(0.15))
                                .frame(height: 8)

                            RoundedRectangle(cornerRadius: 4)
                                .fill(ABTheme.blush)
                                .frame(width: geo.size.width * item.percentage / 100, height: 8)
                        }
                    }
                    .frame(height: 8)

                    Text("\(item.count)")
                        .font(.system(.caption2, design: .serif, weight: .bold))
                        .foregroundColor(ABTheme.secondaryText)
                        .frame(width: 24, alignment: .trailing)
                }
            }

            // Encouragement based on top drift
            if let top = categoryBreakdown.first {
                HStack(spacing: 8) {
                    Image(systemName: "sparkles")
                        .foregroundColor(ABTheme.warmGold)
                        .font(.caption)
                    Text(encouragement(for: top.category))
                        .font(.system(.caption, design: .serif).italic())
                        .foregroundColor(ABTheme.secondaryText)
                        .lineSpacing(2)
                }
                .padding(ABTheme.paddingSmall)
                .background(ABTheme.warmGoldLight.opacity(0.3))
                .cornerRadius(ABTheme.cornerRadiusSmall)
            }
        }
        .abCard()
    }

    // MARK: - Day Pattern Card
    private var dayPatternCard: some View {
        VStack(alignment: .leading, spacing: ABTheme.paddingMedium) {
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(ABTheme.sageGreen)
                Text("When You Drift")
                    .font(ABTheme.subheadlineFont)
                    .foregroundColor(ABTheme.primaryText)
            }

            HStack(alignment: .bottom, spacing: 6) {
                let maxCount = max(driftsByDay.map(\.count).max() ?? 1, 1)
                ForEach(driftsByDay, id: \.date) { day in
                    VStack(spacing: 4) {
                        Text("\(day.count)")
                            .font(.system(size: 9, weight: .bold, design: .serif))
                            .foregroundColor(ABTheme.secondaryText)

                        RoundedRectangle(cornerRadius: 4)
                            .fill(day.count == maxCount ? ABTheme.blush : ABTheme.sageGreen.opacity(0.4))
                            .frame(height: max(4, CGFloat(day.count) / CGFloat(maxCount) * 60))

                        Text(day.date)
                            .font(.system(size: 9, weight: .medium, design: .serif))
                            .foregroundColor(ABTheme.secondaryText)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 90)
        }
        .abCard()
    }

    // MARK: - Recent Drifts Card
    private var recentDriftsCard: some View {
        VStack(alignment: .leading, spacing: ABTheme.paddingMedium) {
            HStack {
                Image(systemName: "clock.fill")
                    .foregroundColor(ABTheme.warmGold)
                Text("Recent Drifts")
                    .font(ABTheme.subheadlineFont)
                    .foregroundColor(ABTheme.primaryText)
            }

            let recentDrifts = allDrifts
                .sorted { $0.timestamp > $1.timestamp }
                .prefix(10)

            ForEach(Array(recentDrifts), id: \.id) { drift in
                HStack(spacing: 12) {
                    Image(systemName: drift.category.icon)
                        .foregroundColor(ABTheme.blush)
                        .frame(width: 24)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(drift.category.rawValue)
                            .font(.system(.subheadline, design: .serif, weight: .medium))
                            .foregroundColor(ABTheme.primaryText)

                        if let note = drift.note, !note.isEmpty {
                            Text(note)
                                .font(.caption)
                                .foregroundColor(ABTheme.secondaryText)
                                .lineLimit(1)
                        }
                    }

                    Spacer()

                    Text(drift.timestamp, style: .relative)
                        .font(.caption2)
                        .foregroundColor(ABTheme.secondaryText)
                }
                .padding(.vertical, 4)

                if drift.id != recentDrifts.last?.id {
                    Divider()
                }
            }
        }
        .abCard()
    }

    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: ABTheme.paddingMedium) {
            Image(systemName: "chart.bar")
                .font(.system(size: 48))
                .foregroundColor(ABTheme.blush.opacity(0.4))

            Text("No drift data yet")
                .font(ABTheme.subheadlineFont)
                .foregroundColor(ABTheme.primaryText)

            Text("As you log drifts, patterns will appear here\nto help you understand your growth areas.")
                .font(ABTheme.captionFont)
                .foregroundColor(ABTheme.secondaryText)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 40)
    }

    // MARK: - Helpers
    private func loadEntries() async {
        isLoading = true
        defer { isLoading = false }
        let from = Calendar.current.date(byAdding: .day, value: -selectedPeriod.days, to: Date()) ?? Date()
        entries = (try? await firestoreService.fetchEntries(from: from, to: Date())) ?? []
    }

    private func encouragement(for category: DriftCategory) -> String {
        switch category {
        case .comparison:
            return "You're becoming aware of comparison's pull. Remember: God made you uniquely on purpose."
        case .perfectionism:
            return "Grace over perfection. His power is made perfect in your weakness."
        case .envy:
            return "Awareness of envy opens the door to gratitude. Count your blessings today."
        case .peoplepleasing:
            return "You're growing in living for an audience of One. Freedom is ahead."
        case .anger:
            return "Bringing anger to God is a sign of trust. He can handle your honest heart."
        case .selfPity:
            return "Recognizing self-pity takes courage. God is turning your mourning into dancing."
        case .impatience:
            return "Patience is a fruit that grows slowly. You're right on schedule."
        case .doubt:
            return "Even honest doubt can deepen faith. Keep bringing it to Him."
        case .temptation:
            return "Recognizing temptation is half the battle. God always provides a way out."
        case .selfReliance:
            return "Leaning on God isn't weakness — it's the strongest thing you can do."
        case .lust:
            return "Your awareness is a victory. God is purifying your heart one step at a time."
        case .avoidance:
            return "Courage isn't the absence of fear — it's moving forward with God beside you."
        case .anxiety:
            return "Cast your cares on Him. He's big enough to carry every one of them."
        case .distraction:
            return "Refocusing on God is never wasted. Fix your eyes on Jesus today."
        case .laziness:
            return "God gave you this day on purpose. Even one small step honors Him."
        }
    }
}
