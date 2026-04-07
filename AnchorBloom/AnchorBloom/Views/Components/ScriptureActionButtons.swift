import SwiftUI

// MARK: - Scripture Action Buttons
/// Bookmark and share buttons for scripture cards throughout the app
struct ScriptureActionButtons: View {
    let verseText: String
    let reference: String
    let source: BookmarkedVerse.VerseSource
    @EnvironmentObject var firestoreService: FirestoreService

    @State private var isBookmarked = false
    @State private var showShareSheet = false
    @State private var showBookmarkConfirmation = false

    var body: some View {
        HStack(spacing: 16) {
            // Bookmark button
            Button {
                toggleBookmark()
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                        .font(.caption)
                    Text(isBookmarked ? "Saved" : "Save")
                        .font(.system(.caption, design: .serif))
                }
                .foregroundColor(isBookmarked ? ABTheme.warmGold : ABTheme.secondaryText)
            }
            .buttonStyle(.plain)

            // Share button
            Button {
                showShareSheet = true
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.caption)
                    Text("Share")
                        .font(.system(.caption, design: .serif))
                }
                .foregroundColor(ABTheme.secondaryText)
            }
            .buttonStyle(.plain)
            .sheet(isPresented: $showShareSheet) {
                VerseShareSheet(verseText: verseText, reference: reference)
            }
        }
        .task {
            isBookmarked = await firestoreService.isVerseBookmarked(reference: reference)
        }
        .overlay(alignment: .top) {
            if showBookmarkConfirmation {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption2)
                    Text(isBookmarked ? "Verse saved!" : "Bookmark removed")
                        .font(.system(.caption2, design: .serif))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(ABTheme.sageGreen)
                .cornerRadius(12)
                .offset(y: -30)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }

    private func toggleBookmark() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        Task {
            if isBookmarked {
                await firestoreService.removeBookmark(reference: reference)
                isBookmarked = false
            } else {
                await firestoreService.saveBookmark(
                    verseText: verseText,
                    reference: reference,
                    source: source
                )
                isBookmarked = true
            }
            withAnimation(.spring(response: 0.3)) {
                showBookmarkConfirmation = true
            }
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            withAnimation {
                showBookmarkConfirmation = false
            }
        }
    }
}

// MARK: - Verse Card Template
/// Available templates for verse share cards
enum VerseCardTemplate: String, CaseIterable {
    case garden = "Garden"        // FREE  — sage green botanical
    case dawn = "Dawn"            // PREMIUM — warm gold sunrise
    case twilight = "Twilight"    // PREMIUM — dark navy evening
    case blossom = "Blossom"      // PREMIUM — blush pink floral
    case minimalist = "Minimalist" // PREMIUM — clean white with thin border

    var isPremium: Bool { self != .garden }

    var icon: String {
        switch self {
        case .garden:     return "leaf.fill"
        case .dawn:       return "sunrise.fill"
        case .twilight:   return "moon.stars.fill"
        case .blossom:    return "camera.macro"
        case .minimalist: return "square"
        }
    }
}

// MARK: - Verse Share Sheet
/// Renders a beautiful verse card with template selection and presents the system share sheet
struct VerseShareSheet: View {
    let verseText: String
    let reference: String
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var subscriptionManager: SubscriptionManager

