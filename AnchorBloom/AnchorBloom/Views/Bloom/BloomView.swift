import SwiftUI

// MARK: - Evening Bloom View
/// Evening reflection: Verse → Calling roles → Reflect prompt → Response → Close in prayer
struct BloomView: View {
    @ObservedObject var viewModel: AppViewModel
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @Environment(\.dismiss) private var dismiss

    @State private var reflectionText = ""
    @State private var selectedRoles: Set<BloomRole> = []
    @State private var isSaving = false
    @State private var showCompletionAnimation = false
    @StateObject private var aiService = ClaudeAIService()
    @StateObject private var audioService = AudioDevotionalService()
    @State private var aiResponse: String?

    private var todayPrompt: DailyPrompt {
        DailyPrompt.eveningPrompt(for: Date())
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: ABTheme.paddingLarge) {
                    // 1. Verse
                    scriptureCard

                    // 2. How did you walk in your calling today?
                    roleSection

                    // 3. Reflect
                    reflectPromptCard

                    // 3b. Premium Deeper Reflection
                    if subscriptionManager.isPremium {
                        deeperReflectionCard
                    }

                    // 4. Your reflect response box
                    reflectionSection

                    // 5. Close in prayer
                    closeInPrayerSection

                    // Save button
                    Button {
                        saveBloom()
                    } label: {
                        HStack {
                            Image(systemName: "camera.macro")
                            Text("I Bloomed Today")
                        }
                    }
                    .buttonStyle(ABPrimaryButtonStyle())
                    .disabled(isSaving)

                    Spacer().frame(height: 40)
                }
                .padding(.horizontal, ABTheme.paddingMedium)
                .padding(.top, ABTheme.paddingMedium)
            }
            .background(
                LinearGradient(
                    colors: [
                        ABTheme.blush.opacity(0.15),
                        ABTheme.cream,
                        ABTheme.softWhite
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
            .navigationTitle("Evening Bloom")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") { dismiss() }
                        .foregroundColor(ABTheme.sageGreen)
                }
            }
            .overlay {
                if showCompletionAnimation {
                    bloomCompletionOverlay
                }
            }
        }
    }

    // MARK: - 1. Verse
    private var scriptureCard: some View {
        VStack(spacing: ABTheme.paddingMedium) {
            Image(systemName: "moon.stars.fill")
                .font(.title2)
                .foregroundColor(ABTheme.blush)

            Text(todayPrompt.scripture)
                .font(ABTheme.scriptureFont)
                .foregroundColor(ABTheme.primaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            Text(todayPrompt.scriptureReference)
                .font(.system(.caption, design: .serif, weight: .semibold))
                .foregroundColor(ABTheme.blushDark)

            HStack(spacing: 16) {
                ScriptureActionButtons(
                    verseText: todayPrompt.scripture,
                    reference: todayPrompt.scriptureReference,
                    source: .eveningBloom
                )
                ListenButton(
                    audioService: audioService,
                    text: todayPrompt.scripture,
                    cacheKey: "bloom_verse_\(todayPrompt.scriptureReference)",
                    isPremium: subscriptionManager.isPremium
                )
            }
        }
        .abCard()
    }

    // MARK: - 2. How did you walk in your calling today?
    private var roleSection: some View {
        VStack(alignment: .leading, spacing: ABTheme.paddingMedium) {
            HStack {
                Image(systemName: "figure.walk")
                    .foregroundColor(ABTheme.blush)
                Text("How did you walk in your calling today?")
                    .font(ABTheme.subheadlineFont)
                    .foregroundColor(ABTheme.primaryText)
            }

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(BloomRole.allCases, id: \.self) { role in
                    RoleCard(
                        role: role,
                        isSelected: selectedRoles.contains(role)
                    ) {
                        if selectedRoles.contains(role) {
                            selectedRoles.remove(role)
                        } else {
                            selectedRoles.insert(role)
                        }
                    }
                }
            }

            // Show scripture for selected role
            if let firstRole = selectedRoles.first {
                VStack(alignment: .leading, spacing: 4) {
                    Text(firstRole.description)
                        .font(.system(.caption, design: .serif))
                        .foregroundColor(ABTheme.primaryText)

                    Text(firstRole.scriptureReference)
                        .font(.system(.caption2, design: .serif, weight: .semibold))
                        .foregroundColor(ABTheme.blushDark)
                }
                .padding(ABTheme.paddingSmall)
                .background(ABTheme.blush.opacity(0.1))
                .cornerRadius(8)
                .transition(.opacity)
                .animation(.easeInOut, value: selectedRoles)
            }
        }
        .abCard()
    }

    // MARK: - 3. Reflect
    private var reflectPromptCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(ABTheme.blush)
                Text("Reflect")
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

            Text(DailyPrompt.premiumEveningReflection(for: Date()))
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

    // MARK: - 4. Your Reflect Response Box
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
                        .stroke(ABTheme.blush.opacity(0.3), lineWidth: 1)
                )
                .overlay(alignment: .topLeading) {
                    if reflectionText.isEmpty {
                        Text("How did you nurture, speak truth gently, or cultivate peace today?")
                            .font(ABTheme.bodyFont)
                            .foregroundColor(ABTheme.secondaryText.opacity(0.5))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 16)
                            .allowsHitTesting(false)
                    }
                }
        }
    }

    // MARK: - 5. Close in Prayer + Audio
    private static let bloomPrayerText = "Lord, thank You for this day and the ways You moved through me. Where I fell short, cover me with grace. As I rest tonight, let the seeds planted today take root and bloom for Your glory. Amen."

    private var closeInPrayerSection: some View {
        VStack(spacing: 10) {
            Image(systemName: "hands.sparkles.fill")
                .font(.title2)
                .foregroundColor(ABTheme.blush)

            Text("Close in Prayer")
                .font(ABTheme.subheadlineFont)
                .foregroundColor(ABTheme.primaryText)

            Text(Self.bloomPrayerText)
                .font(ABTheme.bodyFont)
                .foregroundColor(ABTheme.secondaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            ListenButton(
                audioService: audioService,
                text: Self.bloomPrayerText,
                cacheKey: "bloom_prayer",
                isPremium: subscriptionManager.isPremium
            )
        }
        .abCard()
    }

    // MARK: - Bloom Completion Overlay
    private var bloomCompletionOverlay: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture { dismiss() }

            ScrollView {
                VStack(spacing: ABTheme.paddingMedium) {
                    PrettyFlower(petalColor: ABTheme.blush, centerColor: ABTheme.warmGold, size: 80, petalCount: 5)
                        .rotationEffect(.degrees(showCompletionAnimation ? 0 : -15))
                        .animation(.spring(response: 0.6, dampingFraction: 0.5), value: showCompletionAnimation)

                    Text("Beautifully Bloomed")
                        .font(ABTheme.headlineFont)
                        .foregroundColor(ABTheme.primaryText)

                    Text("You walked in purpose today.\nGod is growing something beautiful in you.")
                        .font(ABTheme.bodyFont)
                        .foregroundColor(ABTheme.secondaryText)
                        .multilineTextAlignment(.center)

                    // AI Devotional Response (with error/timeout handling)
                    if aiService.isGenerating || aiResponse != nil || aiService.errorMessage != nil {
                        if let error = aiService.errorMessage {
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
                            .foregroundColor(ABTheme.blush)
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
    private func saveBloom() {
        isSaving = true
        Task {
            await viewModel.saveEveningBloom(
                reflection: reflectionText.isEmpty ? nil : reflectionText,
                roles: Array(selectedRoles)
            )
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            withAnimation(.spring(response: 0.4)) {
                showCompletionAnimation = true
            }

            // Generate AI response if user wrote a reflection
            if !reflectionText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                let context = DevotionalContext(
                    type: .eveningBloom,
                    displayName: viewModel.userProfile?.displayName ?? "Sister",
                    streakDays: viewModel.userProfile?.currentStreak ?? 0,
                    tags: [],
                    roles: Array(selectedRoles).map { $0.rawValue },
                    scriptureReference: nil
                )
                aiResponse = await aiService.generateResponse(reflection: reflectionText, context: context)
            } else {
                try? await Task.sleep(nanoseconds: 2_000_000_000)
                dismiss()
            }
        }
    }
}

// MARK: - Role Card
struct RoleCard: View {
    let role: BloomRole
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: role.icon)
                    .font(.title3)
                    .foregroundColor(isSelected ? .white : ABTheme.blush)

                Text(role.rawValue)
                    .font(.system(.caption, design: .serif, weight: .medium))
                    .foregroundColor(isSelected ? .white : ABTheme.primaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(isSelected ? ABTheme.sageGreen : ABTheme.cardBackground)
            .cornerRadius(ABTheme.cornerRadiusSmall)
            .overlay(
                RoundedRectangle(cornerRadius: ABTheme.cornerRadiusSmall)
                    .stroke(isSelected ? Color.clear : ABTheme.blush.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

#Preview {
    BloomView(viewModel: AppViewModel(firestoreService: FirestoreService()))
}
