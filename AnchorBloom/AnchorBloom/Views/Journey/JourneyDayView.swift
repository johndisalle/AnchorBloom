import SwiftUI

// MARK: - Journey Day View
/// Displays a single day's devotional content within a journey
struct JourneyDayView: View {
    let journey: Journey
    let dayNumber: Int
    @ObservedObject var viewModel: AppViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var reflectionText = ""
    @State private var isCompleting = false
    @State private var showCompletion = false

    private var journeyDay: JourneyDay? {
        journey.days.first { $0.dayNumber == dayNumber }
    }

    private var isCompleted: Bool {
        viewModel.journeyProgress(for: journey.id) >= dayNumber
    }

    var body: some View {
        ScrollView {
            if let day = journeyDay {
                VStack(spacing: ABTheme.paddingLarge) {
                    // Day header
                    dayHeader(day)

                    // Scripture card
                    scriptureCard(day)

                    // Reflection
                    reflectionCard(day)

                    // Prompt
                    promptCard(day)

                    // Action step
                    actionStepCard(day)

                    // Prayer
                    prayerCard(day)

                    // Complete button
                    if !isCompleted {
                        Button {
                            completeDay()
                        } label: {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                Text("Complete Day \(dayNumber)")
                            }
                        }
                        .buttonStyle(ABPrimaryButtonStyle())
                        .disabled(isCompleting)
                    } else {
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(ABTheme.sageGreen)
                            Text("Day \(dayNumber) Complete")
                                .font(.system(.subheadline, design: .serif, weight: .semibold))
                                .foregroundColor(ABTheme.sageGreen)
                        }
                        .padding(.vertical, 14)
                        .frame(maxWidth: .infinity)
                        .background(ABTheme.sageGreen.opacity(0.1))
                        .cornerRadius(ABTheme.cornerRadius)
                    }

                    // Navigation to next day
                    if isCompleted && dayNumber < journey.totalDays {
                        NavigationLink {
                            JourneyDayView(
                                journey: journey,
                                dayNumber: dayNumber + 1,
                                viewModel: viewModel
                            )
                        } label: {
                            HStack {
                                Text("Continue to Day \(dayNumber + 1)")
                                Image(systemName: "arrow.right")
                            }
                            .font(.system(.subheadline, design: .serif, weight: .medium))
                            .foregroundColor(ABTheme.sageGreen)
                        }
                    }

                    Spacer().frame(height: 40)
                }
                .padding(.horizontal, ABTheme.paddingMedium)
                .padding(.top, ABTheme.paddingMedium)
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.title)
                        .foregroundColor(ABTheme.warmGold)
                    Text("Day content not available yet")
                        .font(ABTheme.bodyFont)
                        .foregroundColor(ABTheme.secondaryText)
                }
                .padding(.top, 60)
            }
        }
        .abScreenBackground()
        .navigationTitle("Day \(dayNumber)")
        .navigationBarTitleDisplayMode(.inline)
        .overlay {
            if showCompletion {
                completionOverlay
            }
        }
    }

    // MARK: - Day Header
    private func dayHeader(_ day: JourneyDay) -> some View {
        VStack(spacing: 8) {
            Text("Day \(dayNumber) of \(journey.totalDays)")
                .font(.system(.caption, design: .serif, weight: .semibold))
                .foregroundColor(ABTheme.sageGreen)
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(ABTheme.sageGreen.opacity(0.1))
                .cornerRadius(12)

            Text(day.title)
                .font(ABTheme.headlineFont)
                .foregroundColor(ABTheme.primaryText)
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - Scripture Card
    private func scriptureCard(_ day: JourneyDay) -> some View {
        VStack(spacing: ABTheme.paddingMedium) {
            Image(systemName: "book.closed.fill")
                .font(.title2)
                .foregroundColor(ABTheme.warmGold)

            Text(day.scripture)
                .font(ABTheme.scriptureFont)
                .foregroundColor(ABTheme.primaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            Text(day.scriptureReference)
                .font(.system(.caption, design: .serif, weight: .semibold))
                .foregroundColor(ABTheme.sageGreen)
        }
        .abCard()
    }

    // MARK: - Reflection Card
    private func reflectionCard(_ day: JourneyDay) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "text.book.closed.fill")
                    .foregroundColor(ABTheme.warmGold)
                Text("Reflection")
                    .font(ABTheme.subheadlineFont)
                    .foregroundColor(ABTheme.primaryText)
            }

            Text(day.reflection)
                .font(ABTheme.bodyFont)
                .foregroundColor(ABTheme.secondaryText)
                .lineSpacing(4)
        }
        .abCard()
    }

    // MARK: - Prompt Card
    private func promptCard(_ day: JourneyDay) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(ABTheme.warmGold)
                Text("Journal Prompt")
                    .font(ABTheme.subheadlineFont)
                    .foregroundColor(ABTheme.primaryText)
            }

            Text(day.prompt)
                .font(ABTheme.bodyFont)
                .foregroundColor(ABTheme.secondaryText)
                .lineSpacing(4)

            // Optional journal space
            TextEditor(text: $reflectionText)
                .font(ABTheme.bodyFont)
                .frame(minHeight: 80)
                .padding(ABTheme.paddingSmall)
                .background(ABTheme.softWhite)
                .cornerRadius(ABTheme.cornerRadiusSmall)
                .overlay(
                    RoundedRectangle(cornerRadius: ABTheme.cornerRadiusSmall)
                        .stroke(ABTheme.sageGreen.opacity(0.2), lineWidth: 1)
                )
                .overlay(alignment: .topLeading) {
                    if reflectionText.isEmpty {
                        Text("Write your thoughts...")
                            .font(ABTheme.bodyFont)
                            .foregroundColor(ABTheme.secondaryText.opacity(0.5))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 16)
                            .allowsHitTesting(false)
                    }
                }
        }
        .abCard()
    }

    // MARK: - Action Step Card
    private func actionStepCard(_ day: JourneyDay) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "figure.walk")
                    .foregroundColor(ABTheme.sageGreen)
                Text("Today's Action Step")
                    .font(ABTheme.subheadlineFont)
                    .foregroundColor(ABTheme.primaryText)
            }

            Text(day.actionStep)
                .font(ABTheme.bodyFont)
                .foregroundColor(ABTheme.secondaryText)
                .lineSpacing(4)
        }
        .padding(ABTheme.paddingMedium)
        .background(ABTheme.sageGreen.opacity(0.06))
        .cornerRadius(ABTheme.cornerRadius)
    }

    // MARK: - Prayer Card
    private func prayerCard(_ day: JourneyDay) -> some View {
        VStack(spacing: 10) {
            Image(systemName: "hands.sparkles.fill")
                .font(.title2)
                .foregroundColor(ABTheme.warmGold)

            Text("Prayer")
                .font(ABTheme.subheadlineFont)
                .foregroundColor(ABTheme.primaryText)

            Text(day.prayer)
                .font(ABTheme.bodyFont)
                .foregroundColor(ABTheme.secondaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
        }
        .abCard()
    }

    // MARK: - Complete Day
    private func completeDay() {
        isCompleting = true
        Task {
            await viewModel.completeJourneyDay(journeyID: journey.id, day: dayNumber)
            withAnimation(.spring(response: 0.4)) {
                showCompletion = true
            }
            try? await Task.sleep(nanoseconds: 1_800_000_000)
            showCompletion = false
            isCompleting = false
        }
    }

    // MARK: - Completion Overlay
    private var completionOverlay: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()

            VStack(spacing: ABTheme.paddingMedium) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 60))
                    .foregroundColor(ABTheme.sageGreen)

                Text("Day \(dayNumber) Complete!")
                    .font(ABTheme.headlineFont)
                    .foregroundColor(ABTheme.primaryText)

                if dayNumber < journey.totalDays {
                    Text("Keep growing — Day \(dayNumber + 1) awaits.")
                        .font(ABTheme.bodyFont)
                        .foregroundColor(ABTheme.secondaryText)
                } else {
                    Text("You've completed the entire journey!")
                        .font(ABTheme.bodyFont)
                        .foregroundColor(ABTheme.secondaryText)
                }
            }
            .padding(ABTheme.paddingXLarge)
            .background(ABTheme.softWhite)
            .cornerRadius(ABTheme.cornerRadius)
            .shadow(radius: 20)
            .transition(.scale.combined(with: .opacity))
        }
    }
}
