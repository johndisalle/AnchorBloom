import SwiftUI

// MARK: - AI Devotional Response View
/// Beautiful animated view showing the Claude AI's personalized response after a reflection
struct AIDevotionalResponseView: View {
    let response: String
    let isGenerating: Bool
    let onDismiss: () -> Void

    @State private var visibleText = ""
    @State private var isAnimating = true
    @StateObject private var audioService = AudioDevotionalService()

    var body: some View {
        VStack(spacing: ABTheme.paddingMedium) {
            // Header
            HStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(ABTheme.warmGold.opacity(0.15))
                        .frame(width: 36, height: 36)

                    Image(systemName: "sparkles")
                        .font(.system(size: 14))
                        .foregroundColor(ABTheme.warmGold)
                }

                VStack(alignment: .leading, spacing: 1) {
                    Text("A Word for You")
                        .font(.system(.caption, design: .serif, weight: .semibold))
                        .foregroundColor(ABTheme.primaryText)
                    Text("From your AI devotional companion")
                        .font(.system(size: 10))
                        .foregroundColor(ABTheme.secondaryText)
                }

                Spacer()

                // Listen button
                if !isGenerating && !response.isEmpty {
                    Button {
                        Task {
                            let key = String(response.prefix(30)).replacingOccurrences(of: " ", with: "_")
                            await audioService.play(text: response, cacheKey: "ai_\(key.hashValue)")
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: audioService.isPlaying ? "pause.circle.fill" : "headphones.circle.fill")
                                .font(.body)
                            Text(audioService.isLoading ? "Loading..." : (audioService.isPlaying ? "Pause" : "Listen"))
                                .font(.system(.caption2, design: .serif, weight: .medium))
                        }
                        .foregroundColor(ABTheme.sageGreen)
                    }
                    .disabled(audioService.isLoading)
                }
            }

            // Divider
            Rectangle()
                .fill(ABTheme.warmGold.opacity(0.2))
                .frame(height: 1)

            // Response content
            if isGenerating {
                generatingState
            } else {
                responseText
            }
        }
        .padding(ABTheme.paddingMedium)
        .background(
            RoundedRectangle(cornerRadius: ABTheme.cornerRadius)
                .fill(ABTheme.cardBackground)
                .shadow(color: ABTheme.warmGold.opacity(0.1), radius: 12, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: ABTheme.cornerRadius)
                .stroke(ABTheme.warmGold.opacity(0.15), lineWidth: 1)
        )
        .onAppear {
            if !response.isEmpty {
                animateText()
            }
        }
    }

    // MARK: - Generating State

    private var generatingState: some View {
        HStack(spacing: 10) {
            ProgressView()
                .tint(ABTheme.warmGold)
                .scaleEffect(0.8)

            VStack(alignment: .leading, spacing: 2) {
                Text("Reading your reflection...")
                    .font(.system(.caption, design: .serif, weight: .medium))
                    .foregroundColor(ABTheme.primaryText)
                Text("Preparing a word just for you")
                    .font(.caption2)
                    .foregroundColor(ABTheme.secondaryText)
            }

            Spacer()
        }
        .padding(.vertical, ABTheme.paddingSmall)
    }

    // MARK: - Response Text

    private var responseText: some View {
        VStack(alignment: .leading, spacing: ABTheme.paddingSmall) {
            Text(isAnimating ? visibleText : response)
                .font(.system(.body, design: .serif))
                .foregroundColor(ABTheme.primaryText)
                .lineSpacing(5)

            if isAnimating {
                // Typing cursor
                Rectangle()
                    .fill(ABTheme.warmGold)
                    .frame(width: 2, height: 16)
                    .opacity(0.7)
            }
        }
    }

    // MARK: - Typing Animation

    private func animateText() {
        visibleText = ""
        isAnimating = true
        let characters = Array(response)
        var index = 0

        Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { timer in
            if index < characters.count {
                visibleText.append(characters[index])
                index += 1
            } else {
                timer.invalidate()
                isAnimating = false
            }
        }
    }
}

// MARK: - AI Usage Banner
/// Shows free users their remaining AI responses and premium upsell
struct AIUsageBanner: View {
    let usedThisWeek: Int
    let isPremium: Bool
    let onUpgrade: () -> Void

    var body: some View {
        if isPremium { return AnyView(EmptyView()) }

        let remaining = max(0, 1 - usedThisWeek)

        return AnyView(
            HStack(spacing: 10) {
                Image(systemName: remaining > 0 ? "sparkles" : "lock.fill")
                    .font(.caption)
                    .foregroundColor(remaining > 0 ? ABTheme.warmGold : ABTheme.secondaryText)

                VStack(alignment: .leading, spacing: 1) {
                    Text(remaining > 0 ? "1 free AI response this week" : "AI responses used this week")
                        .font(.system(.caption, design: .serif, weight: .medium))
                        .foregroundColor(ABTheme.primaryText)
                    Text(remaining > 0 ? "Get personalized scripture after your reflection" : "Upgrade for unlimited personalized responses")
                        .font(.caption2)
                        .foregroundColor(ABTheme.secondaryText)
                }

                Spacer()

                if remaining == 0 {
                    Button {
                        onUpgrade()
                    } label: {
                        Text("Upgrade")
                            .font(.system(.caption2, design: .serif, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(ABTheme.warmGold)
                            .cornerRadius(12)
                    }
                }
            }
            .padding(ABTheme.paddingSmall)
            .background(ABTheme.warmGold.opacity(0.08))
            .cornerRadius(ABTheme.cornerRadiusSmall)
        )
    }
}
