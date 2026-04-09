import SwiftUI
import FirebaseFirestore
import FirebaseAuth

// MARK: - Prayer Request Model

struct PrayerRequest: Codable, Identifiable {
    @DocumentID var id: String?
    var authorID: String
    var content: String
    var category: PrayerCategory
    var createdAt: Date
    var prayerCount: Int
    var prayedByIDs: [String]
    var isActive: Bool
    var answeredAt: Date?
    var answeredNote: String?
}

// MARK: - Prayer Category

enum PrayerCategory: String, Codable, CaseIterable {
    case health = "Health & Healing"
    case family = "Family"
    case marriage = "Marriage"
    case finances = "Finances"
    case guidance = "Guidance"
    case anxiety = "Anxiety & Peace"
    case relationships = "Relationships"
    case career = "Career & Purpose"
    case faith = "Faith & Doubt"
    case praise = "Praise & Thanksgiving"
    case other = "Other"

    var icon: String {
        switch self {
        case .health:        return "heart.circle.fill"
        case .family:        return "house.fill"
        case .marriage:      return "2.circle.fill"
        case .finances:      return "dollarsign.circle.fill"
        case .guidance:      return "map.fill"
        case .anxiety:       return "wind"
        case .relationships: return "person.2.fill"
        case .career:        return "briefcase.fill"
        case .faith:         return "book.closed.fill"
        case .praise:        return "star.fill"
        case .other:         return "ellipsis.circle.fill"
        }
    }
}

// MARK: - Prayer Wall View

struct PrayerWallView: View {
    var embedded = false
    @EnvironmentObject var firestoreService: FirestoreService
    @EnvironmentObject var subscriptionManager: SubscriptionManager

    @State private var prayerRequests: [PrayerRequest] = []
    @State private var isLoading = false
    @State private var selectedCategory: PrayerCategory?
    @State private var showNewPrayerSheet = false
    @State private var showUpgradePrompt = false
    @State private var loadErrorMessage: String?

    private var currentUserID: String {
        Auth.auth().currentUser?.uid ?? ""
    }

    private var filteredRequests: [PrayerRequest] {
        guard let category = selectedCategory else { return prayerRequests }
        return prayerRequests.filter { $0.category == category }
    }

    var body: some View {
        Group {
            if embedded {
                mainContent
            } else {
                NavigationStack {
                    mainContent
                        .navigationTitle("Prayer Wall")
                        .navigationBarTitleDisplayMode(.inline)
                }
            }
        }
        .refreshable { await loadPrayerRequests() }
        .task { await loadPrayerRequests() }
        .sheet(isPresented: $showNewPrayerSheet) {
            NewPrayerRequestView { newRequest in
                prayerRequests.insert(newRequest, at: 0)
            }
            .environmentObject(firestoreService)
            .environmentObject(subscriptionManager)
        }
        .sheet(isPresented: $showUpgradePrompt) {
            SubscriptionView()
                .environmentObject(subscriptionManager)
        }
    }

    private var mainContent: some View {
        ScrollView {
            VStack(spacing: ABTheme.paddingLarge) {
                if !embedded { headerSection }
                categoryFilterRow
                postPrayerButton
                if isLoading {
                    ProgressView()
                        .tint(ABTheme.sageGreen)
                        .padding(.top, 40)
                } else if filteredRequests.isEmpty {
                    emptyStateView
                } else {
                    LazyVStack(spacing: ABTheme.paddingMedium) {
                        ForEach(filteredRequests) { request in
                            PrayerRequestCard(
                                request: request,
                                currentUserID: currentUserID,
                                onPrayTapped: { handlePrayTapped(request: request) },
                                onMarkAnswered: { handleMarkAnswered(request: request) },
                                onAnsweredUpdated: { updated in updateRequest(updated) }
                            )
                        }
                    }
                }
                Spacer().frame(height: 40)
            }
            .padding(.horizontal, ABTheme.paddingMedium)
        }
        .abScreenBackground()
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "hands.sparkles.fill")
                .font(.title)
                .foregroundColor(ABTheme.warmGold)

            Text("Prayer Wall")
                .font(ABTheme.headlineFont)
                .foregroundColor(ABTheme.primaryText)

