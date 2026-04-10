import SwiftUI

// MARK: - Audio Player Bar
/// Compact audio playback controls for devotional content
struct AudioPlayerBar: View {
    @ObservedObject var audioService: AudioDevotionalService
    let text: String
    let cacheKey: String
    let label: String

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 12) {
                // Play/Pause button
                Button {
                    if audioService.isPlaying || audioService.duration > 0 {
                        audioService.togglePlayPause()
                    } else {
                        Task {
                            await audioService.play(text: text, cacheKey: cacheKey)
                        }
                    }
                } label: {
                    ZStack {
                        Circle()
                            .fill(ABTheme.sageGreen)
                            .frame(width: 40, height: 40)

                        if audioService.isLoading {
                            ProgressView()
                                .tint(.white)
                                .scaleEffect(0.7)
                        } else {
                            Image(systemName: audioService.isPlaying ? "pause.fill" : "play.fill")
                                .font(.system(size: 14))
                                .foregroundColor(.white)
                                .offset(x: audioService.isPlaying ? 0 : 1)
                        }
                    }
                }
                .disabled(audioService.isLoading)

                VStack(alignment: .leading, spacing: 4) {
                    Text(label)
                        .font(.system(.caption, design: .serif, weight: .semibold))
                        .foregroundColor(ABTheme.primaryText)

                    // Progress bar
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(ABTheme.sageGreen.opacity(0.15))
                                .frame(height: 3)

                            RoundedRectangle(cornerRadius: 2)
                                .fill(ABTheme.sageGreen)
                                .frame(width: geo.size.width * audioService.playbackProgress, height: 3)
                        }
                    }
                    .frame(height: 3)

                    // Time
                    if audioService.duration > 0 {
                        HStack {
                            Text(formatTime(audioService.playbackProgress * audioService.duration))
                            Spacer()
                            Text(formatTime(audioService.duration))
                        }
                        .font(.system(size: 9))
                        .foregroundColor(ABTheme.secondaryText)
                    }
                }

                // Stop button
                if audioService.isPlaying || audioService.playbackProgress > 0 {
                    Button {
                        audioService.stop()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .foregroundColor(ABTheme.secondaryText.opacity(0.5))
                    }
                }
            }
        }
        .padding(ABTheme.paddingSmall)
        .background(ABTheme.sageGreen.opacity(0.05))
        .cornerRadius(ABTheme.cornerRadiusSmall)
    }

    private func formatTime(_ seconds: Double) -> String {
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%d:%02d", mins, secs)
    }
}

// MARK: - Inline Listen Button
/// Small "Listen" button for premium users. Shows lock icon for free users.
struct ListenButton: View {
    @ObservedObject var audioService: AudioDevotionalService
    let text: String
    let cacheKey: String
    var isPremium: Bool = true
    var onUpgrade: (() -> Void)?

    var body: some View {
        Button {
            if !isPremium {
                onUpgrade?()
                return
            }
            if audioService.isPlaying {
                audioService.togglePlayPause()
            } else {
                Task {
                    await audioService.play(text: text, cacheKey: cacheKey)
                }
            }
        } label: {
            HStack(spacing: 4) {
                if !isPremium {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 10))
                    Text("Listen")
                        .font(.system(.caption2, design: .serif, weight: .medium))
                } else if audioService.isLoading {
                    ProgressView()
                        .tint(ABTheme.sageGreen)
                        .scaleEffect(0.6)
                } else {
                    Image(systemName: audioService.isPlaying ? "pause.circle.fill" : "headphones.circle.fill")
                        .font(.caption)
                }
                if isPremium {
                    Text(audioService.isLoading ? "Loading..." : (audioService.isPlaying ? "Pause" : "Listen"))
                        .font(.system(.caption2, design: .serif, weight: .medium))
                }
            }
            .foregroundColor(isPremium ? ABTheme.sageGreen : ABTheme.warmGold)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(ABTheme.sageGreen.opacity(0.08))
            .cornerRadius(12)
        }
        .disabled(audioService.isLoading)
    }
}
