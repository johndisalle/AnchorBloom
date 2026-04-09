import SwiftUI

// MARK: - Dashboard View (Home)
/// Focused daily companion: greeting, one action, scripture, tree, active journey.
/// Everything else lives in Discover, Community, or Profile tabs.
struct DashboardView: View {
    @EnvironmentObject var firestoreService: FirestoreService
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @StateObject private var viewModel = AppViewModel(firestoreService: FirestoreService())
    @State private var showAnchorSheet = false
    @State private var showBloomSheet = false
    @State private var showJourneyProgress = false

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        let name = viewModel.userProfile?.displayName.components(separatedBy: " ").first ?? "beautiful"
        switch hour {
        case 0..<12: return "Good morning, \(name)"
        case 12..<17: return "Good afternoon, \(name)"
        default: return "Good evening, \(name)"
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
                    // 1. HEADER — greeting + streak badge
                    headerRow

                    // 2. THE ACTION — one clear, unmissable CTA
                    todayActionCard

                    // 3. TODAY'S SCRIPTURE — subtle, beautiful
                    todayScripture

                    // 4. BLOOMING TREE — hero visual with compact stats
                    treeHero

                    // 5. ACTIVE JOURNEY — only if user has one in progress
                    if let journey = viewModel.activeJourney {
                        activeJourneyBar(journey)
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
            .fullScreenCover(isPresented: $showJourneyProgress) {
                if let journey = viewModel.activeJourney {
                    JourneyProgressView(journey: journey, viewModel: viewModel)
                }
            }
        }
    }

    // MARK: - 1. Header Row

    private var headerRow: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text(greeting)
                    .font(ABTheme.headlineFont)
                    .foregroundColor(ABTheme.primaryText)

