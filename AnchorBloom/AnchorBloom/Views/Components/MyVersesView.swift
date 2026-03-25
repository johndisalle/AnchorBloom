import SwiftUI

// MARK: - My Verses View
/// Collection of user's bookmarked scripture verses
struct MyVersesView: View {
    @EnvironmentObject var firestoreService: FirestoreService
    @State private var bookmarks: [BookmarkedVerse] = []
    @State private var isLoading = false
    @State private var selectedVerse: BookmarkedVerse?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: ABTheme.paddingLarge) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "bookmark.fill")
                            .font(.title)
                            .foregroundColor(ABTheme.warmGold)

                        Text("My Verses")
                            .font(ABTheme.headlineFont)
                            .foregroundColor(ABTheme.primaryText)

                        Text("Verses that spoke to your heart")
                            .font(ABTheme.captionFont)
                            .foregroundColor(ABTheme.secondaryText)
                    }
                    .padding(.top, ABTheme.paddingSmall)

                    if isLoading {
                        ProgressView()
                            .tint(ABTheme.sageGreen)
                            .padding(.top, 40)
                    } else if bookmarks.isEmpty {
                        emptyState
                    } else {
                        ForEach(bookmarks) { verse in
                            BookmarkedVerseCard(verse: verse) {
                                selectedVerse = verse
                            } onDelete: {
                                removeBookmark(verse)
                            }
                        }
                    }

                    Spacer().frame(height: 40)
                }
                .padding(.horizontal, ABTheme.paddingMedium)
            }
            .abScreenBackground()
            .navigationTitle("My Verses")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                await loadBookmarks()
            }
            .sheet(item: $selectedVerse) { verse in
                VerseShareSheet(verseText: verse.verseText, reference: verse.reference)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: ABTheme.paddingMedium) {
            Image(systemName: "bookmark")
                .font(.system(size: 48))
                .foregroundColor(ABTheme.warmGold.opacity(0.4))

            Text("No saved verses yet")
                .font(ABTheme.subheadlineFont)
                .foregroundColor(ABTheme.primaryText)

            Text("Tap the bookmark icon on any scripture card\nto save verses that speak to your heart.")
                .font(ABTheme.captionFont)
                .foregroundColor(ABTheme.secondaryText)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 40)
    }

    private func loadBookmarks() async {
        isLoading = true
        defer { isLoading = false }
        bookmarks = (try? await firestoreService.fetchBookmarks()) ?? []
    }

    private func removeBookmark(_ verse: BookmarkedVerse) {
        Task {
            await firestoreService.removeBookmark(reference: verse.reference)
            bookmarks.removeAll { $0.id == verse.id }
        }
    }
}

// MARK: - Bookmarked Verse Card
struct BookmarkedVerseCard: View {
    let verse: BookmarkedVerse
    let onShare: () -> Void
    let onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Source badge
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: sourceIcon)
                        .font(.caption2)
                    Text(verse.source.rawValue)
                        .font(.system(.caption2, design: .serif, weight: .medium))
                }
                .foregroundColor(ABTheme.sageGreen)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(ABTheme.sageGreen.opacity(0.1))
                .cornerRadius(8)

                Spacer()

                Text(verse.savedAt, style: .date)
                    .font(.caption2)
                    .foregroundColor(ABTheme.secondaryText)
            }

            // Verse text
            Text(verse.verseText)
                .font(ABTheme.scriptureFont)
                .foregroundColor(ABTheme.primaryText)
                .lineSpacing(4)

            // Reference
            Text(verse.reference)
                .font(.system(.caption, design: .serif, weight: .semibold))
                .foregroundColor(ABTheme.sageGreen)

            // Action buttons
            HStack(spacing: 16) {
                Button {
                    onShare()
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

                Spacer()

                Button {
                    onDelete()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "bookmark.slash")
                            .font(.caption)
                        Text("Remove")
                            .font(.system(.caption, design: .serif))
                    }
                    .foregroundColor(ABTheme.secondaryText.opacity(0.6))
                }
                .buttonStyle(.plain)
            }
        }
        .abCard()
    }

    private var sourceIcon: String {
        switch verse.source {
        case .morningAnchor: return "sun.and.horizon.fill"
        case .eveningBloom: return "moon.stars.fill"
        case .journey: return "map.fill"
        case .driftLog: return "water.waves"
        }
    }
}
