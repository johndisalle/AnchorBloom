import SwiftUI

// MARK: - Community View
/// Unified community tab: Prayer Wall (primary) + Sister Circles
/// Prayer Wall leads because "47 sisters prayed for you" is the highest-retention mechanic.
struct CommunityView: View {
    @State private var selectedSection = 0

    var body: some View {
        VStack(spacing: 0) {
            // Segmented picker — sits above each view's NavigationStack
            Picker("", selection: $selectedSection) {
                Text("Prayer Wall").tag(0)
                Text("Sister Circles").tag(1)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, ABTheme.paddingMedium)
            .padding(.vertical, 10)
            .background(ABTheme.background)

            // Content — each view provides its own NavigationStack
            if selectedSection == 0 {
                PrayerWallView(embedded: true)
            } else {
                CirclesListView(embedded: true)
            }
        }
    }
}
