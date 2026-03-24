import SwiftUI

// MARK: - Evening Bloom View
/// Evening reflection on biblical womanhood roles and purposeful living
struct BloomView: View {
    @ObservedObject var viewModel: AppViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var reflectionText = ""
    @State private var selectedRoles: Set<BloomRole> = []
    @State private var isSaving = false
    @State private var showCompletionAnimation = false

    private var todayPrompt: DailyPrompt {
        DailyPrompt.eveningPrompt(for: Date())
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: ABTheme.paddingLarge) {
                    // Evening greeting
                    eveningHeader

                    // Prompt card
                    promptCard

                    // Role selection
                    roleSection

                    // Reflection
                    reflectionSection

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

    // MARK: - Evening Header
    private var eveningHeader: some View {
        VStack(spacing: 8) {
            Image(systemName: "moon.stars.fill")
                .font(.title)
                .foregroundColor(ABTheme.blush)

            Text("How did you bloom today?")
                .font(ABTheme.headlineFont)
                .foregroundColor(ABTheme.primaryText)

            Text(todayPrompt.scripture)
                .font(ABTheme.scriptureFont)
                .foregroundColor(ABTheme.secondaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(3)

            Text(todayPrompt.scriptureReference)
                .font(.system(.caption, design: .serif, weight: .semibold))
                .foregroundColor(ABTheme.blushDark)
        }
        .abCard()
    }

    // MARK: - Prompt Card
    private var promptCard: some View {
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

    // MARK: - Role Selection
    private var roleSection: some View {
        VStack(alignment: .leading, spacing: ABTheme.paddingMedium) {
            Text("How did you walk in your calling today?")
                .font(.system(.subheadline, design: .serif, weight: .medium))
                .foregroundColor(ABTheme.primaryText)

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
    }

    // MARK: - Reflection Section
    private var reflectionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Your evening reflection")
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

    // MARK: - Bloom Completion Overlay
    private var bloomCompletionOverlay: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()

            VStack(spacing: ABTheme.paddingMedium) {
                // Animated flower
                FlowerView(color: ABTheme.blush, size: 80)
                    .rotationEffect(.degrees(showCompletionAnimation ? 0 : -15))
                    .animation(.spring(response: 0.6, dampingFraction: 0.5), value: showCompletionAnimation)

                Text("Beautifully Bloomed")
                    .font(ABTheme.headlineFont)
                    .foregroundColor(ABTheme.primaryText)

                Text("You walked in purpose today.\nGod is growing something beautiful in you.")
                    .font(ABTheme.bodyFont)
                    .foregroundColor(ABTheme.secondaryText)
                    .multilineTextAlignment(.center)
            }
            .padding(ABTheme.paddingXLarge)
            .background(ABTheme.softWhite)
            .cornerRadius(ABTheme.cornerRadius)
            .shadow(radius: 20)
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
            withAnimation(.spring(response: 0.4)) {
                showCompletionAnimation = true
            }
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            dismiss()
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
