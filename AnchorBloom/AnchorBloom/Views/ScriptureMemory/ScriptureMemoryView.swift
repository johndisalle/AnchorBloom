import SwiftUI
import FirebaseFirestore
import FirebaseAuth

// MARK: - Scripture Memory Dashboard
struct ScriptureMemoryView: View {
    @EnvironmentObject var firestoreService: FirestoreService
    @Environment(\.dismiss) private var dismiss

    @State private var cards: [ScriptureMemoryCard] = []
    @State private var isLoading = false
    @State private var showAddVerse = false
    @State private var selectedCard: ScriptureMemoryCard?

    private var activeCards: [ScriptureMemoryCard] {
        cards.filter { !$0.isCompleted }.sorted { $0.nextPracticeDate < $1.nextPracticeDate }
    }

    private var completedCards: [ScriptureMemoryCard] {
        cards.filter { $0.isCompleted }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: ABTheme.paddingLarge) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "brain.head.profile")
                            .font(.system(size: 36))
                            .foregroundColor(ABTheme.sageGreen)

                        Text("Scripture Memory")
                            .font(ABTheme.headlineFont)
                            .foregroundColor(ABTheme.primaryText)

                        Text("Hide God's Word in your heart")
                            .font(ABTheme.captionFont)
                            .foregroundColor(ABTheme.secondaryText)

                        // Stats
                        HStack(spacing: 20) {
                            VStack(spacing: 2) {
                                Text("\(activeCards.count)")
                                    .font(.system(.title3, design: .serif, weight: .bold))
                                    .foregroundColor(ABTheme.sageGreen)
                                Text("Active")
                                    .font(.caption2)
                                    .foregroundColor(ABTheme.secondaryText)
                            }
                            VStack(spacing: 2) {
                                Text("\(completedCards.count)")
                                    .font(.system(.title3, design: .serif, weight: .bold))
                                    .foregroundColor(ABTheme.warmGold)
                                Text("Memorized")
                                    .font(.caption2)
                                    .foregroundColor(ABTheme.secondaryText)
                            }
                        }
                    }
                    .padding(.top, ABTheme.paddingSmall)

                    // Add verse button
                    Button { showAddVerse = true } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Add a Verse to Memorize")
                        }
                    }
                    .buttonStyle(ABPrimaryButtonStyle())

                    if isLoading {
                        ProgressView().tint(ABTheme.sageGreen).padding(.top, 40)
                    } else if cards.isEmpty {
                        emptyState
                    } else {
                        // Ready to practice
                        let readyCards = activeCards.filter { $0.isReadyToPractice }
                        if !readyCards.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Image(systemName: "clock.badge.checkmark.fill")
                                        .foregroundColor(ABTheme.sageGreen)
                                    Text("Ready to Practice")
                                        .font(ABTheme.subheadlineFont)
                                        .foregroundColor(ABTheme.primaryText)
                                }

                                ForEach(readyCards) { card in
                                    MemoryCardRow(card: card, isReady: true) {
                                        selectedCard = card
                                    }
                                }
                            }
                        }

                        // Coming up
                        let upcomingCards = activeCards.filter { !$0.isReadyToPractice }
                        if !upcomingCards.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Coming Up")
                                    .font(ABTheme.subheadlineFont)
                                    .foregroundColor(ABTheme.primaryText)

                                ForEach(upcomingCards) { card in
                                    MemoryCardRow(card: card, isReady: false) {
                                        selectedCard = card
                                    }
                                }
                            }
                        }

                        // Memorized
                        if !completedCards.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Image(systemName: "checkmark.seal.fill")
                                        .foregroundColor(ABTheme.warmGold)
                                    Text("Memorized (\(completedCards.count))")
                                        .font(ABTheme.subheadlineFont)
                                        .foregroundColor(ABTheme.primaryText)
                                }

                                ForEach(completedCards) { card in
                                    MemoryCardRow(card: card, isReady: false) { }
                                }
                            }
                        }
                    }

                    Spacer().frame(height: 40)
                }
                .padding(.horizontal, ABTheme.paddingMedium)
            }
            .abScreenBackground()
            .navigationTitle("Scripture Memory")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(ABTheme.sageGreen)
                }
            }
            .task { await loadCards() }
            .refreshable { await loadCards() }
            .sheet(isPresented: $showAddVerse) {
                AddMemoryVerseView { newCard in
                    cards.append(newCard)
                }
            }
            .sheet(item: $selectedCard) { card in
                MemoryPracticeView(card: card) { updatedCard in
                    if let index = cards.firstIndex(where: { $0.id == updatedCard.id }) {
                        cards[index] = updatedCard
                    }
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "book.closed.fill")
                .font(.system(size: 44))
                .foregroundColor(ABTheme.secondaryText.opacity(0.3))

            Text("No verses yet")
                .font(ABTheme.subheadlineFont)
                .foregroundColor(ABTheme.secondaryText)

            Text("Add a verse and memorize it in 7 days through gentle, spaced repetition.")
                .font(ABTheme.captionFont)
                .foregroundColor(ABTheme.secondaryText)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 40)
    }

    private func loadCards() async {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            let snapshot = try await Firestore.firestore().collection("scriptureMemory")
                .whereField("userID", isEqualTo: userID)
                .order(by: "startedAt", descending: true)
                .getDocuments()
            cards = snapshot.documents.compactMap { try? $0.data(as: ScriptureMemoryCard.self) }
        } catch { }
    }
}

