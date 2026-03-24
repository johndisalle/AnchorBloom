import SwiftUI

// MARK: - Journey List View
/// Browse and start 30-day guided spiritual growth journeys
struct JourneyListView: View {
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @State private var selectedJourney: Journey?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: ABTheme.paddingLarge) {
                    // Header
                    VStack(spacing: 8) {
                        Text("Guided Journeys")
                            .font(ABTheme.headlineFont)
                            .foregroundColor(ABTheme.primaryText)

                        Text("30-day paths to deeper roots and fuller blooms")
                            .font(ABTheme.captionFont)
                            .foregroundColor(ABTheme.secondaryText)
                    }
                    .padding(.top, ABTheme.paddingSmall)

                    // Free journeys
                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeader(title: "Free Journeys", icon: "gift.fill")

                        ForEach(Journey.allJourneys.filter { !$0.isPremium }) { journey in
                            JourneyCard(journey: journey) {
                                selectedJourney = journey
                            }
                        }
                    }

                    // Premium journeys
                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeader(title: "Premium Journeys", icon: "crown.fill")

                        ForEach(Journey.allJourneys.filter { $0.isPremium }) { journey in
                            JourneyCard(journey: journey, isPremiumLocked: !subscriptionManager.isPremium) {
                                if subscriptionManager.isPremium || !journey.isPremium {
                                    selectedJourney = journey
                                }
                            }
                        }
                    }

                    Spacer().frame(height: 40)
                }
                .padding(.horizontal, ABTheme.paddingMedium)
            }
            .abScreenBackground()
            .navigationTitle("Journeys")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(item: $selectedJourney) { journey in
                JourneyDetailView(journey: journey)
            }
        }
    }
}

// MARK: - Section Header
struct SectionHeader: View {
    let title: String
    let icon: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .foregroundColor(ABTheme.warmGold)
                .font(.subheadline)
            Text(title)
                .font(ABTheme.subheadlineFont)
                .foregroundColor(ABTheme.primaryText)
        }
    }
}

// MARK: - Journey Card
struct JourneyCard: View {
    let journey: Journey
    var isPremiumLocked: Bool = false
    let action: () -> Void

    private var coverColor: Color {
        switch journey.coverColorName {
        case "sageGreen": return ABTheme.sageGreen
        case "blush": return ABTheme.blush
        case "warmGold": return ABTheme.warmGold
        case "darkNavy": return ABTheme.darkNavy
        case "cream": return ABTheme.warmGoldLight
        default: return ABTheme.sageGreen
        }
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: ABTheme.paddingMedium) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(coverColor.opacity(0.2))
                        .frame(width: 60, height: 60)

                    Image(systemName: journey.iconName)
                        .font(.title2)
                        .foregroundColor(coverColor)
                }

                // Details
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(journey.title)
                            .font(.system(.body, design: .serif, weight: .semibold))
                            .foregroundColor(ABTheme.primaryText)

                        if isPremiumLocked {
                            Image(systemName: "lock.fill")
                                .font(.caption2)
                                .foregroundColor(ABTheme.warmGold)
                        }
                    }

                    Text(journey.subtitle)
                        .font(.system(.caption, design: .serif))
                        .foregroundColor(ABTheme.secondaryText)

                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .font(.caption2)
                        Text("\(journey.totalDays) days")
                            .font(.caption2)
                        Text("·")
                        Text(journey.scriptureTheme)
                            .font(.caption2)
                    }
                    .foregroundColor(ABTheme.secondaryText.opacity(0.7))
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(ABTheme.secondaryText)
            }
            .abCard()
            .opacity(isPremiumLocked ? 0.75 : 1.0)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Journey Detail View
struct JourneyDetailView: View {
    let journey: Journey
    @Environment(\.dismiss) private var dismiss
    @State private var isStarting = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: ABTheme.paddingLarge) {
                    // Hero section
                    VStack(spacing: ABTheme.paddingMedium) {
                        Image(systemName: journey.iconName)
                            .font(.system(size: 56))
                            .foregroundColor(ABTheme.sageGreen)

                        Text(journey.title)
                            .font(ABTheme.titleFont)
                            .foregroundColor(ABTheme.primaryText)

                        Text(journey.subtitle)
                            .font(ABTheme.bodyFont)
                            .foregroundColor(ABTheme.secondaryText)

                        Text(journey.scriptureTheme)
                            .font(.system(.caption, design: .serif, weight: .semibold))
                            .foregroundColor(ABTheme.sageGreen)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(ABTheme.sageGreen.opacity(0.1))
                            .cornerRadius(12)
                    }

                    // Description
                    Text(journey.description)
                        .font(ABTheme.bodyFont)
                        .foregroundColor(ABTheme.secondaryText)
                        .lineSpacing(4)
                        .abCard()

                    // What you'll learn
                    VStack(alignment: .leading, spacing: 10) {
                        Text("What You'll Discover")
                            .font(ABTheme.subheadlineFont)
                            .foregroundColor(ABTheme.primaryText)

                        JourneyBullet(text: "Daily Scripture to anchor your heart")
                        JourneyBullet(text: "Guided reflections and prayer prompts")
                        JourneyBullet(text: "Practical action steps for each day")
                        JourneyBullet(text: "Deep-rooted transformation over 30 days")
                    }
                    .abCard()

                    // Start button
                    Button {
                        isStarting = true
                        // In production, this would update user's active journey
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            dismiss()
                        }
                    } label: {
                        HStack {
                            Image(systemName: "play.fill")
                            Text("Begin This Journey")
                        }
                    }
                    .buttonStyle(ABPrimaryButtonStyle())
                    .disabled(isStarting)

                    Spacer().frame(height: 40)
                }
                .padding(.horizontal, ABTheme.paddingMedium)
                .padding(.top, ABTheme.paddingMedium)
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

// MARK: - Journey Bullet
struct JourneyBullet: View {
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "leaf.fill")
                .font(.caption)
                .foregroundColor(ABTheme.sageGreen)
                .padding(.top, 2)

            Text(text)
                .font(ABTheme.bodyFont)
                .foregroundColor(ABTheme.secondaryText)
        }
    }
}

#Preview {
    JourneyListView()
        .environmentObject(SubscriptionManager())
}
