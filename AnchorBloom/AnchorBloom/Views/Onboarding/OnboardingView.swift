import SwiftUI

// MARK: - Onboarding View
/// Emotional 3-screen onboarding that creates conviction and excitement before sign-up
struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var currentPage = 0

    var body: some View {
        ZStack {
            ABTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                TabView(selection: $currentPage) {
                    // Page 1: The Pain Point
                    OnboardingEmotionalPage(
                        headline: "You were never meant\nto carry it alone.",
                        message: "The comparison. The exhaustion. The quiet voice saying you're not enough.\n\nSister, that voice is a lie.",
                        scripture: "\"Come to me, all you who are weary and burdened, and I will give you rest.\"",
                        reference: "Matthew 11:28",
                        iconName: "heart.slash",
                        accentColor: ABTheme.blush
                    )
                    .tag(0)

                    // Page 2: The Promise
                    OnboardingEmotionalPage(
                        headline: "What if every morning\nstarted with God's truth?",
                        message: "Imagine replacing fear with faith. Comparison with calling. Doubt with the unshakeable knowledge that the God of the universe chose you.\n\nThat's what this app is for.",
                        scripture: "\"She is clothed with strength and dignity; she can laugh at the days to come.\"",
                        reference: "Proverbs 31:25",
                        iconName: "sunrise.fill",
                        accentColor: ABTheme.warmGold
                    )
                    .tag(1)

                    // Page 3: The Invitation
                    OnboardingEmotionalPage(
                        headline: "Root yourself in Christ.\nBloom into who He\ncreated you to be.",
                        message: "Daily scripture anchors. Evening reflections. A community of women walking this road with you.\n\nYour growth starts today.",
                        scripture: "\"I am the vine; you are the branches. If you remain in me and I in you, you will bear much fruit.\"",
                        reference: "John 15:5",
                        iconName: "tree.fill",
                        accentColor: ABTheme.sageGreen,
                        showCTA: true,
                        onBegin: {
                            withAnimation(.easeInOut(duration: 0.4)) {
                                hasCompletedOnboarding = true
                            }
                        }
                    )
                    .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.4), value: currentPage)

                // Page dots + navigation
                VStack(spacing: ABTheme.paddingLarge) {
                    HStack(spacing: 8) {
                        ForEach(0..<3, id: \.self) { index in
                            Capsule()
                                .fill(index == currentPage ? ABTheme.sageGreen : ABTheme.sageGreen.opacity(0.2))
                                .frame(width: index == currentPage ? 24 : 8, height: 8)
                                .animation(.spring(response: 0.3), value: currentPage)
                        }
                    }

                    if currentPage < 2 {
                        Button {
                            withAnimation { currentPage += 1 }
                        } label: {
                            HStack(spacing: 8) {
                                Text("Continue")
                                Image(systemName: "arrow.right")
                            }
                            .font(.system(.body, design: .serif, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(ABTheme.sageGreen)
                            .cornerRadius(ABTheme.cornerRadius)
                        }
                        .padding(.horizontal, ABTheme.paddingXLarge)
                    }
                }
                .padding(.bottom, 40)
            }
        }
    }
}

// MARK: - Emotional Onboarding Page
struct OnboardingEmotionalPage: View {
    let headline: String
    let message: String
    let scripture: String
    let reference: String
    let iconName: String
    let accentColor: Color
    var showCTA: Bool = false
    var onBegin: (() -> Void)? = nil

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 28) {
                Spacer().frame(height: 40)

                // Icon
                ZStack {
                    Circle()
                        .fill(accentColor.opacity(0.1))
                        .frame(width: 100, height: 100)

                    Image(systemName: iconName)
                        .font(.system(size: 40))
                        .foregroundColor(accentColor)
                }

                // Headline
                Text(headline)
                    .font(.system(size: 26, weight: .bold, design: .serif))
                    .foregroundColor(ABTheme.primaryText)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)

                // Body
                Text(message)
                    .font(.system(size: 16, design: .serif))
                    .foregroundColor(ABTheme.secondaryText)
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
                    .padding(.horizontal, ABTheme.paddingLarge)

                // Scripture card
                VStack(spacing: 8) {
                    Text(scripture)
                        .font(.system(size: 15, design: .serif).italic())
                        .foregroundColor(ABTheme.sageGreenDark)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)

                    Text("— \(reference)")
                        .font(.system(size: 13, weight: .semibold, design: .serif))
                        .foregroundColor(ABTheme.sageGreen)
                }
                .padding(.horizontal, ABTheme.paddingLarge)
                .padding(.vertical, ABTheme.paddingMedium)
                .background(
                    RoundedRectangle(cornerRadius: ABTheme.cornerRadius)
                        .fill(ABTheme.sageGreen.opacity(0.08))
                )
                .padding(.horizontal, ABTheme.paddingMedium)

                // CTA button on last page
                if showCTA {
                    Button {
                        onBegin?()
                    } label: {
                        Text("Begin Your Journey")
                            .font(.system(.body, design: .serif, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(
                                LinearGradient(
                                    colors: [ABTheme.sageGreen, ABTheme.sageGreenDark],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(ABTheme.cornerRadius)
                            .shadow(color: ABTheme.sageGreen.opacity(0.3), radius: 8, y: 4)
                    }
                    .padding(.horizontal, ABTheme.paddingXLarge)
                    .padding(.top, 8)
                }

                Spacer().frame(height: 80)
            }
        }
    }
}

#Preview {
    OnboardingView()
}