            Text("Lift each other up in prayer. You are never alone.")
                .font(ABTheme.captionFont)
                .foregroundColor(ABTheme.secondaryText)
                .multilineTextAlignment(.center)
        }
        .padding(.top, ABTheme.paddingMedium)
    }

    // MARK: - Category Filter Row

    private var categoryFilterRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                CategoryChip(
                    title: "All",
                    icon: "square.grid.2x2.fill",
                    isSelected: selectedCategory == nil
                ) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedCategory = nil
                    }
                }

                ForEach(PrayerCategory.allCases, id: \.self) { category in
                    CategoryChip(
                        title: category.rawValue,
                        icon: category.icon,
                        isSelected: selectedCategory == category
                    ) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            if selectedCategory == category {
                                selectedCategory = nil
                            } else {
                                selectedCategory = category
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, ABTheme.paddingMedium)
            .padding(.vertical, 4)
        }
        .padding(.horizontal, -ABTheme.paddingMedium)
    }

    // MARK: - Post Prayer Button

    private var postPrayerButton: some View {
        Button {
            if subscriptionManager.isPremium {
                showNewPrayerSheet = true
            } else {
                showUpgradePrompt = true
            }
        } label: {
            HStack(spacing: 10) {
                Image(systemName: subscriptionManager.isPremium ? "plus.circle.fill" : "crown.fill")
                    .foregroundColor(subscriptionManager.isPremium ? .white : ABTheme.warmGold)
                Text(subscriptionManager.isPremium ? "Post a Prayer Request" : "Unlock to Post Prayers")
                    .font(.system(.body, design: .serif, weight: .semibold))
            }
        }
        .foregroundColor(.white)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(subscriptionManager.isPremium ? ABTheme.sageGreen : ABTheme.warmGold.opacity(0.85))
        .cornerRadius(ABTheme.cornerRadius)
        .shadow(color: ABTheme.cardShadow, radius: ABTheme.cardShadowRadius, x: 0, y: 2)
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            if let errorMsg = loadErrorMessage {
                Image(systemName: "wifi.exclamationmark")
                    .font(.system(size: 44))
                    .foregroundColor(ABTheme.destructive.opacity(0.5))

                Text(errorMsg)
                    .font(ABTheme.captionFont)
                    .foregroundColor(ABTheme.secondaryText)
                    .multilineTextAlignment(.center)
            } else {
                Image(systemName: "hands.sparkles")
                    .font(.system(size: 44))
                    .foregroundColor(ABTheme.secondaryText.opacity(0.3))

                Text("No prayers here yet")
                    .font(ABTheme.subheadlineFont)
                    .foregroundColor(ABTheme.secondaryText)

                Text("Be the first to lift up a prayer request.")
                    .font(ABTheme.captionFont)
                    .foregroundColor(ABTheme.secondaryText.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.top, 40)
    }

    // MARK: - Firestore Operations

    private func loadPrayerRequests() async {
        isLoading = true
        loadErrorMessage = nil
        defer { isLoading = false }

        do {
            let snapshot = try await Firestore.firestore()
                .collection("prayerRequests")
                .order(by: "createdAt", descending: true)
                .limit(to: 100)
                .getDocuments()

            prayerRequests = snapshot.documents.compactMap {
                try? $0.data(as: PrayerRequest.self)
            }
        } catch {
            loadErrorMessage = "Unable to load prayers. Pull down to try again."
        }
    }

    private func handlePrayTapped(request: PrayerRequest) {
        guard let requestID = request.id else { return }
        let userID = currentUserID
        guard !userID.isEmpty else { return }

        let alreadyPrayed = request.prayedByIDs.contains(userID)

        // Optimistic local update
        if let index = prayerRequests.firstIndex(where: { $0.id == requestID }) {
            if alreadyPrayed {
                prayerRequests[index].prayedByIDs.removeAll { $0 == userID }
                prayerRequests[index].prayerCount = max(0, prayerRequests[index].prayerCount - 1)
            } else {
                prayerRequests[index].prayedByIDs.append(userID)
                prayerRequests[index].prayerCount += 1
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }
        }

        // Persist to Firestore
        let docRef = Firestore.firestore().collection("prayerRequests").document(requestID)
        if alreadyPrayed {
            docRef.updateData([
                "prayedByIDs": FieldValue.arrayRemove([userID]),
                "prayerCount": FieldValue.increment(Int64(-1))
            ])
        } else {
            docRef.updateData([
                "prayedByIDs": FieldValue.arrayUnion([userID]),
                "prayerCount": FieldValue.increment(Int64(1))
            ])
        }
    }

    private func handleMarkAnswered(request: PrayerRequest) {
        // Handled inside the card via AnsweredPrayerView sheet
        // This callback triggers a list refresh after the sheet closes
        Task { await loadPrayerRequests() }
    }

    private func updateRequest(_ updated: PrayerRequest) {
        if let index = prayerRequests.firstIndex(where: { $0.id == updated.id }) {
            prayerRequests[index] = updated
        }
    }
}

