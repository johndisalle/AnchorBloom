import SwiftUI

// MARK: - Dashboard View (Home)
/// Focused daily companion: greeting, one action, AI companion, scripture, tree, active journey.
struct DashboardView: View {
    @EnvironmentObject var firestoreService: FirestoreService
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @StateObject private var viewModel = AppViewModel(firestoreService: FirestoreService())
    @StateObject private var aiService = ClaudeAIService()

    @State private var showAnchorSheet = false
    @State private var showBloomSheet = false
    @State private var showJourneyProgress = false
    @State private var showAICompanion = false

    private var hour: Int {
        Calendar.current.component(.hour, from: Date())
    }

    private var greeting: String {
        let name = viewModel.userProfile?.displayName.components(separatedBy: " ").first ?? "sister"
        switch hour {
        case 5..<12: return "Good morning, \(name)"
        case 12..<17: return "Good afternoon, \(name)"
        case 17..<21: return "Good evening, \(name)"
        default: return "Rest well, \(name)"
        }
    }

    private var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: Date())
    }

    // MARK: - Contextual CTA text

    private var actionCTAText: String {
        let streak = viewModel.userProfile?.currentStreak ?? 0
        let totalDays = viewModel.userProfile?.totalDaysCompleted ?? 0

        if totalDays == 0 { return "Start your first anchor" }
        if streak > 3 { return "Keep your \(streak)-day streak alive" }
        return "Tap to begin"
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: ABTheme.paddingLarge) {
                    // 1. HEADER — greeting + streak badge
                    headerRow

                    // 2. THE ACTION — state-driven, not time-driven
                    todayActionCard

                    // 3. AI COMPANION — surfaced, visible, the star feature
                    aiCompanionCard

                    // 4. TODAY'S SCRIPTURE — tappable to bookmark/share
                    todayScripture

                    // 5. BLOOMING TREE — hero visual with compact stats
                    treeHero

                    // 6. ACTIVE JOURNEY — only if user has one in progress
                    if let journey = viewModel.activeJourney {
                        activeJourneyBar(journey)
                    }

                    Spacer().frame(height: 20)
                }
                .padding(.horizontal, ABTheme.paddingMedium)
            }
            .abScreenBackground()
            .refreshable { await viewModel.loadUserData() }
            .task { await viewModel.loadUserData() }
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
            .sheet(isPresented: $showAICompanion) {
                AICompanionIntroView()
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

    // MARK: - 2. Today's Action Card (STATE-DRIVEN)

    private var todayActionCard: some View {
        let anchorDone = viewModel.todayEntry?.anchorCompleted ?? false
        let bloomDone = viewModel.todayEntry?.bloomCompleted ?? false

        return Group {
            // Priority 1: Both done — celebration
            if anchorDone && bloomDone {
                fullyRootedCard
            }
            // Priority 2: Anchor done, bloom not done — always show bloom
            else if anchorDone && !bloomDone {
                splitProgressCard
            }
            // Priority 3: Bloom done, anchor not done — "Anchor Your Heart" (no "Morning")
            else if !anchorDone && bloomDone {
                actionHeroCard(
                    title: "Anchor Your Heart",
                    subtitle: "You bloomed beautifully — now anchor in God's truth too.",
                    icon: "anchor",
                    accentColor: ABTheme.warmGold,
                    ctaText: actionCTAText,
                    isAnchor: true
                )
            }
            // Priority 4: Neither done — time-based
            else {
                neitherDoneCard
            }
        }
    }

    /// Neither anchor nor bloom done — show based on time of day
    private var neitherDoneCard: some View {
        Group {
            // 3am-1pm: Anchor is primary
            if hour >= 3 && hour < 13 {
                actionHeroCard(
                    title: "Anchor Your Morning",
                    subtitle: "Start your day rooted in God's truth. Don't let the enemy set the tone.",
                    icon: "sunrise.fill",
                    accentColor: ABTheme.warmGold,
                    ctaText: actionCTAText,
                    isAnchor: true
                )
            }
            // 1pm-midnight: Bloom is primary, with anchor secondary
            else if hour >= 13 {
                VStack(spacing: 10) {
                    actionHeroCard(
                        title: "Time to Bloom",
                        subtitle: "Reflect on how God worked through you today. Celebrate who He's making you.",
                        icon: "camera.macro",
                        accentColor: ABTheme.blush,
                        ctaText: actionCTAText,
                        isAnchor: false
                    )

                    // Subtle secondary anchor option
                    Button { showAnchorSheet = true } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "anchor")
                                .font(.caption)
                            Text("You can still anchor today")
                                .font(.system(.caption, design: .serif))
                        }
                        .foregroundColor(ABTheme.warmGold.opacity(0.8))
                        .padding(.vertical, 8)
                    }
                }
            }
            // 12am-3am: Rest state
            else {
                restCard
            }
        }
    }

    private func actionHeroCard(title: String, subtitle: String, icon: String, accentColor: Color, ctaText: String, isAnchor: Bool) -> some View {
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
                        Text(ctaText)
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
                    Text("Complete")
                        .font(.caption2)
                        .foregroundColor(ABTheme.secondaryText)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, ABTheme.paddingLarge)
                .background(ABTheme.sageGreen.opacity(0.06))
            }

            Rectangle()
                .fill(ABTheme.secondaryText.opacity(0.1))
                .frame(width: 1)

            // Bloom — pending
            Button { showBloomSheet = true } label: {
                VStack(spacing: 8) {
                    Image(systemName: "moon.stars.fill")
                        .font(.title2)
                        .foregroundColor(ABTheme.blush)
                    Text("Time to Bloom")
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

            Text("You anchored in truth and bloomed in purpose. Well done, sister.")
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

    /// Late night (12am-3am) — gentle rest state, still lets them anchor/bloom
    private var restCard: some View {
        VStack(spacing: 12) {
            Image(systemName: "moon.zzz.fill")
                .font(.title)
                .foregroundColor(ABTheme.secondaryText.opacity(0.5))

            Text("Rest well, sister")
                .font(.system(.body, design: .serif, weight: .semibold))
                .foregroundColor(ABTheme.primaryText)

            Text("God is working even while you sleep. Your garden will be here in the morning.")
                .font(.system(.caption, design: .serif))
                .foregroundColor(ABTheme.secondaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(2)

            // Still allow access if they want
            HStack(spacing: 16) {
                Button { showAnchorSheet = true } label: {
                    Text("Anchor")
                        .font(.system(.caption, design: .serif, weight: .medium))
                        .foregroundColor(ABTheme.warmGold)
                }
                Button { showBloomSheet = true } label: {
                    Text("Bloom")
                        .font(.system(.caption, design: .serif, weight: .medium))
                        .foregroundColor(ABTheme.blush)
                }
            }
            .padding(.top, 4)
        }
        .padding(ABTheme.paddingLarge)
        .frame(maxWidth: .infinity)
        .background(ABTheme.cardBackground)
        .cornerRadius(ABTheme.cornerRadius)
        .shadow(color: ABTheme.cardShadow, radius: 4, x: 0, y: 1)
    }

    // MARK: - 3. AI Companion Card (SURFACED)

    private var aiCompanionCard: some View {
        let hasRecentResponse = aiService.lastResponse != nil

        return Button { showAICompanion = true } label: {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(ABTheme.warmGold.opacity(0.12))
                        .frame(width: 44, height: 44)
                    Image(systemName: "sparkles")
                        .font(.system(size: 18))
                        .foregroundColor(ABTheme.warmGold)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text("AI Devotional Companion")
                        .font(.system(.subheadline, design: .serif, weight: .semibold))
                        .foregroundColor(ABTheme.primaryText)

                    if hasRecentResponse {
                        Text("You have a word waiting for you")
                            .font(.caption)
                            .foregroundColor(ABTheme.warmGold)
                    } else {
                        Text("Write a reflection to receive a personal word")
                            .font(.caption)
                            .foregroundColor(ABTheme.secondaryText)
                    }
                }

                Spacer()

                if !subscriptionManager.isPremium {
                    HStack(spacing: 3) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 9))
                        Text("Premium")
                            .font(.system(size: 9, weight: .semibold, design: .serif))
                    }
                    .foregroundColor(ABTheme.warmGold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(ABTheme.warmGold.opacity(0.1))
                    .cornerRadius(8)
                }

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(hasRecentResponse ? ABTheme.warmGold : ABTheme.secondaryText)
            }
            .padding(ABTheme.paddingMedium)
            .background(
                RoundedRectangle(cornerRadius: ABTheme.cornerRadius)
                    .fill(hasRecentResponse ? ABTheme.warmGold.opacity(0.04) : ABTheme.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: ABTheme.cornerRadius)
                            .stroke(hasRecentResponse ? ABTheme.warmGold.opacity(0.15) : Color.clear, lineWidth: 1)
                    )
            )
            .shadow(color: ABTheme.cardShadow, radius: 4, x: 0, y: 1)
        }
        .buttonStyle(.plain)
    }

    // MARK: - 4. Today's Scripture (TAPPABLE)

    private var todayScripture: some View {
        let prompt = DailyPrompt.morningPrompts[
            (Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1 - 1) % DailyPrompt.morningPrompts.count
        ]
        return VStack(spacing: 10) {
            Text(prompt.scripture)
                .font(.system(.subheadline, design: .serif).italic())
                .foregroundColor(ABTheme.primaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            Text("— \(prompt.scriptureReference)")
                .font(.system(size: 12, weight: .semibold, design: .serif))
                .foregroundColor(ABTheme.sageGreen)

            // Bookmark & Share actions
            ScriptureActionButtons(
                verseText: prompt.scripture,
                reference: prompt.scriptureReference,
                source: .morningAnchor
            )
        }
        .padding(.vertical, ABTheme.paddingMedium)
        .padding(.horizontal, ABTheme.paddingLarge)
        .frame(maxWidth: .infinity)
        .background(ABTheme.sageGreen.opacity(0.06))
        .cornerRadius(ABTheme.cornerRadius)
    }

    // MARK: - 5. Tree Hero

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

    // MARK: - 6. Active Journey Bar

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

// MARK: - AI Companion Intro View
/// Explains the AI companion feature and shows how it works — surfaces the feature for users who haven't discovered it
struct AICompanionIntroView: View {
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @Environment(\.dismiss) private var dismiss
    @State private var showUpgrade = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: ABTheme.paddingLarge) {
                    // Hero
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(ABTheme.warmGold.opacity(0.12))
                                .frame(width: 80, height: 80)
                            Image(systemName: "sparkles")
                                .font(.system(size: 32))
                                .foregroundColor(ABTheme.warmGold)
                        }

                        Text("Your AI Devotional Companion")
                            .font(ABTheme.headlineFont)
                            .foregroundColor(ABTheme.primaryText)

                        Text("No other devotional app does this.")
                            .font(.system(.caption, design: .serif, weight: .medium))
                            .foregroundColor(ABTheme.warmGold)
                    }
                    .padding(.top, ABTheme.paddingMedium)

                    // How it works
                    VStack(alignment: .leading, spacing: 16) {
                        Text("How It Works")
                            .font(ABTheme.subheadlineFont)
                            .foregroundColor(ABTheme.primaryText)

                        howItWorksStep(number: "1", text: "Complete your Morning Anchor or Evening Bloom")
                        howItWorksStep(number: "2", text: "Write a reflection — share what's on your heart")
                        howItWorksStep(number: "3", text: "Receive a personalized, scripture-backed response written just for you")
                    }
                    .abCard()

                    // Example response
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Example Response")
                            .font(.system(.caption, design: .serif, weight: .semibold))
                            .foregroundColor(ABTheme.secondaryText)

                        Text("\"You mentioned feeling unseen at work today. Sister, remember Hagar — she was the first person in Scripture to name God. She called Him 'El Roi, the God who sees me.' He sees you right now, in every hidden sacrifice, every quiet struggle. You are not invisible.\"")
                            .font(.system(.body, design: .serif).italic())
                            .foregroundColor(ABTheme.primaryText)
                            .lineSpacing(5)
                    }
                    .padding(ABTheme.paddingMedium)
                    .background(ABTheme.warmGold.opacity(0.05))
                    .cornerRadius(ABTheme.cornerRadius)
                    .overlay(
                        RoundedRectangle(cornerRadius: ABTheme.cornerRadius)
                            .stroke(ABTheme.warmGold.opacity(0.15), lineWidth: 1)
                    )

                    // CTA
                    if subscriptionManager.isPremium {
                        VStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.title2)
                                .foregroundColor(ABTheme.sageGreen)
                            Text("You have unlimited access")
                                .font(.system(.body, design: .serif, weight: .semibold))
                                .foregroundColor(ABTheme.sageGreen)
                            Text("Write a reflection in your next Anchor or Bloom to receive a personal word.")
                                .font(.caption)
                                .foregroundColor(ABTheme.secondaryText)
                                .multilineTextAlignment(.center)
                        }
                    } else {
                        VStack(spacing: 12) {
                            Text("Free members get 1 AI response per week.\nPremium members get unlimited.")
                                .font(.system(.caption, design: .serif))
                                .foregroundColor(ABTheme.secondaryText)
                                .multilineTextAlignment(.center)

                            Button { showUpgrade = true } label: {
                                HStack {
                                    Image(systemName: "crown.fill")
                                    Text("Unlock Unlimited AI Responses")
                                }
                            }
                            .buttonStyle(ABPremiumButtonStyle())
                        }
                    }

                    Spacer().frame(height: 40)
                }
                .padding(.horizontal, ABTheme.paddingMedium)
            }
            .abScreenBackground()
            .navigationTitle("AI Companion")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(ABTheme.sageGreen)
                }
            }
            .sheet(isPresented: $showUpgrade) { SubscriptionView() }
        }
    }

    private func howItWorksStep(number: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(ABTheme.warmGold.opacity(0.12))
                    .frame(width: 28, height: 28)
                Text(number)
                    .font(.system(.caption, design: .serif, weight: .bold))
                    .foregroundColor(ABTheme.warmGold)
            }

            Text(text)
                .font(.system(.body, design: .serif))
                .foregroundColor(ABTheme.primaryText)
                .lineSpacing(3)
        }
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
