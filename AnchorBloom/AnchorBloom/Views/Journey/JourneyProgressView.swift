import SwiftUI

// MARK: - Journey Progress View
/// Shows the 30-day journey overview with day-by-day progress
struct JourneyProgressView: View {
    let journey: Journey
    @ObservedObject var viewModel: AppViewModel
    @Environment(\.dismiss) private var dismiss

    private var currentDay: Int {
        viewModel.journeyProgress(for: journey.id)
    }

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 6)

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: ABTheme.paddingLarge) {
                    // Journey header
                    headerSection

                    // Progress bar
                    progressBar

                    // Day grid
                    dayGrid

                    // Continue / Start button
                    if currentDay < journey.totalDays {
                        let nextDay = currentDay + 1
                        NavigationLink {
                            JourneyDayView(
                                journey: journey,
                                dayNumber: nextDay,
                                viewModel: viewModel
                            )
                        } label: {
                            HStack {
                                Image(systemName: currentDay == 0 ? "play.fill" : "arrow.right")
                                Text(currentDay == 0 ? "Begin Day 1" : "Continue Day \(nextDay)")
                            }
                            .font(.system(.body, design: .serif).weight(.semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(ABTheme.sageGreen)
                            .cornerRadius(ABTheme.cornerRadius)
                        }
                    } else {
                        // Journey complete
                        VStack(spacing: 8) {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 40))
                                .foregroundColor(ABTheme.warmGold)
                            Text("Journey Complete!")
                                .font(ABTheme.headlineFont)
                                .foregroundColor(ABTheme.primaryText)
                            Text("You've finished all 30 days. Your roots run deep.")
                                .font(ABTheme.captionFont)
                                .foregroundColor(ABTheme.secondaryText)
                                .multilineTextAlignment(.center)
                        }
                        .abCard()
                    }

                    Spacer().frame(height: 40)
                }
                .padding(.horizontal, ABTheme.paddingMedium)
                .padding(.top, ABTheme.paddingMedium)
            }
            .abScreenBackground()
            .navigationTitle(journey.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(ABTheme.sageGreen)
                }
            }
        }
    }

    // MARK: - Header
    private var headerSection: some View {
        VStack(spacing: 10) {
            Image(systemName: journey.iconName)
                .font(.system(size: 40))
                .foregroundColor(ABTheme.sageGreen)

            Text(journey.subtitle)
                .font(ABTheme.captionFont)
                .foregroundColor(ABTheme.secondaryText)

            Text("Day \(currentDay) of \(journey.totalDays)")
                .font(.system(.caption, design: .serif).weight(.semibold))
                .foregroundColor(ABTheme.sageGreen)
        }
    }

    // MARK: - Progress Bar
    private var progressBar: some View {
        VStack(spacing: 6) {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(ABTheme.sageGreen.opacity(0.12))
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(ABTheme.sageGreen)
                        .frame(width: geo.size.width * CGFloat(currentDay) / CGFloat(journey.totalDays), height: 8)
                }
            }
            .frame(height: 8)

            HStack {
                Text("\(Int(Double(currentDay) / Double(journey.totalDays) * 100))% complete")
                    .font(.caption2)
                    .foregroundColor(ABTheme.secondaryText)
                Spacer()
                Text("\(journey.totalDays - currentDay) days remaining")
                    .font(.caption2)
                    .foregroundColor(ABTheme.secondaryText)
            }
        }
    }

    // MARK: - Day Grid
    private var dayGrid: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(1...journey.totalDays, id: \.self) { day in
                if day <= currentDay {
                    // Completed day - tappable to revisit
                    NavigationLink {
                        JourneyDayView(
                            journey: journey,
                            dayNumber: day,
                            viewModel: viewModel
                        )
                    } label: {
                        DayCell(day: day, state: .completed)
                    }
                } else if day == currentDay + 1 {
                    // Next available day
                    NavigationLink {
                        JourneyDayView(
                            journey: journey,
                            dayNumber: day,
                            viewModel: viewModel
                        )
                    } label: {
                        DayCell(day: day, state: .current)
                    }
                } else {
                    // Locked day
                    DayCell(day: day, state: .locked)
                }
            }
        }
    }
}

// MARK: - Day Cell
struct DayCell: View {
    let day: Int
    let state: DayCellState

    enum DayCellState {
        case completed, current, locked
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(backgroundColor)
                .frame(height: 44)

            if state == .completed {
                VStack(spacing: 1) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                    Text("\(day)")
                        .font(.system(size: 10, weight: .medium, design: .serif))
                        .foregroundColor(.white.opacity(0.8))
                }
            } else if state == .current {
                VStack(spacing: 1) {
                    Image(systemName: "play.fill")
                        .font(.system(size: 9))
                        .foregroundColor(.white)
                    Text("\(day)")
                        .font(.system(size: 10, weight: .semibold, design: .serif))
                        .foregroundColor(.white)
                }
            } else {
                Text("\(day)")
                    .font(.system(size: 11, design: .serif))
                    .foregroundColor(ABTheme.secondaryText.opacity(0.5))
            }
        }
    }

    private var backgroundColor: Color {
        switch state {
        case .completed: return ABTheme.sageGreen
        case .current: return ABTheme.sageGreen.opacity(0.7)
        case .locked: return ABTheme.sageGreen.opacity(0.06)
        }
    }
}
