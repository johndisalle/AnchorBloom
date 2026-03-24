import SwiftUI

// MARK: - Drift Log View
/// One-tap drift entries with instant anchoring prayer audio
struct DriftLogView: View {
    @EnvironmentObject var firestoreService: FirestoreService
    @StateObject private var viewModel: AppViewModel
    @StateObject private var audioPlayer = AudioPlayerManager()

    @State private var selectedCategory: DriftCategory?
    @State private var driftNote = ""
    @State private var showPrayerPlayer = false
    @State private var showHistory = false

    init() {
        _viewModel = StateObject(wrappedValue: AppViewModel(firestoreService: FirestoreService()))
    }

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
            .task {
                await viewModel.loadUserData()
            }
        }
    }

    // MARK: - Header
    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "anchor.circle.fill")
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
                    withAnimation(.spring(response: 0.3)) {
                        if selectedCategory == category {
                            selectedCategory = nil
                        } else {
                            selectedCategory = category
                            showPrayerPlayer = false
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

            // Prayer audio player
            PrayerAudioPlayer(
                category: category,
                audioPlayer: audioPlayer
            )

            // Optional note
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

            // Log drift button
            Button {
                logDrift(category: category)
            } label: {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                    Text("Log & Anchor")
                }
            }
            .buttonStyle(ABPrimaryButtonStyle())
        }
        .transition(.opacity.combined(with: .move(edge: .bottom)))
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

                            if drift.prayerPlayed {
                                Image(systemName: "hands.sparkles.fill")
                                    .font(.caption)
                                    .foregroundColor(ABTheme.warmGold)
                            }

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

    // MARK: - Log Drift
    private func logDrift(category: DriftCategory) {
        Task {
            await viewModel.logDrift(
                category: category,
                note: driftNote.isEmpty ? nil : driftNote,
                prayerPlayed: audioPlayer.isPlaying || audioPlayer.progress > 0
            )
            driftNote = ""
            selectedCategory = nil
            audioPlayer.stop()
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

// MARK: - Prayer Audio Player
struct PrayerAudioPlayer: View {
    let category: DriftCategory
    @ObservedObject var audioPlayer: AudioPlayerManager

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "waveform.circle.fill")
                    .font(.title2)
                    .foregroundColor(ABTheme.sageGreen)

                Text("Anchoring Prayer Audio")
                    .font(.system(.subheadline, design: .serif, weight: .medium))
                    .foregroundColor(ABTheme.primaryText)

                Spacer()

                Text("~25 sec")
                    .font(.caption2)
                    .foregroundColor(ABTheme.secondaryText)
            }

            // Play button with progress
            Button {
                if audioPlayer.isPlaying {
                    audioPlayer.pause()
                } else if audioPlayer.progress > 0 {
                    audioPlayer.resume()
                } else {
                    // Play the prayer audio (filename matches category)
                    audioPlayer.playPrayer(named: "prayer_\(category.rawValue.lowercased())")
                }
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: audioPlayer.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.title)
                        .foregroundColor(.white)

                    Text(audioPlayer.isPlaying ? "Pause Prayer" : "Play Prayer")
                        .font(.system(.body, design: .serif, weight: .semibold))
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    LinearGradient(
                        colors: [ABTheme.sageGreen, ABTheme.sageGreenDark],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(ABTheme.cornerRadius)
            }

            // Progress bar
            if audioPlayer.progress > 0 {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(ABTheme.sageGreen.opacity(0.15))
                            .frame(height: 4)

                        Capsule()
                            .fill(ABTheme.sageGreen)
                            .frame(width: geo.size.width * audioPlayer.progress, height: 4)
                    }
                }
                .frame(height: 4)

                HStack {
                    Text(AudioPlayerManager.formatTime(audioPlayer.currentTime))
                    Spacer()
                    Text(AudioPlayerManager.formatTime(audioPlayer.duration))
                }
                .font(.caption2)
                .foregroundColor(ABTheme.secondaryText)
            }
        }
        .padding(ABTheme.paddingMedium)
        .background(ABTheme.sageGreen.opacity(0.05))
        .cornerRadius(ABTheme.cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: ABTheme.cornerRadius)
                .stroke(ABTheme.sageGreen.opacity(0.15), lineWidth: 1)
        )
    }
}

#Preview {
    DriftLogView()
        .environmentObject(FirestoreService())
}
