import SwiftUI
import FirebaseAuth

// MARK: - Profile View (Me Tab)
/// Everything personal: profile, tree, progress, streak rewards, badges, verses, settings, gifting
struct ProfileView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var firestoreService: FirestoreService
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @EnvironmentObject var notificationManager: NotificationManager

    @StateObject private var viewModel = AppViewModel(firestoreService: FirestoreService())

    @State private var showStreakRewards = false
    @State private var showProgressStats = false
    @State private var showJournalExport = false
    @State private var showGiftPremium = false
    @State private var showSubscription = false
    @State private var showBlockedUsers = false
    @State private var showYearInBloom = false
    @State private var showSettings = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: ABTheme.paddingLarge) {
                    // Profile Card
                    profileCard

                    // Blooming Tree — HERO
                    treeSection

                    // Streak & Rewards
                    streakSection

                    // Quick Actions Grid
                    quickActionsGrid

                    // Recent Badges
                    if !viewModel.earnedBadges.isEmpty {
                        badgesSection
                    }

                    // Active Goals (premium)
                    if subscriptionManager.isPremium {
                        let activeGoals = viewModel.spiritualGoals.filter { !$0.isCompleted }
                        if !activeGoals.isEmpty {
                            goalsSection(activeGoals)
                        }
                    }

                    Spacer().frame(height: 40)
                }
                .padding(.horizontal, ABTheme.paddingMedium)
            }
            .abScreenBackground()
            .navigationTitle("Me")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showSettings = true } label: {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(ABTheme.secondaryText)
                    }
                }
            }
            .task { await viewModel.loadUserData() }
            .refreshable { await viewModel.loadUserData() }
            .sheet(isPresented: $showStreakRewards) {
                StreakRewardsView(
                    currentStreak: viewModel.userProfile?.currentStreak ?? 0,
                    longestStreak: viewModel.userProfile?.longestStreak ?? 0,
                    totalDays: viewModel.userProfile?.totalDaysCompleted ?? 0,
                    displayName: viewModel.userProfile?.displayName ?? "Sister",
                    recentEntries: viewModel.recentEntries
                )
            }
            .sheet(isPresented: $showProgressStats) {
                ProgressStatsView(viewModel: viewModel)
            }
            .sheet(isPresented: $showJournalExport) { JournalExportView() }
            .sheet(isPresented: $showGiftPremium) { GiftPremiumView() }
            .sheet(isPresented: $showSubscription) { SubscriptionView() }
            .sheet(isPresented: $showBlockedUsers) { BlockedUsersView() }
            .fullScreenCover(isPresented: $showYearInBloom) { YearInBloomView() }
            .sheet(isPresented: $showSettings) { SettingsSheetView() }
        }
    }

    // MARK: - Profile Card

    private var profileCard: some View {
        let name = viewModel.userProfile?.displayName ?? "Sister"
        let email = viewModel.userProfile?.email ?? ""
        let initial = String(name.prefix(1)).uppercased()

        return HStack(spacing: ABTheme.paddingMedium) {
            // Avatar
            ZStack {
                Circle()
                    .fill(ABTheme.blush.opacity(0.2))
                    .frame(width: 56, height: 56)
                Text(initial)
                    .font(.system(.title2, design: .serif, weight: .bold))
                    .foregroundColor(ABTheme.blush)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.system(.body, design: .serif, weight: .bold))
                    .foregroundColor(ABTheme.primaryText)

                Text(email)
                    .font(.caption)
                    .foregroundColor(ABTheme.secondaryText)
                    .lineLimit(1)
            }

            Spacer()

            // Subscription badge
            if subscriptionManager.isPremium {
                HStack(spacing: 4) {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 10))
                    Text("Premium")
                        .font(.system(.caption2, design: .serif, weight: .bold))
                }
                .foregroundColor(ABTheme.warmGold)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(ABTheme.warmGold.opacity(0.12))
                .cornerRadius(12)
            } else {
                Button { showSubscription = true } label: {
                    Text("Upgrade")
                        .font(.system(.caption2, design: .serif, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 5)
                        .background(ABTheme.warmGold)
                        .cornerRadius(12)
                }
            }
        }
        .padding(.top, ABTheme.paddingSmall)
    }

    // MARK: - Tree Section

    private var treeSection: some View {
        Button { showProgressStats = true } label: {
            VStack(spacing: ABTheme.paddingSmall) {
                BloomingTreeView(
                    growthLevel: viewModel.treeGrowthLevel,
                    bloomCount: viewModel.bloomCount,
                    fruitCount: viewModel.fruitCount,
                    streakDays: viewModel.currentStreak
                )

                // Stats grid
                HStack(spacing: 0) {
                    profileStat(value: "\(viewModel.currentStreak)", label: "Streak", color: .orange)
                    profileStatDivider
                    profileStat(value: "\(viewModel.longestStreak)", label: "Longest", color: ABTheme.warmGold)
                    profileStatDivider
                    profileStat(value: "\(viewModel.totalDays)", label: "Total Days", color: ABTheme.sageGreen)
                    profileStatDivider
                    profileStat(value: "\(viewModel.earnedBadges.count)", label: "Badges", color: ABTheme.blush)
                }
                .padding(.vertical, 10)
                .background(ABTheme.cardBackground)
                .cornerRadius(ABTheme.cornerRadiusSmall)

                HStack(spacing: 4) {
                    Text("View Full Growth Stats")
                        .font(.system(.caption, design: .serif, weight: .medium))
                    Image(systemName: "chart.bar.fill")
                        .font(.caption2)
                }
                .foregroundColor(ABTheme.sageGreen)
            }
            .abCard()
        }
        .buttonStyle(.plain)
    }

    private func profileStat(value: String, label: String, color: Color) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(.body, design: .serif, weight: .bold))
                .foregroundColor(color)
            Text(label)
                .font(.system(size: 9))
                .foregroundColor(ABTheme.secondaryText)
        }
        .frame(maxWidth: .infinity)
    }

    private var profileStatDivider: some View {
        Rectangle()
            .fill(ABTheme.secondaryText.opacity(0.1))
            .frame(width: 1, height: 28)
    }

    // MARK: - Streak Section

    private var streakSection: some View {
        let streak = viewModel.userProfile?.currentStreak ?? 0
        let nextMilestone = [7, 14, 30, 60, 90, 180, 365].first(where: { $0 > streak }) ?? 365
        let progress = streak > 0 ? min(Double(streak) / Double(nextMilestone), 1.0) : 0

        return Button { showStreakRewards = true } label: {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.orange)
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

    // MARK: - Quick Actions Grid

    private var quickActionsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
            quickAction(icon: "bookmark.fill", title: "My Verses", color: ABTheme.warmGold) {
                // Navigate to My Verses
            }
            .background(
                NavigationLink("", destination: MyVersesView()).opacity(0)
            )

            if subscriptionManager.isPremium {
                quickAction(icon: "doc.richtext", title: "Export Journal", color: ABTheme.sageGreen) {
                    showJournalExport = true
                }
            }

            quickAction(icon: "gift.fill", title: "Gift Premium", color: ABTheme.warmGold) {
                showGiftPremium = true
            }

            let month = Calendar.current.component(.month, from: Date())
            if month == 12 || month == 1 {
                quickAction(icon: "sparkles", title: "Year in Bloom", color: ABTheme.blush) {
                    showYearInBloom = true
                }
            }
        }
    }

    private func quickAction(icon: String, title: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(color)
                    .frame(width: 24)
                Text(title)
                    .font(.system(.caption, design: .serif, weight: .semibold))
                    .foregroundColor(ABTheme.primaryText)
                    .lineLimit(1)
                Spacer()
            }
            .padding(ABTheme.paddingMedium)
            .background(ABTheme.cardBackground)
            .cornerRadius(ABTheme.cornerRadiusSmall)
            .shadow(color: ABTheme.cardShadow, radius: 3, x: 0, y: 1)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Badges Section

    private var badgesSection: some View {
        VStack(alignment: .leading, spacing: ABTheme.paddingSmall) {
            HStack {
                Text("Badges")
                    .font(ABTheme.subheadlineFont)
                    .foregroundColor(ABTheme.primaryText)
                Spacer()
                Button { showProgressStats = true } label: {
                    Text("View All")
                        .font(.system(.caption, design: .serif, weight: .medium))
                        .foregroundColor(ABTheme.sageGreen)
                }
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.earnedBadges.suffix(6)) { badge in
                        BadgeCardSmall(badge: badge)
                    }
                }
            }
        }
    }

    // MARK: - Goals Section

    private func goalsSection(_ goals: [SpiritualGoal]) -> some View {
        VStack(alignment: .leading, spacing: ABTheme.paddingSmall) {
            HStack {
                Image(systemName: "target")
                    .foregroundColor(ABTheme.warmGold)
                Text("Active Goals")
                    .font(ABTheme.subheadlineFont)
                    .foregroundColor(ABTheme.primaryText)
            }

            ForEach(goals.prefix(3)) { goal in
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

// MARK: - Settings Sheet (moved from tab to sheet)
/// All settings now live in a sheet accessible from Profile, keeping the tab bar clean
struct SettingsSheetView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var firestoreService: FirestoreService
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @EnvironmentObject var notificationManager: NotificationManager
    @Environment(\.dismiss) private var dismiss

    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = true
    @State private var morningReminder = Calendar.current.date(from: DateComponents(hour: 7, minute: 0)) ?? Date()
    @State private var eveningReminder = Calendar.current.date(from: DateComponents(hour: 20, minute: 0)) ?? Date()
    @State private var notificationsEnabled = true
    @AppStorage("scriptureRemindersEnabled") private var scriptureRemindersEnabled = true
    @AppStorage("appearanceMode") private var appearanceMode: AppearanceMode = .system
    @State private var showSubscription = false
    @State private var showDeleteConfirmation = false
    @State private var showSignOutConfirmation = false
    @State private var showBlockedUsers = false

    var body: some View {
        NavigationStack {
            List {
                // Subscription
                Section("Subscription") {
                    HStack {
                        Image(systemName: subscriptionManager.isPremium ? "crown.fill" : "crown")
                            .foregroundColor(ABTheme.warmGold)
                        Text(subscriptionManager.isPremium ? "Premium Member" : "Free Plan")
                            .font(.system(.body, design: .serif))
                            .foregroundColor(ABTheme.primaryText)
                        Spacer()
                        if !subscriptionManager.isPremium {
                            Button { showSubscription = true } label: {
                                Text("Upgrade")
                                    .font(.system(.caption, design: .serif, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 4)
                                    .background(ABTheme.warmGold)
                                    .cornerRadius(10)
                            }
                        }
                    }

                    Button("Restore Purchases") {
                        Task { await subscriptionManager.restorePurchases() }
                    }
                    .foregroundColor(ABTheme.sageGreen)

                    Button("Redeem Offer Code") {
                        Task { await subscriptionManager.redeemOfferCode() }
                    }
                    .foregroundColor(ABTheme.warmGold)
                }

                // Appearance
                Section("Appearance") {
                    Picker(selection: $appearanceMode) {
                        ForEach(AppearanceMode.allCases, id: \.self) { mode in
                            HStack {
                                Image(systemName: mode.icon)
                                Text(mode.rawValue)
                            }
                            .tag(mode)
                        }
                    } label: {
                        Label {
                            Text("Theme")
                                .font(.system(.body, design: .serif))
                                .foregroundColor(ABTheme.primaryText)
                        } icon: {
                            Image(systemName: "paintbrush.fill")
                                .foregroundColor(ABTheme.sageGreen)
                        }
                    }
                    .onChange(of: appearanceMode) {
                        appearanceMode.apply()
                    }
                }

                // Reminders
                Section("Reminders") {
                    Toggle(isOn: $notificationsEnabled) {
                        Label {
                            Text("Notifications")
                                .font(.system(.body, design: .serif))
                        } icon: {
                            Image(systemName: "bell.fill")
                                .foregroundColor(ABTheme.warmGold)
                        }
                    }
                    .tint(ABTheme.sageGreen)
                    .onChange(of: notificationsEnabled) { updateReminders() }

                    if notificationsEnabled {
                        DatePicker(selection: $morningReminder, displayedComponents: .hourAndMinute) {
                            Label("Morning Anchor", systemImage: "sunrise.fill")
                                .font(.system(.body, design: .serif))
                        }
                        .onChange(of: morningReminder) { updateReminders() }

                        DatePicker(selection: $eveningReminder, displayedComponents: .hourAndMinute) {
                            Label("Evening Bloom", systemImage: "moon.stars.fill")
                                .font(.system(.body, design: .serif))
                        }
                        .onChange(of: eveningReminder) { updateReminders() }

                        if subscriptionManager.isPremium {
                            Toggle(isOn: $scriptureRemindersEnabled) {
                                Label {
                                    Text("Scripture Reminders")
                                        .font(.system(.body, design: .serif))
                                } icon: {
                                    Image(systemName: "book.fill")
                                        .foregroundColor(ABTheme.sageGreen)
                                }
                            }
                            .tint(ABTheme.sageGreen)
                            .onChange(of: scriptureRemindersEnabled) { updateReminders() }
                        }
                    }
                }

                // Privacy & Safety
                Section("Privacy & Safety") {
                    Button { showBlockedUsers = true } label: {
                        Label {
                            Text("Blocked Users")
                                .font(.system(.body, design: .serif))
                                .foregroundColor(ABTheme.primaryText)
                        } icon: {
                            Image(systemName: "hand.raised.fill")
                                .foregroundColor(ABTheme.destructive)
                        }
                    }
                }

                // Account
                Section("Account") {
                    Button {
                        showSignOutConfirmation = true
                    } label: {
                        Label {
                            Text("Sign Out")
                                .font(.system(.body, design: .serif))
                                .foregroundColor(ABTheme.primaryText)
                        } icon: {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .foregroundColor(ABTheme.secondaryText)
                        }
                    }

                    Button {
                        showDeleteConfirmation = true
                    } label: {
                        Label {
                            Text("Delete Account")
                                .font(.system(.body, design: .serif))
                                .foregroundColor(ABTheme.destructive)
                        } icon: {
                            Image(systemName: "trash.fill")
                                .foregroundColor(ABTheme.destructive)
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(ABTheme.cream)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(ABTheme.sageGreen)
                }
            }
            .sheet(isPresented: $showSubscription) { SubscriptionView() }
            .sheet(isPresented: $showBlockedUsers) { BlockedUsersView() }
            .alert("Sign Out?", isPresented: $showSignOutConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Sign Out", role: .destructive) {
                    try? authManager.signOut()
                    hasCompletedOnboarding = false
                }
            }
            .alert("Delete Account?", isPresented: $showDeleteConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    Task {
                        try? await firestoreService.deleteAllUserData()
                        try? await authManager.deleteAccount()
                        hasCompletedOnboarding = false
                    }
                }
            } message: {
                Text("This will permanently delete your account and all data. This cannot be undone.")
            }
        }
    }

    private func updateReminders() {
        notificationManager.updateReminders(
            morning: morningReminder,
            evening: eveningReminder,
            enabled: notificationsEnabled,
            isPremium: subscriptionManager.isPremium,
            scriptureRemindersEnabled: scriptureRemindersEnabled
        )
    }
}
