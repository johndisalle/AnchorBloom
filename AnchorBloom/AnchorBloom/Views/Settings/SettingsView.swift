import SwiftUI
import FirebaseAuth

// MARK: - Settings View
/// App settings: subscription, reminders, theme, account, export
struct SettingsView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var firestoreService: FirestoreService
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @EnvironmentObject var notificationManager: NotificationManager

    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = true
    @State private var morningReminder = Calendar.current.date(from: DateComponents(hour: 7, minute: 0)) ?? Date()
    @State private var eveningReminder = Calendar.current.date(from: DateComponents(hour: 20, minute: 0)) ?? Date()
    @State private var notificationsEnabled = true
    @AppStorage("scriptureRemindersEnabled") private var scriptureRemindersEnabled = true
    @State private var showSubscription = false
    @State private var showDeleteConfirmation = false
    @State private var showSignOutConfirmation = false
    @State private var showBlockedUsers = false
    @AppStorage("appearanceMode") private var appearanceMode: AppearanceMode = .system

    var body: some View {
        NavigationStack {
            List {
                // Profile section
                profileSection

                // My Verses
                Section {
                    NavigationLink {
                        MyVersesView()
                    } label: {
                        Label {
                            Text("My Verses")
                                .font(.system(.body, design: .serif))
                                .foregroundColor(ABTheme.primaryText)
                        } icon: {
                            Image(systemName: "bookmark.fill")
                                .foregroundColor(ABTheme.warmGold)
                        }
                    }
                } header: {
                    Text("Scripture")
                }

                // Subscription section
                subscriptionSection

                // Appearance section
                appearanceSection

                // Reminders section
                remindersSection

                // About section
                aboutSection

                // Privacy & Safety
                privacySection

                // Account section
                accountSection
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .abScreenBackground()
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showSubscription) {
                SubscriptionView()
            }
            .sheet(isPresented: $showBlockedUsers) {
                BlockedUsersView()
            }
        }
    }

    // MARK: - Privacy & Safety Section
    private var privacySection: some View {
        Section("Privacy & Safety") {
            Button {
                showBlockedUsers = true
            } label: {
                HStack {
                    Label {
                        Text("Blocked Users")
                            .font(.system(.body, design: .serif))
                            .foregroundColor(ABTheme.primaryText)
                    } icon: {
                        Image(systemName: "hand.raised.fill")
                            .foregroundColor(ABTheme.secondaryText)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption2)
                        .foregroundColor(ABTheme.secondaryText)
                }
            }
        }
        .listRowBackground(ABTheme.cardBackground)
    }

    // MARK: - Profile Section
    private var profileSection: some View {
        Section {
            HStack(spacing: ABTheme.paddingMedium) {
                ZStack {
                    Circle()
                        .fill(ABTheme.sageGreen.opacity(0.2))
                        .frame(width: 56, height: 56)

                    Image(systemName: "person.fill")
                        .font(.title2)
                        .foregroundColor(ABTheme.sageGreen)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(authManager.currentUser?.displayName ?? "Beloved")
                        .font(.system(.body, design: .serif, weight: .semibold))
                        .foregroundColor(ABTheme.primaryText)

                    Text(authManager.currentUser?.email ?? "")
                        .font(.caption)
                        .foregroundColor(ABTheme.secondaryText)

                    HStack(spacing: 4) {
                        Image(systemName: subscriptionManager.isPremium ? "crown.fill" : "leaf.fill")
                            .font(.caption2)
                        Text(subscriptionManager.isPremium ? "Premium" : "Free")
                            .font(.caption2)
                    }
                    .foregroundColor(subscriptionManager.isPremium ? ABTheme.warmGold : ABTheme.sageGreen)
                }
            }
            .listRowBackground(ABTheme.cardBackground)
        }
    }

    // MARK: - Subscription Section
    private var subscriptionSection: some View {
        Section("Subscription") {
            if subscriptionManager.isPremium {
                HStack {
                    Label("Premium Active", systemImage: "crown.fill")
                        .foregroundColor(ABTheme.warmGold)
                    Spacer()
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(ABTheme.sageGreen)
                }
            } else {
                Button {
                    showSubscription = true
                } label: {
                    HStack {
                        Label("Upgrade to Premium", systemImage: "crown.fill")
                            .foregroundColor(ABTheme.warmGold)
                        Spacer()
                        Text(subscriptionManager.monthlyProduct?.displayPrice ?? "$6.99/mo")
                            .font(.caption)
                            .foregroundColor(ABTheme.secondaryText)
                        Image(systemName: "chevron.right")
                            .font(.caption2)
                            .foregroundColor(ABTheme.secondaryText)
                    }
                }
            }

            Button("Restore Purchases") {
                Task { await subscriptionManager.restorePurchases() }
            }
            .foregroundColor(ABTheme.sageGreen)
        }
        .listRowBackground(ABTheme.cardBackground)
    }

    // MARK: - Appearance Section
    private var appearanceSection: some View {
        Section("Appearance") {
            Picker(selection: $appearanceMode) {
                ForEach(AppearanceMode.allCases, id: \.self) { mode in
                    Label(mode.rawValue, systemImage: mode.icon)
                        .tag(mode)
                }
            } label: {
                Label {
                    Text("Theme")
                        .font(.system(.body, design: .serif))
                        .foregroundColor(ABTheme.primaryText)
                } icon: {
                    Image(systemName: appearanceMode.icon)
                        .foregroundColor(ABTheme.sageGreen)
                }
            }
            .tint(ABTheme.sageGreen)
            .onChange(of: appearanceMode) {
                appearanceMode.apply()
            }
        }
        .listRowBackground(ABTheme.cardBackground)
    }

    // MARK: - Reminders Section
    private var remindersSection: some View {
        Section("Daily Reminders") {
            Toggle(isOn: $notificationsEnabled) {
                Label("Notifications", systemImage: "bell.fill")
            }
            .tint(ABTheme.sageGreen)
            .onChange(of: notificationsEnabled) { _, newValue in
                updateReminders()
                if newValue {
                    Task { await notificationManager.requestAuthorization() }
                }
            }

            if notificationsEnabled {
                DatePicker(
                    selection: $morningReminder,
                    displayedComponents: .hourAndMinute
                ) {
                    Label("Morning Anchor", systemImage: "sunrise.fill")
                        .foregroundColor(ABTheme.warmGold)
                }
                .onChange(of: morningReminder) { _, _ in updateReminders() }

                DatePicker(
                    selection: $eveningReminder,
                    displayedComponents: .hourAndMinute
                ) {
                    Label("Evening Bloom", systemImage: "moon.stars.fill")
                        .foregroundColor(ABTheme.blush)
                }
                .onChange(of: eveningReminder) { _, _ in updateReminders() }

                if subscriptionManager.isPremium {
                    Toggle(isOn: $scriptureRemindersEnabled) {
                        Label("Scripture Reminders", systemImage: "book.fill")
                            .foregroundColor(ABTheme.sageGreen)
                    }
                    .tint(ABTheme.sageGreen)
                    .onChange(of: scriptureRemindersEnabled) { _, _ in updateReminders() }

                    if scriptureRemindersEnabled {
                        HStack {
                            Image(systemName: "info.circle")
                                .font(.caption2)
                                .foregroundColor(ABTheme.secondaryText)
                            Text("3 daily scripture verses at 10am, 1pm, and 5pm")
                                .font(.caption2)
                                .foregroundColor(ABTheme.secondaryText)
                        }
                    }
                }
            }
        }
        .listRowBackground(ABTheme.cardBackground)
    }

    // MARK: - About Section
    private var aboutSection: some View {
        Section("About") {
            HStack {
                Label("Version", systemImage: "info.circle")
                Spacer()
                Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0")
                    .foregroundColor(ABTheme.secondaryText)
            }

            Link(destination: URL(string: "https://github.com/johndisalle/AnchorBloom/blob/claude/anchor-bloom-mvp-D2kbN/docs/privacy.md")!) {
                HStack {
                    Label("Privacy Policy", systemImage: "hand.raised.fill")
                        .foregroundColor(ABTheme.primaryText)
                    Spacer()
                    Image(systemName: "arrow.up.right")
                        .font(.caption2)
                        .foregroundColor(ABTheme.secondaryText)
                }
            }

            Link(destination: URL(string: "https://github.com/johndisalle/AnchorBloom/blob/claude/anchor-bloom-mvp-D2kbN/docs/terms.md")!) {
                HStack {
                    Label("Terms of Service", systemImage: "doc.text.fill")
                        .foregroundColor(ABTheme.primaryText)
                    Spacer()
                    Image(systemName: "arrow.up.right")
                        .font(.caption2)
                        .foregroundColor(ABTheme.secondaryText)
                }
            }

            Link(destination: URL(string: "https://github.com/johndisalle/AnchorBloom/blob/claude/anchor-bloom-mvp-D2kbN/docs/support.md")!) {
                HStack {
                    Label("Customer Support", systemImage: "questionmark.circle.fill")
                        .foregroundColor(ABTheme.primaryText)
                    Spacer()
                    Image(systemName: "arrow.up.right")
                        .font(.caption2)
                        .foregroundColor(ABTheme.secondaryText)
                }
            }

            Button {
                if let url = URL(string: "itms-apps://itunes.apple.com/app/id\(Bundle.main.infoDictionary?["APP_STORE_ID"] as? String ?? "")") {
                    UIApplication.shared.open(url)
                }
            } label: {
                Label("Rate Anchor & Bloom", systemImage: "star.fill")
                    .foregroundColor(ABTheme.primaryText)
            }
        }
        .listRowBackground(ABTheme.cardBackground)
    }

    // MARK: - Account Section
    private var accountSection: some View {
        Section("Account") {
            Button {
                showSignOutConfirmation = true
            } label: {
                Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                    .foregroundColor(ABTheme.primaryText)
            }
            .confirmationDialog("Sign Out?", isPresented: $showSignOutConfirmation) {
                Button("Sign Out", role: .destructive) {
                    try? authManager.signOut()
                }
            }

            Button {
                showDeleteConfirmation = true
            } label: {
                Label("Delete Account", systemImage: "trash.fill")
                    .foregroundColor(ABTheme.destructive)
            }
            .confirmationDialog(
                "Delete your account? This cannot be undone.",
                isPresented: $showDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button("Delete Account", role: .destructive) {
                    Task { try? await authManager.deleteAccount() }
                }
            }
        }
        .listRowBackground(ABTheme.cardBackground)
    }

    // MARK: - Update Reminders
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

