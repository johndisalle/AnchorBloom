import SwiftUI

// MARK: - Welcome View (Post Sign-Up)
/// Shown once after a new user creates their account
struct WelcomeView: View {
    let onContinue: () -> Void

    @State private var currentPage = 0

    private let pages: [(icon: String, title: String, description: String, color: Color)] = [
        (
            "sun.and.horizon.fill",
            "Morning Anchor",
            "Start each day rooted in Scripture. Select what's pulling at your heart, reflect on God's truth, and anchor yourself before the world rushes in.",
            ABTheme.warmGold
        ),
        (
            "moon.stars.fill",
            "Evening Bloom",
            "End each day reflecting on how you walked in your calling. Choose the roles you lived out — Nurturer, Prayer Warrior, Graceful Speaker — and watch your growth unfold.",
            ABTheme.blush
        ),
        (
            "water.waves",
            "Drift Log",
            "Feeling off course? One tap to name it — comparison, fear, overwhelm. God meets you with an anchoring prayer right where you are.",
            ABTheme.sageGreen
        ),
        (
            "map.fill",
            "30-Day Journeys",
            "Walk through guided Scripture journeys like \"Rooted in Identity\" and \"The Armor of Grace.\" Each day brings a verse, reflection, action step, and prayer.",
            ABTheme.warmGold
        ),
        (
            "heart.circle.fill",
            "Sister Circles",
            "You weren't meant to grow alone. Join or create small groups to share encouragement, prayer requests, and praise with other women walking this path.",
            ABTheme.blush
        )
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Page content
            TabView(selection: $currentPage) {
                ForEach(0..<pages.count, id: \.self) { index in
                    welcomePage(pages[index])
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut, value: currentPage)

            // Custom dots
            HStack(spacing: 8) {
                ForEach(0..<pages.count, id: \.self) { index in
                    Circle()
                        .fill(index == currentPage ? ABTheme.sageGreen : ABTheme.sageGreen.opacity(0.25))
                        .frame(width: index == currentPage ? 10 : 7, height: index == currentPage ? 10 : 7)
                        .animation(.spring(response: 0.3), value: currentPage)
                }
            }
            .padding(.bottom, ABTheme.paddingMedium)

            // Button
            Button {
                if currentPage < pages.count - 1 {
                    withAnimation { currentPage += 1 }
                } else {
                    onContinue()
                }
            } label: {
                Text(currentPage < pages.count - 1 ? "Next" : "Start Growing")
            }
            .buttonStyle(ABPrimaryButtonStyle())
            .padding(.horizontal, ABTheme.paddingLarge)
            .padding(.bottom, 8)

            // Skip
            if currentPage < pages.count - 1 {
                Button("Skip") {
                    onContinue()
                }
                .font(.system(.caption, design: .serif))
                .foregroundColor(ABTheme.secondaryText)
                .padding(.bottom, ABTheme.paddingMedium)
            } else {
                Spacer().frame(height: 36)
            }
        }
        .abScreenBackground()
    }

    private func welcomePage(_ page: (icon: String, title: String, description: String, color: Color)) -> some View {
        VStack(spacing: ABTheme.paddingLarge) {
            Spacer()

            // Icon
            ZStack {
                Circle()
                    .fill(page.color.opacity(0.15))
                    .frame(width: 120, height: 120)

                Image(systemName: page.icon)
                    .font(.system(size: 48))
                    .foregroundColor(page.color)
            }

            // Title
            Text(page.title)
                .font(ABTheme.headlineFont)
                .foregroundColor(ABTheme.primaryText)

            // Description
            Text(page.description)
                .font(ABTheme.bodyFont)
                .foregroundColor(ABTheme.secondaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal, ABTheme.paddingXLarge)

            Spacer()
            Spacer()
        }
    }
}

// MARK: - Welcome to Premium View
/// Shown once after a user upgrades to premium
struct WelcomePremiumView: View {
    @Environment(\.dismiss) private var dismiss

