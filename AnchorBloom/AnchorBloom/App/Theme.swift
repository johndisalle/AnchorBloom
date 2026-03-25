import SwiftUI

// MARK: - Adaptive Color Helper
/// Creates a Color that resolves differently in light vs dark mode
private func adaptive(light: UIColor, dark: UIColor) -> Color {
    Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark ? dark : light
    })
}

// MARK: - Anchor & Bloom Theme
/// Soft feminine color palette: sage green, blush, warm gold, cream, dark navy
/// Supports light and dark mode via adaptive colors
struct ABTheme {
    // MARK: - Brand Colors (same in both modes)
    static let sageGreen = Color(red: 0.56, green: 0.68, blue: 0.58)       // #8FAD94
    static let sageGreenDark = Color(red: 0.40, green: 0.52, blue: 0.42)   // #66856B
    static let blush = Color(red: 0.89, green: 0.72, blue: 0.72)           // #E3B8B8
    static let blushDark = Color(red: 0.78, green: 0.55, blue: 0.55)       // #C78C8C
    static let warmGold = Color(red: 0.85, green: 0.75, blue: 0.55)        // #D9BF8C
    static let warmGoldLight = adaptive(
        light: UIColor(red: 0.93, green: 0.87, blue: 0.73, alpha: 1),      // #EDDEBA
        dark: UIColor(red: 0.55, green: 0.48, blue: 0.30, alpha: 1)        // darker gold
    )

    // MARK: - Surface Colors (adaptive)
    static let cream = adaptive(
        light: UIColor(red: 0.97, green: 0.95, blue: 0.91, alpha: 1),      // #F8F2E8
        dark: UIColor(red: 0.10, green: 0.10, blue: 0.12, alpha: 1)        // near black
    )
    static let darkNavy = Color(red: 0.15, green: 0.18, blue: 0.27)        // #262E45
    static let softWhite = adaptive(
        light: UIColor(red: 0.99, green: 0.98, blue: 0.96, alpha: 1),      // #FDFAF5
        dark: UIColor(red: 0.15, green: 0.15, blue: 0.17, alpha: 1)        // dark card
    )

    // MARK: - Semantic Colors (adaptive)
    static let primaryText = adaptive(
        light: UIColor(red: 0.15, green: 0.18, blue: 0.27, alpha: 1),      // darkNavy
        dark: UIColor(red: 0.93, green: 0.91, blue: 0.88, alpha: 1)        // warm off-white
    )
    static let secondaryText = adaptive(
        light: UIColor(red: 0.45, green: 0.48, blue: 0.55, alpha: 1),
        dark: UIColor(red: 0.62, green: 0.60, blue: 0.57, alpha: 1)        // muted warm gray
    )
    static let background = cream
    static let cardBackground = softWhite
    static let accent = sageGreen
    static let accentSecondary = blush
    static let accentTertiary = warmGold
    static let destructive = Color(red: 0.82, green: 0.40, blue: 0.40)

    // MARK: - Gradients
    static let morningGradient = LinearGradient(
        colors: [warmGoldLight, cream, softWhite],
        startPoint: .top,
        endPoint: .bottom
    )

    static let eveningGradient = LinearGradient(
        colors: [
            Color(red: 0.20, green: 0.22, blue: 0.35),
            Color(red: 0.35, green: 0.30, blue: 0.45),
            darkNavy
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    static let cardGradient = LinearGradient(
        colors: [softWhite, cream.opacity(0.5)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let bloomGradient = LinearGradient(
        colors: [blush.opacity(0.3), sageGreen.opacity(0.2)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let premiumGradient = LinearGradient(
        colors: [warmGold, Color(red: 0.78, green: 0.65, blue: 0.40)],
        startPoint: .leading,
        endPoint: .trailing
    )

    // MARK: - Typography
    static let titleFont = Font.system(.largeTitle, design: .serif, weight: .bold)
    static let headlineFont = Font.system(.title2, design: .serif, weight: .semibold)
    static let subheadlineFont = Font.system(.headline, design: .serif, weight: .medium)
    static let bodyFont = Font.system(.body, design: .default)
    static let captionFont = Font.system(.caption, design: .default)
    static let scriptureFont = Font.system(.body, design: .serif).italic()

    // MARK: - Spacing
    static let paddingSmall: CGFloat = 8
    static let paddingMedium: CGFloat = 16
    static let paddingLarge: CGFloat = 24
    static let paddingXLarge: CGFloat = 32
    static let cornerRadius: CGFloat = 16
    static let cornerRadiusSmall: CGFloat = 10

    // MARK: - Shadows
    static let cardShadow = Color.black.opacity(0.06)
    static let cardShadowRadius: CGFloat = 8
}

// MARK: - View Modifiers
struct ABCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(ABTheme.paddingMedium)
            .background(ABTheme.cardBackground)
            .cornerRadius(ABTheme.cornerRadius)
            .shadow(color: ABTheme.cardShadow, radius: ABTheme.cardShadowRadius, x: 0, y: 2)
    }
}

struct ABPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(.body, design: .serif, weight: .semibold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(ABTheme.sageGreen)
            .cornerRadius(ABTheme.cornerRadius)
            .opacity(configuration.isPressed ? 0.85 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

struct ABSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(.body, design: .serif, weight: .semibold))
            .foregroundColor(ABTheme.sageGreen)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(ABTheme.sageGreen.opacity(0.1))
            .cornerRadius(ABTheme.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: ABTheme.cornerRadius)
                    .stroke(ABTheme.sageGreen.opacity(0.3), lineWidth: 1)
            )
            .opacity(configuration.isPressed ? 0.85 : 1.0)
    }
}

struct ABPremiumButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(.body, design: .serif, weight: .semibold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(ABTheme.premiumGradient)
            .cornerRadius(ABTheme.cornerRadius)
            .opacity(configuration.isPressed ? 0.85 : 1.0)
    }
}

// MARK: - View Extensions
extension View {
    func abCard() -> some View {
        modifier(ABCardModifier())
    }

    func abScreenBackground() -> some View {
        self.background(ABTheme.background.ignoresSafeArea())
    }
}
