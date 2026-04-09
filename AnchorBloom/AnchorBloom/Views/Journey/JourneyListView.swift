import SwiftUI

// MARK: - Journey List View
/// Browse and start 30-day guided spiritual growth journeys
struct JourneyListView: View {
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @EnvironmentObject var firestoreService: FirestoreService
    @StateObject private var viewModel = AppViewModel(firestoreService: FirestoreService())
    @State private var showUpgrade = false

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

                    // Active journey card
                    if let active = viewModel.activeJourney {
                        let prog = viewModel.journeyProgress(for: active.id)
                        NavigationLink {
                            JourneyDetailView(journey: active, viewModel: viewModel)
                        } label: {
                            VStack(spacing: 12) {
                                HStack {
                                    Image(systemName: active.iconName)
                                        .font(.title3)
                                        .foregroundColor(ABTheme.sageGreen)

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Currently Active")
                                            .font(.system(.caption2, design: .serif, weight: .semibold))
                                            .foregroundColor(ABTheme.sageGreen)
                                        Text(active.title)
                                            .font(.system(.body, design: .serif, weight: .semibold))
                                            .foregroundColor(ABTheme.primaryText)
                                    }

                                    Spacer()

                                    Text("Day \(prog)/\(active.totalDays)")
                                        .font(.system(.caption, design: .serif, weight: .medium))
                                        .foregroundColor(ABTheme.secondaryText)
                                }

                                GeometryReader { geo in
                                    ZStack(alignment: .leading) {
                                        RoundedRectangle(cornerRadius: 3)
                                            .fill(ABTheme.sageGreen.opacity(0.12))
                                            .frame(height: 6)
                                        RoundedRectangle(cornerRadius: 3)
                                            .fill(ABTheme.sageGreen)
                                            .frame(width: active.totalDays > 0 ? geo.size.width * CGFloat(prog) / CGFloat(active.totalDays) : 0, height: 6)
                                    }
                                }
                                .frame(height: 6)
                            }
                            .padding(ABTheme.paddingMedium)
                            .background(ABTheme.sageGreen.opacity(0.06))
                            .overlay(
                                RoundedRectangle(cornerRadius: ABTheme.cornerRadius)
                                    .stroke(ABTheme.sageGreen.opacity(0.3), lineWidth: 1)
                            )
                            .cornerRadius(ABTheme.cornerRadius)
                        }
                        .buttonStyle(.plain)
                    }

                    // Seasonal journeys (time-limited)
                    let seasonalJourneys = SeasonalJourneyContent.availableJourneys()
                    if !seasonalJourneys.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            SectionHeader(title: "Seasonal — Limited Time", icon: "clock.badge.fill")

                            ForEach(seasonalJourneys) { journey in
                                VStack(spacing: 0) {
                                    if subscriptionManager.isPremium {
                                        NavigationLink {
                                            JourneyDetailView(journey: journey, viewModel: viewModel)
                                        } label: {
                                            JourneyCardLabel(
                                                journey: journey,
                                                progress: viewModel.journeyProgress(for: journey.id)
                                            )
                                        }
                                        .buttonStyle(.plain)
                                    } else {
                                        Button { showUpgrade = true } label: {
                                            JourneyCardLabel(
                                                journey: journey,
                                                progress: 0,
                                                isPremiumLocked: true
                                            )
                                        }
                                        .buttonStyle(.plain)
                                    }

                                    // Days remaining badge
                                    if let daysLeft = SeasonalJourneyContent.daysRemaining(for: journey) {
                                        HStack(spacing: 4) {
                                            Image(systemName: "clock.fill")
                                                .font(.system(size: 9))
                                            Text(daysLeft <= 5 ? "Only \(daysLeft) days left!" : "\(daysLeft) days remaining")
                                                .font(.system(.caption2, design: .serif, weight: .medium))
                                        }
                                        .foregroundColor(daysLeft <= 5 ? ABTheme.destructive : ABTheme.warmGold)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 4)
                                        .background((daysLeft <= 5 ? ABTheme.destructive : ABTheme.warmGold).opacity(0.1))
                                        .cornerRadius(8)
                                        .frame(maxWidth: .infinity, alignment: .trailing)
                                        .padding(.top, 4)
                                    }
                                }
                            }
                        }
                    }

                    // Free journeys
                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeader(title: "Free Journeys", icon: "gift.fill")

                        ForEach(Journey.allJourneys.filter { !$0.isPremium }) { journey in
                            NavigationLink {
                                JourneyDetailView(journey: journey, viewModel: viewModel)
                            } label: {
                                JourneyCardLabel(
                                    journey: journey,
                                    progress: viewModel.journeyProgress(for: journey.id)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    // Premium journeys
                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeader(title: "Premium Journeys", icon: "crown.fill")

                        ForEach(Journey.allJourneys.filter { $0.isPremium }) { journey in
                            if subscriptionManager.isPremium {
                                NavigationLink {
                                    JourneyDetailView(journey: journey, viewModel: viewModel)
                                } label: {
                                    JourneyCardLabel(
                                        journey: journey,
                                        progress: viewModel.journeyProgress(for: journey.id)
                                    )
                                }
                                .buttonStyle(.plain)
                            } else {
                                JourneyCardLabel(
                                    journey: journey,
                                    progress: 0,
                                    isPremiumLocked: true
                                )
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
            .task {
                await viewModel.loadUserData()
            }
            .sheet(isPresented: $showUpgrade) {
                SubscriptionView()
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

// MARK: - Journey Card Label
struct JourneyCardLabel: View {
    let journey: Journey
    var progress: Int = 0
    var isPremiumLocked: Bool = false

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
        HStack(spacing: ABTheme.paddingMedium) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(coverColor.opacity(0.2))
                    .frame(width: 60, height: 60)

                Image(systemName: journey.iconName)
                    .font(.title2)
                    .foregroundColor(coverColor)
            }

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
                    if progress > 0 {
                        Text("Day \(progress)/\(journey.totalDays)")
                            .font(.caption2)
                            .foregroundColor(ABTheme.sageGreen)
                        Text("·")
                            .foregroundColor(ABTheme.secondaryText.opacity(0.7))
                    }
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
}

// MARK: - Journey Detail View
struct JourneyDetailView: View {
    let journey: Journey
    @ObservedObject var viewModel: AppViewModel
    @State private var journeyStarted = false

    private var progress: Int {
        viewModel.journeyProgress(for: journey.id)
    }

    var body: some View {
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

                    // Progress indicator (if started)
                    if progress > 0 {
                        VStack(spacing: 8) {
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(ABTheme.sageGreen.opacity(0.12))
                                        .frame(height: 8)

                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(ABTheme.sageGreen)
                                        .frame(width: geo.size.width * CGFloat(progress) / CGFloat(journey.totalDays), height: 8)
                                }
                            }
                            .frame(height: 8)

                            Text("Day \(progress) of \(journey.totalDays) completed")
                                .font(.system(.caption, design: .serif, weight: .medium))
                                .foregroundColor(ABTheme.sageGreen)
                        }
                        .padding(ABTheme.paddingMedium)
                        .background(ABTheme.sageGreen.opacity(0.06))
                        .cornerRadius(ABTheme.cornerRadius)
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

                    // Journey started confirmation (inline, no modal)
                    if journeyStarted {
                        VStack(spacing: 12) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 40))
                                .foregroundColor(ABTheme.sageGreen)

                            Text("Journey Started!")
                                .font(ABTheme.headlineFont)
                                .foregroundColor(ABTheme.primaryText)

                            Text("You've begun \(journey.title). Open Day 1 below to start your first devotional.")
                                .font(ABTheme.captionFont)
                                .foregroundColor(ABTheme.secondaryText)
                                .multilineTextAlignment(.center)

                            NavigationLink {
                                JourneyDayView(
                                    journey: journey,
                                    dayNumber: 1,
                                    viewModel: viewModel
                                )
                            } label: {
                                HStack {
                                    Image(systemName: "arrow.right")
                                    Text("Open Day 1")
                                }
                                .font(.system(.body, design: .serif, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(ABTheme.sageGreen)
                                .cornerRadius(ABTheme.cornerRadius)
                            }
                        }
                        .padding(ABTheme.paddingMedium)
                        .background(ABTheme.sageGreen.opacity(0.06))
                        .cornerRadius(ABTheme.cornerRadius)
                        .overlay(
                            RoundedRectangle(cornerRadius: ABTheme.cornerRadius)
                                .stroke(ABTheme.sageGreen.opacity(0.3), lineWidth: 1)
                        )
                    }

                    // Action button
                    if progress > 0 {
                        NavigationLink {
                            JourneyDayView(
                                journey: journey,
                                dayNumber: progress + 1,
                                viewModel: viewModel
                            )
                        } label: {
                            HStack {
                                Image(systemName: "arrow.right")
                                Text("Continue Journey — Day \(progress + 1)")
                            }
                            .font(.system(.body, design: .serif, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(ABTheme.sageGreen)
                            .cornerRadius(ABTheme.cornerRadius)
                        }
                    } else if !journeyStarted {
                        Button {
                            journeyStarted = true
                            Task {
                                await viewModel.beginJourney(journey.id)
                            }
                        } label: {
                            HStack {
                                Image(systemName: "play.fill")
                                Text("Begin This Journey")
                            }
                        }
                        .buttonStyle(ABPrimaryButtonStyle())
                    }

                    Spacer().frame(height: 40)
                }
                .padding(.horizontal, ABTheme.paddingMedium)
                .padding(.top, ABTheme.paddingMedium)
            }
            .abScreenBackground()
            .navigationTitle(journey.title)
            .navigationBarTitleDisplayMode(.inline)
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
        .environmentObject(FirestoreService())
}
