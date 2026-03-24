import SwiftUI

// MARK: - Onboarding View
/// Welcome screens introducing the app's vision and core features
struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var currentPage = 0

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            title: "Anchor & Bloom",
            subtitle: "Rooted in Christ.\nBlooming into who God created you to be.",
            scripture: "\"Be on your guard; stand firm in the faith;\nbe courageous; be strong.\nDo everything in love.\"\n— 1 Corinthians 16:13-14",
            iconName: "tree.fill",
            accentColor: ABTheme.sageGreen
        ),
        OnboardingPage(
            title: "Anchor Your Morning",
            subtitle: "Start each day rooted in Scripture and truth. Identify the lies the enemy whispers — comparison, fear, perfectionism — and stand firm in who God says you are.",
            scripture: "\"She is clothed with strength and dignity;\nshe can laugh at the days to come.\"\n— Proverbs 31:25",
            iconName: "sunrise.fill",
            accentColor: ABTheme.warmGold
        ),
        OnboardingPage(
            title: "Bloom Each Evening",
            subtitle: "Reflect on how you nurtured, spoke truth, cultivated peace, and advanced God's kingdom today. Celebrate the woman He's growing you to be.",
            scripture: "\"She speaks with wisdom,\nand faithful instruction is on her tongue.\"\n— Proverbs 31:26",
            iconName: "camera.macro",
            accentColor: ABTheme.blush
        ),
        OnboardingPage(
            title: "Grow Together",
            subtitle: "Join Sister Circles for encouragement. Track your growth with a blooming tree. Walk guided 30-day journeys into deeper faith.",
            scripture: "\"As iron sharpens iron,\nso one person sharpens another.\"\n— Proverbs 27:17",
            iconName: "heart.circle.fill",
            accentColor: ABTheme.sageGreen
        )
    ]

    var body: some View {
        ZStack {
            ABTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                TabView(selection: $currentPage) {
                    ForEach(pages.indices, id: \.self) { index in
                        OnboardingPageView(page: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentPage)

                // Page indicator and buttons
                VStack(spacing: ABTheme.paddingLarge) {
                    // Custom page dots
                    HStack(spacing: 8) {
                        ForEach(pages.indices, id: \.self) { index in
                            Circle()
                                .fill(index == currentPage ? ABTheme.sageGreen : ABTheme.sageGreen.opacity(0.25))
                                .frame(width: index == currentPage ? 10 : 7, height: index == currentPage ? 10 : 7)
                                .animation(.spring(response: 0.3), value: currentPage)
                        }
                    }

                    if currentPage == pages.count - 1 {
                        Button("Begin Your Journey") {
                            withAnimation {
                                hasCompletedOnboarding = true
                            }
                        }
                        .buttonStyle(ABPrimaryButtonStyle())
                        .padding(.horizontal, ABTheme.paddingXLarge)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                    } else {
                        HStack {
                            Button("Skip") {
                                withAnimation {
                                    hasCompletedOnboarding = true
                                }
                            }
                            .foregroundColor(ABTheme.secondaryText)
                            .font(.system(.body, design: .serif))

                            Spacer()

                            Button {
                                withAnimation {
                                    currentPage += 1
                                }
                            } label: {
                                HStack(spacing: 6) {
                                    Text("Next")
                                    Image(systemName: "arrow.right")
                                }
                                .foregroundColor(ABTheme.sageGreen)
                                .font(.system(.body, design: .serif, weight: .semibold))
                            }
                        }
                        .padding(.horizontal, ABTheme.paddingXLarge)
                    }
                }
                .padding(.bottom, ABTheme.paddingXLarge)
            }
        }
    }
}

// MARK: - Onboarding Page Data
struct OnboardingPage {
    let title: String
    let subtitle: String
    let scripture: String
    let iconName: String
    let accentColor: Color
}

// MARK: - Onboarding Page View
struct OnboardingPageView: View {
    let page: OnboardingPage

    var body: some View {
        VStack(spacing: ABTheme.paddingLarge) {
            Spacer()

            // Icon with decorative ring
            ZStack {
                Circle()
                    .stroke(page.accentColor.opacity(0.2), lineWidth: 2)
                    .frame(width: 140, height: 140)

                Circle()
                    .fill(page.accentColor.opacity(0.1))
                    .frame(width: 120, height: 120)

                Image(systemName: page.iconName)
                    .font(.system(size: 48))
                    .foregroundColor(page.accentColor)
            }

            // Title
            Text(page.title)
                .font(ABTheme.titleFont)
                .foregroundColor(ABTheme.primaryText)
                .multilineTextAlignment(.center)

            // Subtitle
            Text(page.subtitle)
                .font(ABTheme.bodyFont)
                .foregroundColor(ABTheme.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, ABTheme.paddingLarge)
                .lineSpacing(4)

            // Scripture
            Text(page.scripture)
                .font(ABTheme.scriptureFont)
                .foregroundColor(ABTheme.sageGreenDark)
                .multilineTextAlignment(.center)
                .padding(.horizontal, ABTheme.paddingLarge)
                .padding(.vertical, ABTheme.paddingMedium)
                .background(
                    RoundedRectangle(cornerRadius: ABTheme.cornerRadius)
                        .fill(ABTheme.sageGreen.opacity(0.08))
                )
                .padding(.horizontal, ABTheme.paddingMedium)

            Spacer()
            Spacer()
        }
    }
}

#Preview {
    OnboardingView()
}