    @State private var selectedTemplate: VerseCardTemplate = .garden
    @State private var showUpgradePrompt = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: ABTheme.paddingLarge) {
                    Text("Share this verse")
                        .font(ABTheme.subheadlineFont)
                        .foregroundColor(ABTheme.primaryText)

                    // MARK: Template Picker
                    VStack(alignment: .leading, spacing: ABTheme.paddingSmall) {
                        Text("Choose a style")
                            .font(.system(.caption, design: .serif, weight: .medium))
                            .foregroundColor(ABTheme.secondaryText)
                            .padding(.horizontal, ABTheme.paddingSmall)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(VerseCardTemplate.allCases, id: \.self) { template in
                                    TemplatePickerThumbnail(
                                        template: template,
                                        isSelected: selectedTemplate == template,
                                        isPremium: template.isPremium,
                                        userIsPremium: subscriptionManager.isPremium
                                    )
                                    .onTapGesture {
                                        if template.isPremium && !subscriptionManager.isPremium {
                                            showUpgradePrompt = true
                                        } else {
                                            withAnimation(.easeInOut(duration: 0.2)) {
                                                selectedTemplate = template
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, ABTheme.paddingSmall)
                            .padding(.vertical, 4)
                        }

                        // Upgrade prompt for free users
                        if !subscriptionManager.isPremium {
                            HStack(spacing: 6) {
                                Image(systemName: "lock.fill")
                                    .font(.system(size: 10, weight: .semibold, design: .default))
                                Text("Unlock Dawn, Twilight, Blossom & Minimalist with Premium")
                                    .font(.system(.caption2, design: .serif))
                            }
                            .foregroundColor(ABTheme.warmGold)
                            .padding(.horizontal, ABTheme.paddingSmall)
                        }
                    }

                    // Preview of the card
                    VerseCardImage(verseText: verseText, reference: reference, template: selectedTemplate)
                        .frame(maxWidth: 340)

                    // Share button using rendered image
                    if let image = renderVerseCard() {
                        ShareLink(
                            item: image,
                            preview: SharePreview(
                                "\(reference) — Anchor & Bloom",
                                image: image
                            )
                        ) {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                Text("Share Verse Card")
                            }
                        }
                        .buttonStyle(ABPrimaryButtonStyle())
                    }

                    // Text-only share
                    ShareLink(item: "\"\(verseText)\"\n— \(reference)\n\nShared from Anchor & Bloom") {
                        HStack {
                            Image(systemName: "text.bubble")
                            Text("Share as Text")
                        }
                    }
                    .buttonStyle(ABSecondaryButtonStyle())

                    Spacer(minLength: ABTheme.paddingLarge)
                }
                .padding(ABTheme.paddingLarge)
            }
            .abScreenBackground()
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(ABTheme.sageGreen)
                }
            }
            .alert("Upgrade to Premium", isPresented: $showUpgradePrompt) {
                Button("Upgrade", role: .none) { showUpgradePrompt = false }
                Button("Not Now", role: .cancel) { }
            } message: {
                Text("Unlock all verse card templates and more with Anchor & Bloom Premium.")
            }
        }
    }

    @MainActor
    private func renderVerseCard() -> Image? {
        let renderer = ImageRenderer(
            content: VerseCardImage(verseText: verseText, reference: reference, template: selectedTemplate)
                .frame(width: 600, height: 600)
        )
        renderer.scale = 3.0
        guard let uiImage = renderer.uiImage else { return nil }
        return Image(uiImage: uiImage)
    }
}

// MARK: - Template Picker Thumbnail
/// Small tappable thumbnail shown in the template horizontal picker
private struct TemplatePickerThumbnail: View {
    let template: VerseCardTemplate
    let isSelected: Bool
    let isPremium: Bool
    let userIsPremium: Bool

    var isLocked: Bool { isPremium && !userIsPremium }

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                // Mini gradient background matching each template
                RoundedRectangle(cornerRadius: ABTheme.cornerRadiusSmall)
                    .fill(thumbnailBackground)
                    .frame(width: 64, height: 64)

                // Template icon
                Image(systemName: template.icon)
                    .font(.system(size: 22, weight: .regular, design: .default))
                    .foregroundColor(thumbnailIconColor)