// MARK: - Category Chip

private struct CategoryChip: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: 11, weight: .medium, design: .default))
                Text(title)
                    .font(.system(.caption, design: .serif, weight: .medium))
                    .lineLimit(1)
            }
            .foregroundColor(isSelected ? .white : ABTheme.primaryText)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(isSelected ? ABTheme.sageGreen : ABTheme.cardBackground)
            .cornerRadius(20)
            .shadow(color: ABTheme.cardShadow, radius: 3, x: 0, y: 1)
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }
}

// MARK: - Prayer Request Card

struct PrayerRequestCard: View {
    let request: PrayerRequest
    let currentUserID: String
    let onPrayTapped: () -> Void
    let onMarkAnswered: () -> Void
    let onAnsweredUpdated: (PrayerRequest) -> Void

    @State private var isExpanded = false
    @State private var showAnsweredSheet = false

    private var alreadyPrayed: Bool {
        request.prayedByIDs.contains(currentUserID)
    }

    private var isOwnRequest: Bool {
        request.authorID == currentUserID
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {

            // MARK: Card Top Row
            HStack(alignment: .top) {
                // Category badge
                HStack(spacing: 5) {
                    Image(systemName: request.category.icon)
                        .font(.system(size: 11, weight: .semibold, design: .default))
                    Text(request.category.rawValue)
                        .font(.system(.caption2, design: .serif, weight: .semibold))
                }
                .foregroundColor(ABTheme.sageGreen)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(ABTheme.sageGreen.opacity(0.1))
                .cornerRadius(20)

                Spacer()

                HStack(spacing: 8) {
                    // Answered badge
                    if !request.isActive {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 11, weight: .medium, design: .default))
                            Text("Answered")
                                .font(.system(.caption2, design: .serif, weight: .semibold))
                        }
                        .foregroundColor(ABTheme.warmGold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(ABTheme.warmGold.opacity(0.12))
                        .cornerRadius(12)
                    }

                    // Time ago
                    Text(request.createdAt.timeAgoShort)
                        .font(.caption2)
                        .foregroundColor(ABTheme.secondaryText)

                    // Owner menu
                    if isOwnRequest && request.isActive {
                        Menu {
                            Button {
                                showAnsweredSheet = true
                            } label: {
                                Label("Mark Answered", systemImage: "checkmark.seal.fill")
                            }
                        } label: {
                            Image(systemName: "ellipsis")
                                .font(.caption)
                                .foregroundColor(ABTheme.secondaryText)
                                .padding(6)
                                .background(ABTheme.cardBackground)
                                .cornerRadius(8)
                        }
                    }
                }
            }

            // MARK: Prayer Content
            VStack(alignment: .leading, spacing: 6) {
                Text(request.content)
                    .font(.system(.body, design: .serif))
                    .foregroundColor(ABTheme.primaryText)
                    .lineLimit(isExpanded ? nil : 3)
                    .lineSpacing(3)
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isExpanded.toggle()
                        }
                    }

                if !isExpanded && request.content.lineCount > 3 {
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isExpanded = true
                        }
                    } label: {
                        Text("Read more")
                            .font(.system(.caption, design: .serif, weight: .medium))
                            .foregroundColor(ABTheme.sageGreen)
                    }
                    .buttonStyle(.plain)
                }

                // Answered testimony note
                if !request.isActive, let note = request.answeredNote, !note.isEmpty {
                    HStack(alignment: .top, spacing: 6) {
                        Image(systemName: "quote.bubble.fill")
                            .font(.system(size: 12, weight: .regular, design: .default))
                            .foregroundColor(ABTheme.warmGold)
                        Text(note)
                            .font(.system(.caption, design: .serif).italic())
                            .foregroundColor(ABTheme.secondaryText)
                            .lineSpacing(2)
                    }
                    .padding(10)
                    .background(ABTheme.warmGold.opacity(0.07))
                    .cornerRadius(ABTheme.cornerRadiusSmall)
                }
            }

            Divider()
                .background(ABTheme.cardShadow)

            // MARK: Card Bottom Bar
            HStack {
                // Prayer count
                HStack(spacing: 5) {
                    Image(systemName: "hands.sparkles.fill")
                        .font(.system(size: 12, weight: .regular, design: .default))
                        .foregroundColor(ABTheme.blush)
                    Text(prayerCountLabel)
                        .font(.system(.caption, design: .serif))
                        .foregroundColor(ABTheme.secondaryText)
                }

                Spacer()

                // I Prayed button
                Button {
                    onPrayTapped()
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: alreadyPrayed ? "hands.sparkles.fill" : "hands.sparkles")
                            .font(.system(size: 14, weight: .medium, design: .default))
                        Text(alreadyPrayed ? "Prayed" : "I Prayed")
                            .font(.system(.caption, design: .serif, weight: .semibold))
                    }
                    .foregroundColor(alreadyPrayed ? .white : ABTheme.sageGreen)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 7)
                    .background(alreadyPrayed ? ABTheme.sageGreen : ABTheme.sageGreen.opacity(0.1))
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(ABTheme.sageGreen.opacity(alreadyPrayed ? 0 : 0.3), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
                .animation(.easeInOut(duration: 0.15), value: alreadyPrayed)
            }
        }
        .abCard()
        .sheet(isPresented: $showAnsweredSheet) {
            AnsweredPrayerView(request: request) { updatedRequest in
                onAnsweredUpdated(updatedRequest)
            }
        }
    }

    private var prayerCountLabel: String {
        let count = request.prayerCount
        if count == 0 { return "Be the first to pray" }
        if count == 1 { return "1 sister prayed" }
        return "\(count) sisters prayed"
    }
}

