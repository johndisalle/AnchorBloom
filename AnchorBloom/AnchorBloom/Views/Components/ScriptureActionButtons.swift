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

// MARK: - Verse Share Sheet
/// Renders a beautiful verse card and presents the system share sheet
struct VerseShareSheet: View {
    let verseText: String
    let reference: String
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: ABTheme.paddingLarge) {
                Text("Share this verse")
                    .font(ABTheme.subheadlineFont)
                    .foregroundColor(ABTheme.primaryText)

                // Preview of the card
                VerseCardImage(verseText: verseText, reference: reference)
                    .frame(maxWidth: 340)

                // Share button using rendered image
                if let image = renderVerseCard() {
                    ShareLink(
                        item: image,
                        preview: SharePreview(
                            "\(reference) — AnchorBloom",
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
                ShareLink(item: "\"\(verseText)\"\n— \(reference)\n\nShared from AnchorBloom") {
                    HStack {
                        Image(systemName: "text.bubble")
                        Text("Share as Text")
                    }
                }
                .buttonStyle(ABSecondaryButtonStyle())

                Spacer()
            }
            .padding(ABTheme.paddingLarge)
            .abScreenBackground()
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(ABTheme.sageGreen)
                }
            }
        }
    }

    @MainActor
    private func renderVerseCard() -> Image? {
        let renderer = ImageRenderer(
            content: VerseCardImage(verseText: verseText, reference: reference)
                .frame(width: 600, height: 600)
        )
        renderer.scale = 3.0
        guard let uiImage = renderer.uiImage else { return nil }
        return Image(uiImage: uiImage)
    }
}

// MARK: - Verse Card Image (for rendering/sharing)
/// Beautiful branded verse card for social sharing
struct VerseCardImage: View {
    let verseText: String
    let reference: String

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color(red: 0.97, green: 0.95, blue: 0.91),
                    Color(red: 0.93, green: 0.87, blue: 0.73).opacity(0.4),
                    Color(red: 0.97, green: 0.95, blue: 0.91)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // Subtle decorative elements
            VStack {
                HStack {
                    Spacer()
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 40))
                        .foregroundColor(ABTheme.sageGreen.opacity(0.12))
                        .rotationEffect(.degrees(-30))
                }
                Spacer()
                HStack {
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 30))
                        .foregroundColor(ABTheme.blush.opacity(0.12))
                        .rotationEffect(.degrees(150))
                    Spacer()
                }
            }
            .padding(20)

            // Content
            VStack(spacing: 20) {
                Spacer()

                // Opening quote mark
                Image(systemName: "quote.opening")
                    .font(.system(size: 24))
                    .foregroundColor(ABTheme.warmGold.opacity(0.6))

                // Verse text
                Text(verseText)
                    .font(.system(.title3, design: .serif).italic())
                    .foregroundColor(ABTheme.darkNavy)
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
                    .padding(.horizontal, 30)

                // Reference
                Text(reference)
                    .font(.system(.subheadline, design: .serif, weight: .semibold))
                    .foregroundColor(ABTheme.sageGreen)

                Spacer()

                // Branding
                HStack(spacing: 6) {
                    Image(systemName: "anchor")
                        .font(.caption2)
                    Text("AnchorBloom")
                        .font(.system(.caption, design: .serif, weight: .medium))
                }
                .foregroundColor(ABTheme.secondaryText.opacity(0.5))
                .padding(.bottom, 16)
            }
            .padding(ABTheme.paddingLarge)
        }
        .aspectRatio(1, contentMode: .fit)
        .cornerRadius(20)
        .shadow(color: ABTheme.cardShadow, radius: 10, x: 0, y: 4)
    }
}
