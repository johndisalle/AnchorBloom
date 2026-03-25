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

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: ABTheme.paddingLarge) {
                    // Header
                    headerSection

                    // Tree visualization
                    treeSection

                    // Active journey card
                    if let journey = viewModel.activeJourney {
                        activeJourneyCard(journey)
                    }

                    // Daily action cards
                    dailyActionsSection

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
        }
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

    // MARK: - Daily Actions
    private var dailyActionsSection: some View {
        VStack(spacing: ABTheme.paddingMedium) {
            // Morning Anchor Card
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

            // Evening Bloom Card
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
        }
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