// MARK: - New Prayer Request View

struct NewPrayerRequestView: View {
    @Environment(\.dismiss) private var dismiss

    var onSubmitted: (PrayerRequest) -> Void

    @State private var selectedCategory: PrayerCategory = .other
    @State private var prayerText = ""
    @State private var isSubmitting = false
    @State private var contentViolation: String?

    private var currentUserID: String {
        Auth.auth().currentUser?.uid ?? ""
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: ABTheme.paddingLarge) {

                    // MARK: Anonymity Notice
                    HStack(spacing: 10) {
                        Image(systemName: "eye.slash.fill")
                            .foregroundColor(ABTheme.blush)
                        Text("All prayers are anonymous. Only God and your sisters need to know.")
                            .font(.system(.caption, design: .serif))
                            .foregroundColor(ABTheme.secondaryText)
                            .lineSpacing(2)
                    }
                    .padding(ABTheme.paddingMedium)
                    .background(ABTheme.blush.opacity(0.08))
                    .cornerRadius(ABTheme.cornerRadius)

                    // MARK: Category Picker
                    VStack(alignment: .leading, spacing: ABTheme.paddingSmall) {
                        Text("Category")
                            .font(ABTheme.subheadlineFont)
                            .foregroundColor(ABTheme.primaryText)

                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 10) {
                            ForEach(PrayerCategory.allCases, id: \.self) { category in
                                CategoryGridItem(
                                    category: category,
                                    isSelected: selectedCategory == category
                                ) {
                                    UISelectionFeedbackGenerator().selectionChanged()
                                    selectedCategory = category
                                }
                            }
                        }
                    }

