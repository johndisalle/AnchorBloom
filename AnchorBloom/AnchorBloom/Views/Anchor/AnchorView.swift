import SwiftUI

// MARK: - Morning Anchor View
/// Daily morning devotional: Scripture → Drift tags → Reflection prompt → Response → Open in prayer
struct AnchorView: View {
    @ObservedObject var viewModel: AppViewModel
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @Environment(\.dismiss) private var dismiss

    @State private var reflectionText = ""
    @State private var selectedTags: Set<AnchorTag> = []
    @State private var isSaving = false
    @State private var showCompletionAnimation = false
    @StateObject private var aiService = ClaudeAIService()
    @StateObject private var audioService = AudioDevotionalService()
    @State private var aiResponse: String?

    private var todayPrompt: DailyPrompt {
        DailyPrompt.morningPrompt(for: Date())
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: ABTheme.paddingLarge) {
                    // 1. Verse
                    scriptureCard

                    // 2. Drift tags
                    driftSection

                    // 3. Today's Reflection
                    reflectionPromptCard

                    // 3b. Premium Deeper Reflection
                    if subscriptionManager.isPremium {
                        deeperReflectionCard
                    }

                    // 4. Your reflection response box
                    reflectionSection

                    // 5. Open in prayer
                    openInPrayerSection

                    // Save button
                    Button {
                        saveAnchor()
                    } label: {
                        HStack {
                            Image(systemName: "anchor")
                            Text("Anchor My Heart")
                        }
                    }
                    .buttonStyle(ABPrimaryButtonStyle())
                    .disabled(isSaving)

                    Spacer().frame(height: 40)
                }
                .padding(.horizontal, ABTheme.paddingMedium)
                .padding(.top, ABTheme.paddingMedium)
            }
            .background(ABTheme.morningGradient.ignoresSafeArea())
            .navigationTitle("Morning Anchor")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") { dismiss() }
                        .foregroundColor(ABTheme.sageGreen)
                }
            }
            .overlay {
                if showCompletionAnimation {
                    completionOverlay
                }
            }
        }
    }

    // MARK: - 1. Scripture Card (Verse) + Audio
    private var scriptureCard: some View {
        VStack(spacing: ABTheme.paddingMedium) {
            Image(systemName: "book.closed.fill")
                .font(.title2)
                .foregroundColor(ABTheme.warmGold)

            Text(todayPrompt.scripture)
                .font(ABTheme.scriptureFont)
                .foregroundColor(ABTheme.primaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            Text(todayPrompt.scriptureReference)
                .font(.system(.caption, design: .serif, weight: .semibold))
                .foregroundColor(ABTheme.sageGreen)

            HStack(spacing: 16) {
                ScriptureActionButtons(
                    verseText: todayPrompt.scripture,
                    reference: todayPrompt.scriptureReference,
                    source: .morningAnchor
                )
                ListenButton(
                    audioService: audioService,
                    text: todayPrompt.scripture,
                    cacheKey: "anchor_verse_\(todayPrompt.scriptureReference)",
                    isPremium: subscriptionManager.isPremium
                )
            }
        }
        .abCard()
    }

    // MARK: - 2. Drift Section
    private var driftSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "wind")
                    .foregroundColor(ABTheme.warmGold)
                Text("Any drift pulling at you today?")
                    .font(ABTheme.subheadlineFont)
                    .foregroundColor(ABTheme.primaryText)
            }

            FlowLayout(spacing: 8) {
                ForEach(AnchorTag.allCases, id: \.self) { tag in
                    TagChip(
                        tag: tag.rawValue,
                        icon: tag.icon,
                        isSelected: selectedTags.contains(tag)
                    ) {
                        if selectedTags.contains(tag) {
                            selectedTags.remove(tag)
                        } else {
                            selectedTags.insert(tag)
                        }
                    }
                }
            }

            // Show anchoring verse for selected tag
            if let firstTag = selectedTags.first {
                Text(firstTag.anchoringVerse)
                    .font(.system(.caption, design: .serif).italic())
                    .foregroundColor(ABTheme.sageGreenDark)
                    .padding(ABTheme.paddingSmall)
                    .background(ABTheme.sageGreen.opacity(0.08))
                    .cornerRadius(8)
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
                    .animation(.easeInOut, value: selectedTags)
            }
        }
        .abCard()
    }

    // MARK: - 3. Today's Reflection
    private var reflectionPromptCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(ABTheme.warmGold)
                Text("Today's Reflection")
                    .font(ABTheme.subheadlineFont)
                    .foregroundColor(ABTheme.primaryText)
            }

            Text(todayPrompt.prompt)
                .font(ABTheme.bodyFont)
                .foregroundColor(ABTheme.secondaryText)
                .lineSpacing(4)
        }
        .abCard()
    }

    // MARK: - 3b. Premium Deeper Reflection
    private var deeperReflectionCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "crown.fill")
                    .foregroundColor(ABTheme.warmGold)
                Text("Go Deeper")
                    .font(ABTheme.subheadlineFont)
                    .foregroundColor(ABTheme.primaryText)
            }

            Text(DailyPrompt.premiumMorningReflection(for: Date()))
                .font(ABTheme.bodyFont)
                .foregroundColor(ABTheme.secondaryText)
                .lineSpacing(4)
        }
        .abCard()
        .overlay(
            RoundedRectangle(cornerRadius: ABTheme.cornerRadius)
                .stroke(ABTheme.warmGold.opacity(0.3), lineWidth: 1)
        )
    }

    // MARK: - 4. Your Reflection Response Box
    private var reflectionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Your reflection")
                .font(.system(.subheadline, design: .serif, weight: .medium))
                .foregroundColor(ABTheme.primaryText)

            TextEditor(text: $reflectionText)
                .font(ABTheme.bodyFont)
                .frame(minHeight: 100)
                .padding(ABTheme.paddingSmall)
                .background(ABTheme.softWhite)
                .cornerRadius(ABTheme.cornerRadiusSmall)
                .overlay(
                    RoundedRectangle(cornerRadius: ABTheme.cornerRadiusSmall)
                        .stroke(ABTheme.sageGreen.opacity(0.2), lineWidth: 1)
                )
                .overlay(alignment: .topLeading) {
                    if reflectionText.isEmpty {
                        Text("Write what's on your heart...")
                            .font(ABTheme.bodyFont)
                            .foregroundColor(ABTheme.secondaryText.opacity(0.5))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 16)
                            .allowsHitTesting(false)
                    }
                }
        }
    }

    // MARK: - 5. Open in Prayer + Audio
    private static let anchorPrayerText = "Lord, anchor my heart in Your truth today. Guard my mind from the enemy's lies and help me walk confidently in who You've called me to be. Amen."

    private var openInPrayerSection: some View {
        VStack(spacing: 10) {
            HStack {
                Spacer()
                Image(systemName: "hands.sparkles.fill")
                    .font(.title2)
                    .foregroundColor(ABTheme.warmGold)
                Spacer()
            }

            Text("Open in Prayer")
                .font(ABTheme.subheadlineFont)
                .foregroundColor(ABTheme.primaryText)

            Text(Self.anchorPrayerText)
                .font(ABTheme.bodyFont)
                .foregroundColor(ABTheme.secondaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            // Premium audio: listen to prayer read aloud
            ListenButton(
                audioService: audioService,
                text: Self.anchorPrayerText,
                cacheKey: "anchor_prayer",
                isPremium: subscriptionManager.isPremium
            )
        }
        .abCard()
    }

    // MARK: - Completion Overlay
    private var completionOverlay: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture { dismiss() }

            ScrollView {
                VStack(spacing: ABTheme.paddingMedium) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 60))
                        .foregroundColor(ABTheme.sageGreen)

                    Text("Anchored")
                        .font(ABTheme.headlineFont)
                        .foregroundColor(ABTheme.primaryText)

                    Text("Your heart is rooted in truth today.")
                        .font(ABTheme.bodyFont)
                        .foregroundColor(ABTheme.secondaryText)

                    // AI Devotional Response (with error/timeout handling)
                    if aiService.isGenerating || aiResponse != nil || aiService.errorMessage != nil {
                        if let error = aiService.errorMessage {
                            // Error state — don't leave user stuck
                            HStack(spacing: 8) {
                                Image(systemName: "exclamationmark.circle")
                                    .foregroundColor(ABTheme.secondaryText)
                                Text(error)
                                    .font(.caption)
                                    .foregroundColor(ABTheme.secondaryText)
                            }
                            .padding(ABTheme.paddingSmall)
                        } else {
                            AIDevotionalResponseView(
                                response: aiResponse ?? "",
                                isGenerating: aiService.isGenerating,
                                onDismiss: { dismiss() }
                            )
                            .padding(.top, ABTheme.paddingSmall)
                        }
                    }

                    // Always show Continue — never leave user stuck
                    Button { dismiss() } label: {
                        Text(aiService.isGenerating ? "Skip & Continue →" : "Continue →")
                            .font(.system(.body, design: .serif, weight: .semibold))
                            .foregroundColor(ABTheme.sageGreen)
                    }
                    .padding(.top, ABTheme.paddingSmall)
                }
                .padding(ABTheme.paddingLarge)
                .background(ABTheme.softWhite)
                .cornerRadius(ABTheme.cornerRadius)
                .shadow(radius: 20)
                .padding(.horizontal, ABTheme.paddingMedium)
                .padding(.vertical, 60)
            }
            .transition(.scale.combined(with: .opacity))
        }
    }

    // MARK: - Save
    private func saveAnchor() {
        isSaving = true
        Task {
            await viewModel.saveMorningAnchor(
                reflection: reflectionText.isEmpty ? nil : reflectionText,
                tags: Array(selectedTags),
                scriptureRef: todayPrompt.scriptureReference
            )
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            withAnimation(.spring(response: 0.4)) {
                showCompletionAnimation = true
            }

            // Generate AI response if user wrote a reflection
            if !reflectionText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                let context = DevotionalContext(
                    type: .morningAnchor,
                    displayName: viewModel.userProfile?.displayName ?? "Sister",
                    streakDays: viewModel.userProfile?.currentStreak ?? 0,
                    tags: Array(selectedTags).map { $0.rawValue },
                    roles: [],
                    scriptureReference: todayPrompt.scriptureReference
                )
                aiResponse = await aiService.generateResponse(reflection: reflectionText, context: context)
            } else {
                try? await Task.sleep(nanoseconds: 2_000_000_000)
                dismiss()
            }
        }
    }
}

// MARK: - Tag Chip
struct TagChip: View {
    let tag: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption2)
                Text(tag)
                    .font(.system(.caption, design: .serif))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(isSelected ? ABTheme.sageGreen : ABTheme.sageGreen.opacity(0.08))
            .foregroundColor(isSelected ? .white : ABTheme.primaryText)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(ABTheme.sageGreen.opacity(0.3), lineWidth: isSelected ? 0 : 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Flow Layout
/// A layout that wraps content horizontally (for tags)
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = flowLayout(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = flowLayout(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y), proposal: .unspecified)
        }
    }

    private func flowLayout(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0
        var maxX: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > maxWidth && currentX > 0 {
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
            }
            positions.append(CGPoint(x: currentX, y: currentY))
            lineHeight = max(lineHeight, size.height)
            currentX += size.width + spacing
            maxX = max(maxX, currentX)
        }

        return (CGSize(width: maxX, height: currentY + lineHeight), positions)
    }
}

#Preview {
    AnchorView(viewModel: AppViewModel(firestoreService: FirestoreService()))
}
