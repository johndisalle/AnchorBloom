import SwiftUI

// MARK: - Discover View
/// Content browsing hub: journeys, topical library, scripture memory, seasonal content
struct DiscoverView: View {
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @EnvironmentObject var firestoreService: FirestoreService
    @StateObject private var viewModel = AppViewModel(firestoreService: FirestoreService())

    @State private var showUpgrade = false
    @State private var showScriptureMemory = false
    @State private var showTopicalLibrary = false
    @State private var showYearInBloom = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: ABTheme.paddingLarge) {

                    // Welcome header — always visible so the tab never feels empty
                    Text("Deepen your walk with guided journeys, devotionals, and scripture memory")
                        .font(.system(.subheadline, design: .serif))
                        .foregroundColor(ABTheme.secondaryText)
                        .multilineTextAlignment(.center)
                        .padding(.top, ABTheme.paddingSmall)

                    // Active Journey (if exists) — always top
                    if let active = viewModel.activeJourney {
                        activeJourneySection(active)
                    }

                    // Seasonal Journeys (time-limited, urgency)
                    let seasonal = SeasonalJourneyContent.availableJourneys()
                    if !seasonal.isEmpty {
                        seasonalSection(seasonal)
                    }

                    // Year in Bloom (Dec/Jan)
                    let month = Calendar.current.component(.month, from: Date())
                    if month == 12 || month == 1 {
                        yearInBloomBanner
                    }

                    // Life Topics — Topical Library
                    topicalLibrarySection

                    // Scripture Memory
                    scriptureMemorySection

                    // Browse All Journeys
                    allJourneysSection

                    Spacer().frame(height: 40)
                }
                .padding(.horizontal, ABTheme.paddingMedium)
            }
            .abScreenBackground()
            .navigationTitle("Discover")
            .navigationBarTitleDisplayMode(.large)
            .task { await viewModel.loadUserData() }
            .sheet(isPresented: $showUpgrade) { SubscriptionView() }
            .sheet(isPresented: $showScriptureMemory) { ScriptureMemoryView() }
            .sheet(isPresented: $showTopicalLibrary) { TopicalLibraryView() }
            .fullScreenCover(isPresented: $showYearInBloom) { YearInBloomView() }
        }
    }

    // MARK: - Active Journey

    private func activeJourneySection(_ journey: Journey) -> some View {
        let progress = viewModel.journeyProgress(for: journey.id)

        return NavigationLink {
            JourneyDetailView(journey: journey, viewModel: viewModel)
        } label: {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Continue Your Journey")
                        .font(.system(.caption, design: .serif, weight: .semibold))
                        .foregroundColor(ABTheme.sageGreen)
                    Spacer()
                    Text("Day \(progress)/\(journey.totalDays)")
                        .font(.system(.caption2, design: .serif, weight: .medium))
                        .foregroundColor(ABTheme.secondaryText)
                }

                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(ABTheme.sageGreen.opacity(0.12))
                            .frame(width: 46, height: 46)
                        Image(systemName: journey.iconName)
                            .font(.title3)
                            .foregroundColor(ABTheme.sageGreen)
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text(journey.title)
                            .font(.system(.body, design: .serif, weight: .semibold))
                            .foregroundColor(ABTheme.primaryText)

                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(ABTheme.sageGreen.opacity(0.12))
                                    .frame(height: 6)
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(ABTheme.sageGreen)
                                    .frame(width: journey.totalDays > 0 ? geo.size.width * CGFloat(progress) / CGFloat(journey.totalDays) : 0, height: 6)
                            }
                        }
                        .frame(height: 6)
                    }

                    Image(systemName: "arrow.right.circle.fill")
                        .font(.title3)
                        .foregroundColor(ABTheme.sageGreen)
                }
            }
            .padding(ABTheme.paddingMedium)
            .background(ABTheme.sageGreen.opacity(0.05))
            .overlay(
                RoundedRectangle(cornerRadius: ABTheme.cornerRadius)
                    .stroke(ABTheme.sageGreen.opacity(0.2), lineWidth: 1)
            )
            .cornerRadius(ABTheme.cornerRadius)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Seasonal

    private func seasonalSection(_ journeys: [Journey]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "clock.badge.fill")
                    .foregroundColor(ABTheme.warmGold)
                Text("Limited Time")
                    .font(ABTheme.subheadlineFont)
                    .foregroundColor(ABTheme.primaryText)
            }

            ForEach(journeys) { journey in
                VStack(spacing: 6) {
                    if subscriptionManager.isPremium {
                        NavigationLink {
                            JourneyDetailView(journey: journey, viewModel: viewModel)
                        } label: {
                            JourneyCardLabel(journey: journey, progress: viewModel.journeyProgress(for: journey.id))
                        }
                        .buttonStyle(.plain)
                    } else {
                        Button { showUpgrade = true } label: {
                            JourneyCardLabel(journey: journey, progress: 0, isPremiumLocked: true)
                        }
                        .buttonStyle(.plain)
                    }

                    if let daysLeft = SeasonalJourneyContent.daysRemaining(for: journey) {
                        HStack(spacing: 4) {
                            Image(systemName: "clock.fill")
                                .font(.system(size: 9))
                            Text(daysLeft <= 5 ? "Only \(daysLeft) days left!" : "\(daysLeft) days remaining")
                                .font(.system(.caption2, design: .serif, weight: .medium))
                        }
                        .foregroundColor(daysLeft <= 5 ? ABTheme.destructive : ABTheme.warmGold)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                }
            }
        }
    }

    // MARK: - Year in Bloom Banner

    private var yearInBloomBanner: some View {
        Button { showYearInBloom = true } label: {
            HStack(spacing: 12) {
                Image(systemName: "sparkles")
                    .font(.title2)
                    .foregroundColor(ABTheme.warmGold)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Your Year in Bloom")
                        .font(.system(.body, design: .serif, weight: .semibold))
                        .foregroundColor(ABTheme.primaryText)
                    Text("See your faith story this year — share it with the world")
                        .font(.caption2)
                        .foregroundColor(ABTheme.secondaryText)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(ABTheme.warmGold)
            }
            .padding(ABTheme.paddingMedium)
            .background(
                LinearGradient(colors: [ABTheme.warmGold.opacity(0.08), ABTheme.blush.opacity(0.06)], startPoint: .leading, endPoint: .trailing)
            )
            .cornerRadius(ABTheme.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: ABTheme.cornerRadius)
                    .stroke(ABTheme.warmGold.opacity(0.15), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Topical Library Section

    private var topicalLibrarySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Life Topics")
                    .font(ABTheme.subheadlineFont)
                    .foregroundColor(ABTheme.primaryText)
                Spacer()
                Button { showTopicalLibrary = true } label: {
                    Text("See All")
                        .font(.system(.caption, design: .serif, weight: .medium))
                        .foregroundColor(ABTheme.sageGreen)
                }
            }

            Text("Devotionals for every season of life")
                .font(.caption)
                .foregroundColor(ABTheme.secondaryText)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(TopicalCategory.allCases, id: \.self) { category in
                        Button { showTopicalLibrary = true } label: {
                            VStack(spacing: 8) {
                                ZStack {
                                    Circle()
                                        .fill(ABTheme.blush.opacity(0.12))
                                        .frame(width: 48, height: 48)
                                        .shadow(color: ABTheme.blush.opacity(0.15), radius: 4, x: 0, y: 2)
                                    Image(systemName: category.icon)
                                        .font(.system(size: 18))
                                        .foregroundColor(ABTheme.blush)
                                }
                                Text(category.rawValue)
                                    .font(.system(size: 10, weight: .medium, design: .serif))
                                    .foregroundColor(ABTheme.primaryText)
                                    .lineLimit(1)
                                    .frame(width: 72)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    // MARK: - Scripture Memory Section

    private var scriptureMemorySection: some View {
        Button { showScriptureMemory = true } label: {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(ABTheme.sageGreen.opacity(0.12))
                        .frame(width: 44, height: 44)
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 18))
                        .foregroundColor(ABTheme.sageGreen)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text("Scripture Memory")
                        .font(.system(.body, design: .serif, weight: .semibold))
                        .foregroundColor(ABTheme.primaryText)
                    Text("Memorize a verse in 7 days through spaced repetition")
                        .font(.caption)
                        .foregroundColor(ABTheme.secondaryText)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(ABTheme.secondaryText)
            }
            .abCard()
        }
        .buttonStyle(.plain)
    }

    // MARK: - All Journeys

    private var allJourneysSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("30-Day Journeys")
                .font(ABTheme.subheadlineFont)
                .foregroundColor(ABTheme.primaryText)

            // Free
            VStack(alignment: .leading, spacing: 6) {
                Text("Free")
                    .font(.system(.caption, design: .serif, weight: .medium))
                    .foregroundColor(ABTheme.sageGreen)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(ABTheme.sageGreen.opacity(0.1))
                    .cornerRadius(6)

                ForEach(Journey.allJourneys.filter { !$0.isPremium }) { journey in
                    NavigationLink {
                        JourneyDetailView(journey: journey, viewModel: viewModel)
                    } label: {
                        JourneyCardLabel(journey: journey, progress: viewModel.journeyProgress(for: journey.id))
                    }
                    .buttonStyle(.plain)
                }
            }

            // Premium
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 4) {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 10))
                        .foregroundColor(ABTheme.warmGold)
                    Text("Premium")
                        .font(.system(.caption, design: .serif, weight: .medium))
                        .foregroundColor(ABTheme.warmGold)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(ABTheme.warmGold.opacity(0.1))
                .cornerRadius(6)

                ForEach(Journey.allJourneys.filter { $0.isPremium }) { journey in
                    if subscriptionManager.isPremium {
                        NavigationLink {
                            JourneyDetailView(journey: journey, viewModel: viewModel)
                        } label: {
                            JourneyCardLabel(journey: journey, progress: viewModel.journeyProgress(for: journey.id))
                        }
                        .buttonStyle(.plain)
                    } else {
                        Button { showUpgrade = true } label: {
                            JourneyCardLabel(journey: journey, progress: 0, isPremiumLocked: true)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}