                    // MARK: Prayer Text Editor
                    VStack(alignment: .leading, spacing: ABTheme.paddingSmall) {
                        Text("Your Prayer Request")
                            .font(ABTheme.subheadlineFont)
                            .foregroundColor(ABTheme.primaryText)

                        ZStack(alignment: .topLeading) {
                            if prayerText.isEmpty {
                                Text("Share what's on your heart… You don't need to have the right words — God hears every prayer. (Feel free to write as much as you need.)")
                                    .font(.system(.body, design: .serif))
                                    .foregroundColor(ABTheme.secondaryText.opacity(0.6))
                                    .padding(.top, 8)
                                    .padding(.leading, 4)
                                    .allowsHitTesting(false)
                            }

                            TextEditor(text: $prayerText)
                                .font(.system(.body, design: .serif))
                                .foregroundColor(ABTheme.primaryText)
                                .scrollContentBackground(.hidden)
                                .frame(minHeight: 140)
                                .onChange(of: prayerText) { _, _ in
                                    contentViolation = nil
                                }
                        }
                        .padding(ABTheme.paddingSmall)
                        .background(ABTheme.cardBackground)
                        .cornerRadius(ABTheme.cornerRadiusSmall)
                        .overlay(
                            RoundedRectangle(cornerRadius: ABTheme.cornerRadiusSmall)
                                .stroke(
                                    contentViolation != nil ? ABTheme.destructive.opacity(0.6) : ABTheme.sageGreen.opacity(0.2),
                                    lineWidth: 1
                                )
                        )

                        // Content violation warning
                        if let violation = contentViolation {
                            HStack(spacing: 6) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(ABTheme.destructive)
                                    .font(.caption)
                                Text("Your request contains a word that isn't allowed: \"\(violation)\". Please revise.")
                                    .font(.caption)
                                    .foregroundColor(ABTheme.destructive)
                            }
                        }
                    }

                    // MARK: Submit Button
                    Button {
                        submitPrayerRequest()
                    } label: {
                        if isSubmitting {
                            ProgressView()
                                .tint(.white)
                        } else {
                            HStack(spacing: 8) {
                                Image(systemName: "paperplane.fill")
                                Text("Submit Prayer")
                            }
                        }
                    }
                    .buttonStyle(ABPrimaryButtonStyle())
                    .disabled(prayerText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSubmitting)

                    Spacer().frame(height: 24)
                }
                .padding(.horizontal, ABTheme.paddingMedium)
                .padding(.top, ABTheme.paddingMedium)
            }
            .abScreenBackground()
            .navigationTitle("Post a Prayer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .font(.system(.body, design: .serif))
                        .foregroundColor(ABTheme.secondaryText)
                }
            }
        }
    }

    // MARK: - Submit Logic

    private func submitPrayerRequest() {
        let trimmed = prayerText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        // Content filter check
        if !ContentFilter.isClean(trimmed) {
            if let violation = ContentFilter.findViolation(in: trimmed) {
                contentViolation = violation
            }
            return
        }

        isSubmitting = true
        let userID = currentUserID

        let data: [String: Any] = [
            "authorID": userID,
            "content": trimmed,
            "category": selectedCategory.rawValue,
            "createdAt": Timestamp(date: Date()),
            "prayerCount": 0,
            "prayedByIDs": [String](),
            "isActive": true
        ]

        Task {
            do {
                let ref = try await Firestore.firestore()
                    .collection("prayerRequests")
                    .addDocument(data: data)

                let newRequest = PrayerRequest(
                    id: ref.documentID,
                    authorID: userID,
                    content: trimmed,
                    category: selectedCategory,
                    createdAt: Date(),
                    prayerCount: 0,
                    prayedByIDs: [],
                    isActive: true,
                    answeredAt: nil,
                    answeredNote: nil
                )

                UINotificationFeedbackGenerator().notificationOccurred(.success)
                onSubmitted(newRequest)
                dismiss()
            } catch {
                isSubmitting = false
            }
        }
    }
}

// MARK: - Category Grid Item

private struct CategoryGridItem: View {
    let category: PrayerCategory
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: category.icon)
                    .font(.system(size: 20, weight: .regular, design: .default))
                    .foregroundColor(isSelected ? .white : ABTheme.sageGreen)

                Text(category.rawValue)
                    .font(.system(.caption2, design: .serif, weight: .medium))
                    .foregroundColor(isSelected ? .white : ABTheme.primaryText)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .padding(.horizontal, 6)
            .background(isSelected ? ABTheme.sageGreen : ABTheme.cardBackground)
            .cornerRadius(ABTheme.cornerRadiusSmall)
            .shadow(color: ABTheme.cardShadow, radius: isSelected ? 5 : 2, x: 0, y: 1)
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }
}

// MARK: - Answered Prayer View