// MARK: - Subscription View
struct SubscriptionView: View {
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: ABTheme.paddingLarge) {
                    // Premium hero
                    VStack(spacing: ABTheme.paddingMedium) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 48))
                            .foregroundColor(ABTheme.warmGold)

                        Text("Bloom Premium")
                            .font(ABTheme.titleFont)
                            .foregroundColor(ABTheme.primaryText)

                        Text("Unlock the full garden of growth")
                            .font(ABTheme.bodyFont)
                            .foregroundColor(ABTheme.secondaryText)
                    }
                    .padding(.top, ABTheme.paddingLarge)

                    // Features
                    VStack(alignment: .leading, spacing: 14) {
                        PremiumFeatureRow(icon: "heart.circle.fill", text: "Kingdom Funded — all profits fund service and missions")
                        PremiumFeatureRow(icon: "map.fill", text: "All premium 30-day journeys")
                        PremiumFeatureRow(icon: "person.3.fill", text: "Unlimited Sister Circles — post & comment")
                        PremiumFeatureRow(icon: "book.fill", text: "Deeper daily devotional prompts & reflections")
                        PremiumFeatureRow(icon: "chart.line.uptrend.xyaxis", text: "Detailed growth insights & weekly spiritual reports")
                        PremiumFeatureRow(icon: "bell.badge.fill", text: "Personalized scripture reminders throughout the day")
                        PremiumFeatureRow(icon: "target", text: "Custom spiritual goals & milestone tracking")
                        PremiumFeatureRow(icon: "xmark.circle", text: "Ad-free experience")
                    }
                    .abCard()

                    // Pricing
                    VStack(spacing: 12) {
                        if let yearly = subscriptionManager.yearlyProduct {
                            Button {
                                Task { try? await subscriptionManager.purchase(yearly) }
                            } label: {
                                VStack(spacing: 4) {
                                    Text("Yearly — Best Value")
                                        .font(.system(.body, design: .serif, weight: .bold))
                                    Text("$59.99/year (save 28%)")
                                        .font(.caption)
                                }
                            }
                            .buttonStyle(ABPremiumButtonStyle())
                        }

                        if let monthly = subscriptionManager.monthlyProduct {
                            Button {
                                Task { try? await subscriptionManager.purchase(monthly) }
                            } label: {
                                VStack(spacing: 4) {
                                    Text("Monthly")
                                        .font(.system(.body, design: .serif, weight: .semibold))
                                    Text("$6.99/month")
                                        .font(.caption)
                                }
                            }
                            .buttonStyle(ABSecondaryButtonStyle())
                        }

                        // Fallback if products haven't loaded
                        if subscriptionManager.products.isEmpty {
                            VStack(spacing: 12) {
                                Button("Yearly — $59.99/year (Best Value)") {}
                                    .buttonStyle(ABPremiumButtonStyle())

                                Button("Monthly — $6.99/month") {}
                                    .buttonStyle(ABSecondaryButtonStyle())
                            }
                        }
                    }

                    // Restore
                    Button("Restore Purchases") {
                        Task { await subscriptionManager.restorePurchases() }
                    }
                    .font(.caption)
                    .foregroundColor(ABTheme.secondaryText)

                    Text("Payment will be charged to your Apple ID account. Subscription automatically renews unless cancelled at least 24 hours before the end of the current period.")
                        .font(.system(size: 10))
                        .foregroundColor(ABTheme.secondaryText.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    Spacer().frame(height: 40)
                }
                .padding(.horizontal, ABTheme.paddingMedium)
            }
            .abScreenBackground()
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") { dismiss() }
                        .foregroundColor(ABTheme.sageGreen)
                }
            }
        }
    }
}