                // Lock overlay for premium templates when user is free
                if isLocked {
                    RoundedRectangle(cornerRadius: ABTheme.cornerRadiusSmall)
                        .fill(Color.black.opacity(0.35))
                        .frame(width: 64, height: 64)
                    Image(systemName: "lock.fill")
                        .font(.system(size: 14, weight: .semibold, design: .default))
                        .foregroundColor(.white)
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: ABTheme.cornerRadiusSmall)
                    .stroke(isSelected ? ABTheme.sageGreen : Color.clear, lineWidth: 2)
            )

            Text(template.rawValue)
                .font(.system(.caption2, design: .serif))
                .foregroundColor(isSelected ? ABTheme.sageGreen : ABTheme.secondaryText)
        }
    }

    private var thumbnailBackground: AnyShapeStyle {
        switch template {
        case .garden:
            return AnyShapeStyle(LinearGradient(
                colors: [Color(red: 0.93, green: 0.96, blue: 0.93), Color(red: 0.82, green: 0.91, blue: 0.83)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            ))
        case .dawn:
            return AnyShapeStyle(LinearGradient(
                colors: [Color(red: 1.0, green: 0.95, blue: 0.80), Color(red: 0.97, green: 0.82, blue: 0.55)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            ))
        case .twilight:
            return AnyShapeStyle(LinearGradient(
                colors: [Color(red: 0.12, green: 0.14, blue: 0.28), Color(red: 0.22, green: 0.18, blue: 0.38)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            ))
        case .blossom:
            return AnyShapeStyle(LinearGradient(
                colors: [Color(red: 0.99, green: 0.92, blue: 0.93), Color(red: 0.95, green: 0.80, blue: 0.84)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            ))
        case .minimalist:
            return AnyShapeStyle(LinearGradient(
                colors: [Color(red: 0.99, green: 0.99, blue: 0.99), Color(red: 0.96, green: 0.95, blue: 0.93)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            ))
        }
    }

    private var thumbnailIconColor: Color {
        switch template {
        case .garden:     return ABTheme.sageGreen
        case .dawn:       return ABTheme.warmGold
        case .twilight:   return Color.white.opacity(0.85)
        case .blossom:    return ABTheme.blushDark
        case .minimalist: return ABTheme.secondaryText
        }
    }
}

// MARK: - Verse Card Image (for rendering/sharing)
/// Beautiful branded verse card for social sharing — supports multiple templates
struct VerseCardImage: View {
    let verseText: String
    let reference: String
    var template: VerseCardTemplate = .garden

    var body: some View {
        ZStack {
            cardBackground
            decorativeElements
            cardContent
        }
        .aspectRatio(1, contentMode: .fit)
        .cornerRadius(20)
        .shadow(color: ABTheme.cardShadow, radius: 10, x: 0, y: 4)
    }

    // MARK: Backgrounds

    @ViewBuilder
    private var cardBackground: some View {
        switch template {
        case .garden:
            LinearGradient(
                colors: [
                    Color(red: 0.97, green: 0.95, blue: 0.91),
                    Color(red: 0.93, green: 0.87, blue: 0.73).opacity(0.4),
                    Color(red: 0.97, green: 0.95, blue: 0.91)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .dawn:
            LinearGradient(
                colors: [
                    Color(red: 1.0, green: 0.97, blue: 0.85),
                    Color(red: 1.0, green: 0.90, blue: 0.65),
                    Color(red: 0.98, green: 0.80, blue: 0.50)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        case .twilight:
            LinearGradient(
                colors: [
                    Color(red: 0.08, green: 0.10, blue: 0.22),
                    Color(red: 0.18, green: 0.15, blue: 0.35),
                    Color(red: 0.15, green: 0.18, blue: 0.27)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .blossom:
            LinearGradient(
                colors: [
                    Color(red: 0.99, green: 0.94, blue: 0.95),
                    Color(red: 0.97, green: 0.85, blue: 0.88),
                    Color(red: 0.99, green: 0.94, blue: 0.95)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .minimalist:
            LinearGradient(
                colors: [
                    Color(red: 1.0, green: 1.0, blue: 1.0),
                    Color(red: 0.97, green: 0.96, blue: 0.94)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    // MARK: Decorative Elements

    @ViewBuilder
    private var decorativeElements: some View {
        switch template {
        case .garden:
            VStack {
                HStack {
                    Spacer()
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 50, weight: .regular, design: .default))
                        .foregroundColor(ABTheme.sageGreen.opacity(0.13))
                        .rotationEffect(.degrees(-25))
                }
                Spacer()
                HStack {
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 36, weight: .regular, design: .default))
                        .foregroundColor(ABTheme.blush.opacity(0.13))
                        .rotationEffect(.degrees(155))
                    Spacer()
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 24, weight: .regular, design: .default))
                        .foregroundColor(ABTheme.sageGreenDark.opacity(0.10))
                        .rotationEffect(.degrees(60))
                }
            }
            .padding(20)

        case .dawn:
            VStack {
                HStack {
                    Spacer()
                    // Sun rays top-right
                    ZStack {
                        ForEach(0..<8, id: \.self) { i in
                            Rectangle()
                                .fill(Color.white.opacity(0.12))
                                .frame(width: 2, height: 55)
                                .offset(y: -28)
                                .rotationEffect(.degrees(Double(i) * 22.5))
                        }
                        Circle()
                            .fill(ABTheme.warmGold.opacity(0.25))
                            .frame(width: 36, height: 36)
                    }
                    .frame(width: 80, height: 80)
                    .offset(x: 10, y: -10)
                }
                Spacer()
            }
            .padding(20)

        case .twilight:
            ZStack {
                // Scattered stars
                ForEach(0..<12, id: \.self) { i in
                    Circle()
                        .fill(Color.white.opacity(Double.random(in: 0.25...0.55)))
                        .frame(
                            width: CGFloat.random(in: 2...5),
                            height: CGFloat.random(in: 2...5)
                        )
                        .offset(
                            x: CGFloat(i * 47 % 260) - 130,
                            y: CGFloat(i * 31 % 200) - 130
                        )
                }
                VStack {
                    HStack {
                        Spacer()
                        Image(systemName: "moon.stars.fill")
                            .font(.system(size: 40, weight: .regular, design: .default))
                            .foregroundColor(Color.white.opacity(0.18))
                    }
                    Spacer()
                }
                .padding(24)
            }

        case .blossom:
            VStack {
                HStack {
                    Image(systemName: "camera.macro")
                        .font(.system(size: 44, weight: .regular, design: .default))
                        .foregroundColor(ABTheme.blush.opacity(0.25))
                        .rotationEffect(.degrees(-15))
                    Spacer()
                }
                Spacer()
                HStack {
                    Spacer()
                    Image(systemName: "camera.macro")
                        .font(.system(size: 32, weight: .regular, design: .default))
                        .foregroundColor(ABTheme.blushDark.opacity(0.15))
                        .rotationEffect(.degrees(20))
                }
            }
            .padding(20)

        case .minimalist:
            // Thin gold border inset
            RoundedRectangle(cornerRadius: 17)
                .stroke(ABTheme.warmGold.opacity(0.40), lineWidth: 1.5)
                .padding(10)
        }
    }

    // MARK: Card Content

    private var cardContent: some View {
        VStack(spacing: 20) {
            Spacer()

            // Quote mark
            Image(systemName: "quote.opening")
                .font(.system(size: 24, weight: .regular, design: .default))
                .foregroundColor(quoteMarkColor)

            // Verse text
            Text(verseText)
                .font(.system(.title3, design: .serif).italic())
                .foregroundColor(verseTextColor)
                .multilineTextAlignment(.center)
                .lineSpacing(6)
                .padding(.horizontal, 30)

            // Reference
            Text(reference)
                .font(.system(.subheadline, design: .serif, weight: .semibold))
                .foregroundColor(referenceColor)

            Spacer()

            // Branding watermark
            HStack(spacing: 6) {
                Image(systemName: "anchor")
                    .font(.system(.caption2, design: .default))
                Text("Anchor & Bloom")
                    .font(.system(.caption, design: .serif, weight: .medium))
            }
            .foregroundColor(brandingColor)
            .padding(.bottom, 16)
        }
        .padding(ABTheme.paddingLarge)
    }

    // MARK: Per-template color tokens

    private var quoteMarkColor: Color {
        switch template {
        case .garden:     return ABTheme.warmGold.opacity(0.6)
        case .dawn:       return ABTheme.warmGold.opacity(0.8)
        case .twilight:   return Color.white.opacity(0.55)
        case .blossom:    return ABTheme.blushDark.opacity(0.70)
        case .minimalist: return ABTheme.warmGold.opacity(0.50)
        }
    }

    private var verseTextColor: Color {
        switch template {
        case .twilight: return Color.white.opacity(0.92)
        default:        return ABTheme.darkNavy
        }
    }

    private var referenceColor: Color {
        switch template {
        case .garden:     return ABTheme.sageGreen
        case .dawn:       return Color(red: 0.72, green: 0.50, blue: 0.18)
        case .twilight:   return Color.white.opacity(0.75)
        case .blossom:    return ABTheme.blushDark
        case .minimalist: return ABTheme.secondaryText
        }
    }

    private var brandingColor: Color {
        switch template {
        case .twilight: return Color.white.opacity(0.35)
        default:        return ABTheme.secondaryText.opacity(0.45)
        }
    }
}