struct AnsweredPrayerView: View {
    let request: PrayerRequest
    var onMarked: (PrayerRequest) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var testimonyText = ""
    @State private var isSubmitting = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: ABTheme.paddingLarge) {

                    // MARK: Celebration Header
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(ABTheme.warmGold.opacity(0.15))
                                .frame(width: 80, height: 80)

                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 38, weight: .regular, design: .default))
                                .foregroundColor(ABTheme.warmGold)
                        }

                        Text("God answered!")
                            .font(ABTheme.headlineFont)
                            .foregroundColor(ABTheme.primaryText)

                        Text("What a blessing! Mark this prayer as answered and let your sisters rejoice with you.")
                            .font(ABTheme.captionFont)
                            .foregroundColor(ABTheme.secondaryText)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, ABTheme.paddingLarge)

                    // MARK: Original Prayer (preview)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Your Prayer")
                            .font(.system(.caption, design: .serif, weight: .semibold))
                            .foregroundColor(ABTheme.secondaryText)

                        Text(request.content)
                            .font(.system(.body, design: .serif).italic())
                            .foregroundColor(ABTheme.primaryText)
                            .lineSpacing(3)
                            .lineLimit(4)
                    }
                    .padding(ABTheme.paddingMedium)
                    .background(ABTheme.warmGold.opacity(0.06))
                    .cornerRadius(ABTheme.cornerRadius)
                    .overlay(
                        RoundedRectangle(cornerRadius: ABTheme.cornerRadius)
                            .stroke(ABTheme.warmGold.opacity(0.2), lineWidth: 1)
                    )

                    // MARK: Testimony Text Field
                    VStack(alignment: .leading, spacing: ABTheme.paddingSmall) {
                        Text("Share how God moved (optional)")
                            .font(ABTheme.subheadlineFont)
                            .foregroundColor(ABTheme.primaryText)

                        ZStack(alignment: .topLeading) {
                            if testimonyText.isEmpty {
                                Text("Tell your sisters what happened — your testimony encourages others to keep believing…")
                                    .font(.system(.body, design: .serif))
                                    .foregroundColor(ABTheme.secondaryText.opacity(0.6))
                                    .padding(.top, 8)
                                    .padding(.leading, 4)
                                    .allowsHitTesting(false)
                            }

                            TextEditor(text: $testimonyText)
                                .font(.system(.body, design: .serif))
                                .foregroundColor(ABTheme.primaryText)
                                .scrollContentBackground(.hidden)
                                .frame(minHeight: 120)
                        }
                        .padding(ABTheme.paddingSmall)
                        .background(ABTheme.cardBackground)
                        .cornerRadius(ABTheme.cornerRadiusSmall)
                        .overlay(
                            RoundedRectangle(cornerRadius: ABTheme.cornerRadiusSmall)
                                .stroke(ABTheme.warmGold.opacity(0.25), lineWidth: 1)
                        )
                    }

                    // MARK: Confirm Button
                    Button {
                        markAsAnswered()
                    } label: {
                        if isSubmitting {
                            ProgressView()
                                .tint(.white)
                        } else {
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark.seal.fill")
                                Text("Mark as Answered")
                            }
                        }
                    }
                    .buttonStyle(ABPrimaryButtonStyle())
                    .disabled(isSubmitting)

                    Spacer().frame(height: 24)
                }
                .padding(.horizontal, ABTheme.paddingMedium)
            }
            .abScreenBackground()
            .navigationTitle("Prayer Answered")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .font(.system(.body, design: .serif))
                        .foregroundColor(ABTheme.secondaryText)
                }
            }
        }
    }

    // MARK: - Mark Answered Logic

    private func markAsAnswered() {
        guard let requestID = request.id else { return }
        isSubmitting = true

        let note = testimonyText.trimmingCharacters(in: .whitespacesAndNewlines)
        var updateData: [String: Any] = [
            "isActive": false,
            "answeredAt": Timestamp(date: Date())
        ]
        if !note.isEmpty {
            updateData["answeredNote"] = note
        }

        Task {
            do {
                try await Firestore.firestore()
                    .collection("prayerRequests")
                    .document(requestID)
                    .updateData(updateData)

                var updated = request
                updated.isActive = false
                updated.answeredAt = Date()
                updated.answeredNote = note.isEmpty ? nil : note

                UINotificationFeedbackGenerator().notificationOccurred(.success)
                onMarked(updated)
                dismiss()
            } catch {
                isSubmitting = false
            }
        }
    }
}

// MARK: - Helpers

private extension Date {
    /// Short relative time string (e.g. "2h ago", "3d ago")
    var timeAgoShort: String {
        let seconds = Int(Date().timeIntervalSince(self))
        if seconds < 60 { return "just now" }
        let minutes = seconds / 60
        if minutes < 60 { return "\(minutes)m ago" }
        let hours = minutes / 60
        if hours < 24 { return "\(hours)h ago" }
        let days = hours / 24
        if days < 7 { return "\(days)d ago" }
        let weeks = days / 7
        return "\(weeks)w ago"
    }
}

private extension String {
    /// Rough estimate of line count for 3-line expand logic
    var lineCount: Int {
        let approxCharsPerLine = 45
        return max(1, count / approxCharsPerLine)
    }
}

// MARK: - Preview

#Preview {
    PrayerWallView()
        .environmentObject(FirestoreService())
        .environmentObject(SubscriptionManager())
}
