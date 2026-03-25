import SwiftUI

// MARK: - Drift Log View
/// One-tap drift entries with anchoring prayer text
struct DriftLogView: View {
    @EnvironmentObject var firestoreService: FirestoreService
    @StateObject private var viewModel = AppViewModel(firestoreService: FirestoreService())

    @State private var selectedCategory: DriftCategory?
    @State private var driftNote = ""
    @State private var driftLogged = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: ABTheme.paddingLarge) {
                    // Header
                    headerSection

                    // Quick-tap drift categories
                    driftCategoriesGrid

                    // Selected drift detail + prayer
                    if let category = selectedCategory {
                        selectedDriftSection(category: category)
                    }

                    // Today's drift entries
                    todayDriftHistory

                    Spacer().frame(height: 40)
                }
                .padding(.horizontal, ABTheme.paddingMedium)
            }
            .abScreenBackground()
            .navigationTitle("Drift Log")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        DriftHistoryView()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "chart.bar.fill")
                            Text("Patterns")
                        }
                        .font(.system(.caption, design: .serif, weight: .medium))
                        .foregroundColor(ABTheme.sageGreen)
                    }
                }
            }
            .task {
                await viewModel.loadUserData()
            }
        }
    }

    // MARK: - Header
    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "water.waves")
                .font(.title)
                .foregroundColor(ABTheme.sageGreen)

            Text("Feeling off course?")
                .font(ABTheme.headlineFont)
                .foregroundColor(ABTheme.primaryText)

            Text("Tap what you're feeling. Let God anchor you back.")
                .font(ABTheme.captionFont)
                .foregroundColor(ABTheme.secondaryText)
                .multilineTextAlignment(.center)
        }
        .padding(.top, ABTheme.paddingMedium)
    }

    // MARK: - Drift Categories Grid
    private var driftCategoriesGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 12) {
            ForEach(DriftCategory.allCases, id: \.self) { category in
                DriftCategoryButton(
                    category: category,
                    isSelected: selectedCategory == category
                ) {
                    UISelectionFeedbackGenerator().selectionChanged()
                    withAnimation(.spring(response: 0.3)) {
                        if selectedCategory == category {
                            selectedCategory = nil
                        } else {
                            selectedCategory = category
                        }
                    }
                }
            }
        }
    }

    // MARK: - Selected Drift Section
    private func selectedDriftSection(category: DriftCategory) -> some View {
        VStack(spacing: ABTheme.paddingMedium) {
            // Prayer text
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: "hands.sparkles.fill")
                        .foregroundColor(ABTheme.warmGold)
                    Text("Anchoring Prayer")
                        .font(ABTheme.subheadlineFont)
                        .foregroundColor(ABTheme.primaryText)
                }

                Text(category.anchoringPrayer)
                    .font(.system(.body, design: .serif).italic())
                    .foregroundColor(ABTheme.secondaryText)
                    .lineSpacing(4)
            }
            .abCard()

            if driftLogged {
                // Success state — replaces the form
                HStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                        .foregroundColor(.white)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Drift Logged & Anchored")
                            .font(.system(.subheadline, design: .serif, weight: .semibold))
                            .foregroundColor(.white)

                        Text("You acknowledged your \(category.rawValue.lowercased()) drift. God sees you.")
                            .font(.system(.caption2, design: .serif))
                            .foregroundColor(.white.opacity(0.85))
                    }

                    Spacer()
                }
                .padding(ABTheme.paddingMedium)
                .background(ABTheme.sageGreen)
                .cornerRadius(ABTheme.cornerRadius)

                Button {
                    driftLogged = false
                    selectedCategory = nil
                } label: {
                    Text("Done")
                        .font(.system(.body, design: .serif, weight: .semibold))
                        .foregroundColor(ABTheme.sageGreen)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(ABTheme.sageGreen.opacity(0.1))
                        .cornerRadius(ABTheme.cornerRadius)
                }
            } else {
                // Note + Log button
                VStack(alignment: .leading, spacing: 8) {
                    Text("Add a note (optional)")
                        .font(.system(.caption, design: .serif))
                        .foregroundColor(ABTheme.secondaryText)

                    TextField("What triggered this drift?", text: $driftNote)
                        .font(ABTheme.bodyFont)
                        .padding()
                        .background(ABTheme.softWhite)
                        .cornerRadius(ABTheme.cornerRadiusSmall)
                        .overlay(
                            RoundedRectangle(cornerRadius: ABTheme.cornerRadiusSmall)
                                .stroke(ABTheme.sageGreen.opacity(0.2), lineWidth: 1)
                        )
                }

                Button {
                    guard let category = selectedCategory else { return }
                    let note = driftNote.isEmpty ? nil : driftNote
                    driftLogged = true
                    driftNote = ""
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    Task {
                        await viewModel.logDrift(
                            category: category,
                            note: note,
                            prayerPlayed: false
                        )
                    }
                } label: {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Log & Anchor")
                    }
                }
                .buttonStyle(ABPrimaryButtonStyle())
            }
        }
    }

    // MARK: - Today's Drift History
    private var todayDriftHistory: some View {
        Group {
            if let entry = viewModel.todayEntry, !entry.driftEntries.isEmpty {
                VStack(alignment: .leading, spacing: ABTheme.paddingSmall) {
                    Text("Today's Drifts")
                        .font(ABTheme.subheadlineFont)
                        .foregroundColor(ABTheme.primaryText)

                    ForEach(entry.driftEntries) { drift in
                        HStack(spacing: 12) {
                            Image(systemName: drift.category.icon)
                                .foregroundColor(ABTheme.blush)
                                .frame(width: 24)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(drift.category.rawValue)
                                    .font(.system(.subheadline, design: .serif, weight: .medium))
                                    .foregroundColor(ABTheme.primaryText)

                                if let note = drift.note, !note.isEmpty {
                                    Text(note)
                                        .font(.caption)
                                        .foregroundColor(ABTheme.secondaryText)
                                }
                            }

                            Spacer()

                            Text(drift.timestamp, style: .time)
                                .font(.caption2)
                                .foregroundColor(ABTheme.secondaryText)
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(ABTheme.cardBackground)
                        .cornerRadius(ABTheme.cornerRadiusSmall)
                    }
                }
            }
        }
    }

}

// MARK: - Drift Category Button
struct DriftCategoryButton: View {
    let category: DriftCategory
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: category.icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : ABTheme.blush)

                Text(category.rawValue)
                    .font(.system(.caption2, design: .serif, weight: .medium))
                    .foregroundColor(isSelected ? .white : ABTheme.primaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(isSelected ? ABTheme.sageGreen : ABTheme.cardBackground)
            .cornerRadius(ABTheme.cornerRadiusSmall)
            .shadow(color: ABTheme.cardShadow, radius: isSelected ? 6 : 3, x: 0, y: 1)
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

#Preview {
    DriftLogView()
        .environmentObject(FirestoreService())
}