    private let features: [(icon: String, title: String, description: String)] = [
        (
            "map.fill",
            "Premium Journeys Unlocked",
            "Dive into \"The Proverbs 31 Life,\" \"Becoming a Prayer Warrior,\" \"Gentle Strength,\" and more."
        ),
        (
            "book.fill",
            "Deeper Reflections",
            "Each morning and evening now includes a \"Go Deeper\" prompt to draw you further into God's Word."
        ),
        (
            "heart.circle.fill",
            "Unlimited Circles",
            "Create as many Sister Circles as you want, plus post and comment freely."
        ),
        (
            "chart.line.uptrend.xyaxis",
            "Growth Insights",
            "See detailed weekly reports on your streaks, drift patterns, and bloom roles."
        ),
        (
            "target",
            "Spiritual Goals",
            "Set custom goals and track your progress with milestone celebrations."
        ),
        (
            "bell.badge.fill",
            "Scripture Reminders",
            "Receive personalized verse notifications throughout your day at 10am, 1pm, and 5pm."
        )
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: ABTheme.paddingLarge) {
                    // Hero
                    VStack(spacing: ABTheme.paddingMedium) {
                        ZStack {
                            Circle()
                                .fill(ABTheme.warmGold.opacity(0.15))
                                .frame(width: 100, height: 100)

                            Image(systemName: "crown.fill")
                                .font(.system(size: 44))
                                .foregroundColor(ABTheme.warmGold)
                        }

                        Text("Welcome to Premium!")
                            .font(ABTheme.titleFont)
                            .foregroundColor(ABTheme.primaryText)

                        Text("Thank you for investing in your spiritual growth.\nHere's everything you've unlocked:")
                            .font(ABTheme.bodyFont)
                            .foregroundColor(ABTheme.secondaryText)
                            .multilineTextAlignment(.center)
                            .lineSpacing(3)
                    }
                    .padding(.top, ABTheme.paddingMedium)

                    // Feature cards
                    ForEach(features, id: \.title) { feature in
                        HStack(alignment: .top, spacing: 14) {
                            ZStack {
                                Circle()
                                    .fill(ABTheme.warmGold.opacity(0.12))
                                    .frame(width: 40, height: 40)

                                Image(systemName: feature.icon)
                                    .font(.body)
                                    .foregroundColor(ABTheme.warmGold)
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                Text(feature.title)
                                    .font(.system(.subheadline, design: .serif, weight: .semibold))
                                    .foregroundColor(ABTheme.primaryText)

                                Text(feature.description)
                                    .font(ABTheme.captionFont)
                                    .foregroundColor(ABTheme.secondaryText)
                                    .lineSpacing(2)
                            }

                            Spacer()
                        }
                        .abCard()
                    }

                    // Kingdom funded note
                    HStack(spacing: 10) {
                        Image(systemName: "heart.fill")
                            .foregroundColor(ABTheme.blush)
                            .font(.caption)
                        Text("Every dollar funds service and missions. You're not just growing — you're helping others bloom too.")
                            .font(.system(.caption, design: .serif).italic())
                            .foregroundColor(ABTheme.secondaryText)
                            .lineSpacing(2)
                    }
                    .padding(ABTheme.paddingMedium)
                    .background(ABTheme.blush.opacity(0.08))
                    .cornerRadius(ABTheme.cornerRadiusSmall)

                    // CTA
                    Button {
                        dismiss()
                    } label: {
                        HStack {
                            Image(systemName: "sparkles")
                            Text("Start Exploring")
                        }
                    }
                    .buttonStyle(ABPremiumButtonStyle())

                    Spacer().frame(height: 40)
                }
                .padding(.horizontal, ABTheme.paddingMedium)
            }
            .abScreenBackground()
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(ABTheme.warmGold)
                }
            }
        }
    }
}