                Text(dateString)
                    .font(ABTheme.captionFont)
                    .foregroundColor(ABTheme.secondaryText)
            }

            Spacer()

            // Streak badge
            let streak = viewModel.userProfile?.currentStreak ?? 0
            if streak > 0 {
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.orange)
                    Text("\(streak)")
                        .font(.system(.body, design: .serif, weight: .bold))
                        .foregroundColor(ABTheme.primaryText)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.orange.opacity(0.1))
                .cornerRadius(20)
            }
        }
        .padding(.top, ABTheme.paddingMedium)
    }

    // MARK: - 2. Today's Action Card

    private var todayActionCard: some View {
        let anchorDone = viewModel.todayEntry?.anchorCompleted ?? false
        let bloomDone = viewModel.todayEntry?.bloomCompleted ?? false
        let hour = Calendar.current.component(.hour, from: Date())
        let isMorning = hour < 14

        return Group {
            if anchorDone && bloomDone {
                // BOTH COMPLETE — celebration
                fullyRootedCard
            } else if !anchorDone && (isMorning || !bloomDone) {
                // ANCHOR NEEDED — primary action
                actionHeroCard(
                    title: "Anchor Your Morning",
                    subtitle: "Start your day rooted in God's truth. Don't let the enemy set the tone.",
                    icon: "sunrise.fill",
                    accentColor: ABTheme.warmGold,
                    isAnchor: true
                )
            } else if anchorDone && !bloomDone {
                // ANCHOR DONE, BLOOM PENDING
                splitProgressCard
            } else {
                // BLOOM NEEDED (afternoon, anchor not done either)
                actionHeroCard(
                    title: "Time to Bloom",
                    subtitle: "Reflect on how God worked through you today. Celebrate who He's making you.",
                    icon: "camera.macro",
                    accentColor: ABTheme.blush,
                    isAnchor: false
                )
            }
        }
    }

    private func actionHeroCard(title: String, subtitle: String, icon: String, accentColor: Color, isAnchor: Bool) -> some View {
        Button {
            if isAnchor { showAnchorSheet = true } else { showBloomSheet = true }
        } label: {
            VStack(spacing: 16) {
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(accentColor.opacity(0.15))
                            .frame(width: 56, height: 56)
                        Image(systemName: icon)
                            .font(.system(size: 24))
                            .foregroundColor(accentColor)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(.system(.title3, design: .serif, weight: .bold))
                            .foregroundColor(ABTheme.primaryText)
                        Text("Tap to begin")
                            .font(.system(.caption, design: .serif, weight: .medium))
                            .foregroundColor(accentColor)
                    }

                    Spacer()

                    Image(systemName: "arrow.right.circle.fill")
                        .font(.title2)
                        .foregroundColor(accentColor)
                }

                Text(subtitle)
                    .font(.system(.subheadline, design: .serif))
                    .foregroundColor(ABTheme.secondaryText)
                    .lineSpacing(3)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(ABTheme.paddingLarge)
            .background(
                RoundedRectangle(cornerRadius: ABTheme.cornerRadius)
                    .fill(ABTheme.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: ABTheme.cornerRadius)
                            .stroke(accentColor.opacity(0.25), lineWidth: 1.5)
                    )
            )
            .shadow(color: accentColor.opacity(0.12), radius: 10, y: 4)
        }
        .buttonStyle(.plain)
    }

    private var splitProgressCard: some View {
        HStack(spacing: 0) {
            // Anchor — completed
            Button { showAnchorSheet = true } label: {
                VStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(ABTheme.sageGreen)
                    Text("Anchored")
                        .font(.system(.caption, design: .serif, weight: .semibold))
                        .foregroundColor(ABTheme.sageGreen)
                    Text("This morning")
                        .font(.caption2)
                        .foregroundColor(ABTheme.secondaryText)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, ABTheme.paddingLarge)
                .background(ABTheme.sageGreen.opacity(0.06))
            }

            // Divider
            Rectangle()
                .fill(ABTheme.secondaryText.opacity(0.1))
                .frame(width: 1)

            // Bloom — pending
            Button { showBloomSheet = true } label: {
                VStack(spacing: 8) {
                    Image(systemName: "moon.stars.fill")
                        .font(.title2)
                        .foregroundColor(ABTheme.blush)
                    Text("Bloom Tonight")
                        .font(.system(.caption, design: .serif, weight: .semibold))
                        .foregroundColor(ABTheme.blush)
                    Text("Tap to begin")
                        .font(.caption2)
                        .foregroundColor(ABTheme.secondaryText)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, ABTheme.paddingLarge)
                .background(ABTheme.blush.opacity(0.04))
            }
        }
        .buttonStyle(.plain)
        .cornerRadius(ABTheme.cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: ABTheme.cornerRadius)
                .stroke(ABTheme.secondaryText.opacity(0.1), lineWidth: 1)
        )
    }

    private var fullyRootedCard: some View {
        VStack(spacing: 12) {
            HStack(spacing: 16) {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(ABTheme.sageGreen)
                    Text("Anchored")
                        .font(.system(.caption, design: .serif, weight: .semibold))
                        .foregroundColor(ABTheme.sageGreen)
                }

                HStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(ABTheme.blush)
                    Text("Bloomed")
                        .font(.system(.caption, design: .serif, weight: .semibold))
                        .foregroundColor(ABTheme.blush)
                }
            }

            Text("Fully Rooted Today")
                .font(.system(.body, design: .serif, weight: .bold))
                .foregroundColor(ABTheme.primaryText)

            Text("You anchored in truth this morning and bloomed in purpose tonight. Well done, sister.")
                .font(.system(.caption, design: .serif))
                .foregroundColor(ABTheme.secondaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(2)
        }
        .padding(ABTheme.paddingLarge)
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                colors: [ABTheme.sageGreen.opacity(0.06), ABTheme.blush.opacity(0.06)],
                startPoint: .leading, endPoint: .trailing
            )
        )
        .cornerRadius(ABTheme.cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: ABTheme.cornerRadius)
                .stroke(ABTheme.sageGreen.opacity(0.15), lineWidth: 1)
        )
    }

    // MARK: - 3. Today's Scripture

    private var todayScripture: some View {
        let prompt = DailyPrompt.morningPrompts[
            (Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1 - 1) % DailyPrompt.morningPrompts.count
        ]
        return VStack(spacing: 8) {
            Text(prompt.scripture)
                .font(.system(.subheadline, design: .serif).italic())
                .foregroundColor(ABTheme.primaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            Text("— \(prompt.scriptureReference)")
                .font(.system(size: 12, weight: .semibold, design: .serif))
                .foregroundColor(ABTheme.sageGreen)
        }
        .padding(.vertical, ABTheme.paddingMedium)
        .padding(.horizontal, ABTheme.paddingLarge)
        .frame(maxWidth: .infinity)
        .background(ABTheme.sageGreen.opacity(0.06))
        .cornerRadius(ABTheme.cornerRadius)
    }

    // MARK: - 4. Tree Hero

    private var treeHero: some View {
        VStack(spacing: ABTheme.paddingMedium) {
            BloomingTreeView(
                growthLevel: viewModel.treeGrowthLevel,
                bloomCount: viewModel.bloomCount,
                fruitCount: viewModel.fruitCount,
                streakDays: viewModel.currentStreak
            )

            // Compact stats row
            HStack(spacing: 0) {
                miniStat(value: "\(viewModel.currentStreak)", label: "Streak", icon: "flame.fill", color: .orange)
                miniDivider
                miniStat(value: "\(viewModel.totalDays)", label: "Total Days", icon: "calendar", color: ABTheme.sageGreen)
                miniDivider
                miniStat(value: "\(viewModel.earnedBadges.count)", label: "Badges", icon: "star.fill", color: ABTheme.warmGold)
            }
            .padding(.vertical, 10)
            .background(ABTheme.cardBackground)
            .cornerRadius(ABTheme.cornerRadiusSmall)
        }
        .abCard()
    }

    private func miniStat(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 3) {
            HStack(spacing: 3) {
                Image(systemName: icon)
                    .font(.system(size: 10))
                    .foregroundColor(color)
                Text(value)
                    .font(.system(.body, design: .serif, weight: .bold))
                    .foregroundColor(ABTheme.primaryText)
            }
            Text(label)
                .font(.system(size: 10))
                .foregroundColor(ABTheme.secondaryText)
        }
        .frame(maxWidth: .infinity)
    }

    private var miniDivider: some View {
        Rectangle()
            .fill(ABTheme.secondaryText.opacity(0.12))
            .frame(width: 1, height: 28)
    }

    // MARK: - 5. Active Journey Bar

    private func activeJourneyBar(_ journey: Journey) -> some View {
        let progress = viewModel.journeyProgress(for: journey.id)
        let nextDay = min(progress + 1, journey.totalDays)

        return Button { showJourneyProgress = true } label: {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(ABTheme.sageGreen.opacity(0.12))
                        .frame(width: 42, height: 42)
                    Image(systemName: journey.iconName)
                        .font(.body)
                        .foregroundColor(ABTheme.sageGreen)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(journey.title)
                        .font(.system(.subheadline, design: .serif, weight: .semibold))
                        .foregroundColor(ABTheme.primaryText)
                        .lineLimit(1)

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

                Text("Day \(nextDay)")
                    .font(.system(.caption, design: .serif, weight: .semibold))
                    .foregroundColor(ABTheme.sageGreen)

                Image(systemName: "chevron.right")
                    .font(.caption2)
                    .foregroundColor(ABTheme.secondaryText)
            }
            .padding(ABTheme.paddingMedium)
            .background(ABTheme.cardBackground)
            .cornerRadius(ABTheme.cornerRadius)
            .shadow(color: ABTheme.cardShadow, radius: 4, x: 0, y: 1)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Reusable Components (preserved from original)

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