// MARK: - Memory Card Row
struct MemoryCardRow: View {
    let card: ScriptureMemoryCard
    let isReady: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                // Stage icon
                ZStack {
                    Circle()
                        .fill(card.isCompleted ? ABTheme.warmGold.opacity(0.15) : (isReady ? ABTheme.sageGreen.opacity(0.15) : ABTheme.secondaryText.opacity(0.1)))
                        .frame(width: 40, height: 40)

                    Image(systemName: card.currentStage.icon)
                        .font(.system(size: 16))
                        .foregroundColor(card.isCompleted ? ABTheme.warmGold : (isReady ? ABTheme.sageGreen : ABTheme.secondaryText))
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(card.reference)
                        .font(.system(.body, design: .serif, weight: .semibold))
                        .foregroundColor(ABTheme.primaryText)

                    Text(card.verseText)
                        .font(.caption)
                        .foregroundColor(ABTheme.secondaryText)
                        .lineLimit(1)

                    HStack(spacing: 6) {
                        Text(card.currentStage.dayLabel)
                            .font(.system(.caption2, design: .serif, weight: .medium))
                            .foregroundColor(card.isCompleted ? ABTheme.warmGold : ABTheme.sageGreen)

                        if !card.isCompleted && !isReady {
                            Text("· In \(card.daysUntilNextPractice) day\(card.daysUntilNextPractice == 1 ? "" : "s")")
                                .font(.caption2)
                                .foregroundColor(ABTheme.secondaryText)
                        } else if isReady {
                            Text("· Ready now!")
                                .font(.system(.caption2, design: .serif, weight: .medium))
                                .foregroundColor(ABTheme.sageGreen)
                        }
                    }
                }

                Spacer()

                if isReady && !card.isCompleted {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(ABTheme.sageGreen)
                }
            }
            .abCard()
        }
        .buttonStyle(.plain)
        .disabled(card.isCompleted)
    }
}

// MARK: - Add Memory Verse View
struct AddMemoryVerseView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var verseText = ""
    @State private var reference = ""
    @State private var isSaving = false
    let onAdded: (ScriptureMemoryCard) -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: ABTheme.paddingLarge) {
                    Image(systemName: "book.fill")
                        .font(.system(size: 36))
                        .foregroundColor(ABTheme.sageGreen)

                    Text("Add a Verse to Memorize")
                        .font(ABTheme.headlineFont)
                        .foregroundColor(ABTheme.primaryText)

                    Text("You'll memorize this verse over 7 days through gentle, spaced repetition.")
                        .font(ABTheme.captionFont)
                        .foregroundColor(ABTheme.secondaryText)
                        .multilineTextAlignment(.center)

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Scripture Reference")
                            .font(.system(.caption, design: .serif, weight: .medium))
                            .foregroundColor(ABTheme.secondaryText)

                        TextField("e.g., Psalm 46:10", text: $reference)
                            .font(ABTheme.bodyFont)
                            .padding()
                            .background(ABTheme.softWhite)
                            .cornerRadius(ABTheme.cornerRadiusSmall)
                            .overlay(RoundedRectangle(cornerRadius: ABTheme.cornerRadiusSmall).stroke(ABTheme.sageGreen.opacity(0.2), lineWidth: 1))
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Verse Text")
                            .font(.system(.caption, design: .serif, weight: .medium))
                            .foregroundColor(ABTheme.secondaryText)

                        TextEditor(text: $verseText)
                            .font(.system(.body, design: .serif))
                            .frame(minHeight: 120)
                            .padding(8)
                            .background(ABTheme.softWhite)
                            .cornerRadius(ABTheme.cornerRadiusSmall)
                            .overlay(RoundedRectangle(cornerRadius: ABTheme.cornerRadiusSmall).stroke(ABTheme.sageGreen.opacity(0.2), lineWidth: 1))
                    }

                    Button {
                        saveVerse()
                    } label: {
                        HStack {
                            Image(systemName: "brain.head.profile")
                            Text("Start Memorizing")
                        }
                    }
                    .buttonStyle(ABPrimaryButtonStyle())
                    .disabled(verseText.isEmpty || reference.isEmpty || isSaving)
                }
                .padding(ABTheme.paddingLarge)
            }
            .abScreenBackground()
            .navigationTitle("New Verse")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(ABTheme.sageGreen)
                }
            }
        }
    }

    private func saveVerse() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        isSaving = true
        let card = ScriptureMemoryCard(
            userID: userID,
            verseText: verseText.trimmingCharacters(in: .whitespacesAndNewlines),
            reference: reference.trimmingCharacters(in: .whitespacesAndNewlines),
            currentStage: .readFull,
            startedAt: Date(),
            nextPracticeDate: Date(),
            practiceCount: 0
        )
        Task {
            _ = try? Firestore.firestore().collection("scriptureMemory").addDocument(from: card)
            onAdded(card)
            dismiss()
        }
    }
}