// MARK: - Premium Feature Row
struct PremiumFeatureRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(ABTheme.warmGold)
                .frame(width: 20)

            Text(text)
                .font(ABTheme.bodyFont)
                .foregroundColor(ABTheme.primaryText)
        }
    }
}

// MARK: - Blocked Users View
struct BlockedUsersView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var firestoreService: FirestoreService

    @State private var blockedUserIDs: [String] = []
    @State private var blockedProfiles: [String: String] = [:] // userID -> displayName
    @State private var isLoading = false
    @State private var unblockingID: String?

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView()
                        .tint(ABTheme.sageGreen)
                } else if blockedUserIDs.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "hand.raised.slash")
                            .font(.system(size: 48))
                            .foregroundColor(ABTheme.secondaryText.opacity(0.3))

                        Text("No blocked users")
                            .font(ABTheme.subheadlineFont)
                            .foregroundColor(ABTheme.primaryText)

                        Text("Users you block will appear here.\nYou can unblock them at any time.")
                            .font(ABTheme.captionFont)
                            .foregroundColor(ABTheme.secondaryText)
                            .multilineTextAlignment(.center)
                    }
                } else {
                    List {
                        ForEach(blockedUserIDs, id: \.self) { userID in
                            HStack {
                                Circle()
                                    .fill(ABTheme.secondaryText.opacity(0.2))
                                    .frame(width: 32, height: 32)
                                    .overlay(
                                        Text(String((blockedProfiles[userID] ?? "?").prefix(1)).uppercased())
                                            .font(.system(.caption, design: .serif, weight: .bold))
                                            .foregroundColor(ABTheme.secondaryText)
                                    )

                                Text(blockedProfiles[userID] ?? "User")
                                    .font(.system(.body, design: .serif))
                                    .foregroundColor(ABTheme.primaryText)

                                Spacer()

                                Button("Unblock") {
                                    unblockingID = userID
                                }
                                .font(.system(.caption, design: .serif, weight: .semibold))
                                .foregroundColor(ABTheme.sageGreen)
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .abScreenBackground()
            .navigationTitle("Blocked Users")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(ABTheme.sageGreen)
                }
            }
            .task {
                isLoading = true
                blockedUserIDs = await firestoreService.fetchBlockedUserIDs()
                // Fetch display names for blocked users
                for userID in blockedUserIDs {
                    if let name = try? await firestoreService.fetchDisplayName(userID: userID) {
                        blockedProfiles[userID] = name
                    }
                }
                isLoading = false
            }
            .alert("Unblock User?", isPresented: Binding(
                get: { unblockingID != nil },
                set: { if !$0 { unblockingID = nil } }
            )) {
                Button("Cancel", role: .cancel) { unblockingID = nil }
                Button("Unblock") {
                    if let userID = unblockingID {
                        Task {
                            try? await firestoreService.unblockUser(userID: userID)
                            blockedUserIDs.removeAll { $0 == userID }
                            blockedProfiles.removeValue(forKey: userID)
                            unblockingID = nil
                        }
                    }
                }
            } message: {
                if let userID = unblockingID {
                    Text("Unblock \(blockedProfiles[userID] ?? "this user")? You'll see their posts and comments again.")
                }
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(AuthManager())
        .environmentObject(FirestoreService())
        .environmentObject(SubscriptionManager())
        .environmentObject(NotificationManager())
}