// MARK: - Memory Practice View
struct MemoryPracticeView: View {
    @State var card: ScriptureMemoryCard
    let onComplete: (ScriptureMemoryCard) -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var userInput = ""
    @State private var showSuccess = false
    @State private var showVerse = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: ABTheme.paddingLarge) {
                    // Stage header
                    VStack(spacing: 8) {
                        Image(systemName: card.currentStage.icon)
                            .font(.system(size: 36))
                            .foregroundColor(ABTheme.sageGreen)

                        Text(card.currentStage.title)
                            .font(ABTheme.headlineFont)
                            .foregroundColor(ABTheme.primaryText)

                        Text(card.reference)
                            .font(.system(.body, design: .serif, weight: .semibold))
                            .foregroundColor(ABTheme.warmGold)

                        Text(card.currentStage.instruction)
                            .font(ABTheme.captionFont)
                            .foregroundColor(ABTheme.secondaryText)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, ABTheme.paddingMedium)

                    // Progress dots
                    HStack(spacing: 8) {
                        ForEach(MemoryStage.allCases.filter { $0 != .memorized }, id: \.rawValue) { stage in
                            Circle()
                                .fill(stage.rawValue <= card.currentStage.rawValue ? ABTheme.sageGreen : ABTheme.secondaryText.opacity(0.2))
                                .frame(width: 10, height: 10)
                        }
                    }

                    if showSuccess {
                        successView
                    } else {
                        practiceContent
                    }

                    Spacer().frame(height: 40)
                }
                .padding(.horizontal, ABTheme.paddingMedium)
            }
            .abScreenBackground()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(ABTheme.sageGreen)
                }
            }
        }
    }

    // MARK: - Practice Content

    @ViewBuilder
    private var practiceContent: some View {
        switch card.currentStage {
        case .readFull:
            // Show full verse
            VStack(spacing: ABTheme.paddingMedium) {
                Text(card.verseText)
                    .font(.system(.title3, design: .serif).italic())
                    .foregroundColor(ABTheme.primaryText)
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
                    .padding(ABTheme.paddingLarge)
                    .abCard()

                Text("Read it slowly. Three times. Let each word settle.")
                    .font(.caption)
                    .foregroundColor(ABTheme.secondaryText)

                Button { completeStage() } label: {
                    HStack { Image(systemName: "checkmark.circle.fill"); Text("I've Read It") }
                }
                .buttonStyle(ABPrimaryButtonStyle())
            }

        case .fillBlanks:
            // Show verse with blanks
            let result = card.currentStage.blankedText(from: card.verseText)
            VStack(spacing: ABTheme.paddingMedium) {
                Text(result.display)
                    .font(.system(.body, design: .serif))
                    .foregroundColor(ABTheme.primaryText)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(ABTheme.paddingLarge)
                    .abCard()

                Button { showVerse.toggle() } label: {
                    Text(showVerse ? "Hide Answer" : "Show Answer")
                        .font(.system(.caption, design: .serif, weight: .medium))
                        .foregroundColor(ABTheme.warmGold)
                }

                if showVerse {
                    Text(card.verseText)
                        .font(.system(.caption, design: .serif).italic())
                        .foregroundColor(ABTheme.secondaryText)
                        .multilineTextAlignment(.center)
                        .padding()
                }

                Button { completeStage() } label: {
                    HStack { Image(systemName: "checkmark.circle.fill"); Text("I Got It") }
                }
                .buttonStyle(ABPrimaryButtonStyle())
            }

        case .firstLetters:
            // Show first letters only
            let hintText = card.currentStage.firstLettersText(from: card.verseText)
            VStack(spacing: ABTheme.paddingMedium) {
                Text(hintText)
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(ABTheme.primaryText)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(ABTheme.paddingLarge)
                    .abCard()

                Button { showVerse.toggle() } label: {
                    Text(showVerse ? "Hide Verse" : "Need a Peek?")
                        .font(.system(.caption, design: .serif, weight: .medium))
                        .foregroundColor(ABTheme.warmGold)
                }

                if showVerse {
                    Text(card.verseText)
                        .font(.system(.caption, design: .serif).italic())
                        .foregroundColor(ABTheme.secondaryText)
                        .multilineTextAlignment(.center)
                        .padding()
                }

                Button { completeStage() } label: {
                    HStack { Image(systemName: "checkmark.circle.fill"); Text("I Recalled It") }
                }
                .buttonStyle(ABPrimaryButtonStyle())
            }

        case .fullRecall:
            // No hints — type or recite from memory
            VStack(spacing: ABTheme.paddingMedium) {
                VStack(spacing: 8) {
                    Image(systemName: "brain.head.profile")
                        .font(.title)
                        .foregroundColor(ABTheme.warmGold.opacity(0.5))

                    Text("Speak or type this verse from memory")
                        .font(ABTheme.captionFont)
                        .foregroundColor(ABTheme.secondaryText)
                }
                .padding(ABTheme.paddingLarge)
                .frame(maxWidth: .infinity)
                .abCard()

                TextEditor(text: $userInput)
                    .font(.system(.body, design: .serif))
                    .frame(minHeight: 100)
                    .padding(8)
                    .background(ABTheme.softWhite)
                    .cornerRadius(ABTheme.cornerRadiusSmall)
                    .overlay(RoundedRectangle(cornerRadius: ABTheme.cornerRadiusSmall).stroke(ABTheme.sageGreen.opacity(0.2), lineWidth: 1))

                Button { showVerse.toggle() } label: {
                    Text(showVerse ? "Hide Answer" : "Check Answer")
                        .font(.system(.caption, design: .serif, weight: .medium))
                        .foregroundColor(ABTheme.warmGold)
                }

                if showVerse {
                    Text(card.verseText)
                        .font(.system(.body, design: .serif).italic())
                        .foregroundColor(ABTheme.sageGreen)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding()
                        .abCard()
                }

                Button { completeStage() } label: {
                    HStack { Image(systemName: "checkmark.seal.fill"); Text("I Memorized It!") }
                }
                .buttonStyle(ABPrimaryButtonStyle())
            }

        case .memorized:
            EmptyView()
        }
    }

    // MARK: - Success View

    private var successView: some View {
        VStack(spacing: ABTheme.paddingMedium) {
            Image(systemName: card.isCompleted ? "crown.fill" : "sparkles")
                .font(.system(size: 44))
                .foregroundColor(ABTheme.warmGold)

            Text(card.isCompleted ? "Verse Memorized!" : "Stage Complete!")
                .font(ABTheme.headlineFont)
                .foregroundColor(ABTheme.primaryText)

            Text(card.isCompleted
                 ? "\(card.reference) now lives in your heart. You carry God's Word wherever you go."
                 : "Next practice: \(card.currentStage.title) in \(card.currentStage.daysToNext) days. God's Word is taking root.")
                .font(ABTheme.captionFont)
                .foregroundColor(ABTheme.secondaryText)
                .multilineTextAlignment(.center)

            Button("Continue") {
                onComplete(card)
                dismiss()
            }
            .buttonStyle(ABPrimaryButtonStyle())
        }
    }

    // MARK: - Stage Completion

    private func completeStage() {
        card.practiceCount += 1

        if let nextStage = card.currentStage.next {
            card.currentStage = nextStage
            if nextStage == .memorized {
                card.completedAt = Date()
                card.nextPracticeDate = Date.distantFuture
            } else {
                card.nextPracticeDate = Calendar.current.date(byAdding: .day, value: card.currentStage.daysToNext, to: Date()) ?? Date()
            }
        }

        // Save to Firestore
        if let cardID = card.id {
            try? Firestore.firestore().collection("scriptureMemory").document(cardID).setData(from: card, merge: true)
        }

        UINotificationFeedbackGenerator().notificationOccurred(.success)
        showSuccess = true
    }
}
