import Foundation
import FirebaseFirestore

// MARK: - Scripture Memory Card Model
/// Tracks a verse being memorized through spaced repetition
struct ScriptureMemoryCard: Codable, Identifiable {
    @DocumentID var id: String?
    var userID: String
    var verseText: String
    var reference: String
    var currentStage: MemoryStage
    var startedAt: Date
    var nextPracticeDate: Date
    var completedAt: Date?
    var practiceCount: Int

    var isCompleted: Bool { currentStage == .memorized }

    var daysUntilNextPractice: Int {
        let calendar = Calendar.current
        let days = calendar.dateComponents([.day], from: Date(), to: nextPracticeDate).day ?? 0
        return max(0, days)
    }

    var isReadyToPractice: Bool {
        nextPracticeDate <= Date()
    }
}

// MARK: - Memory Stages
enum MemoryStage: Int, Codable, CaseIterable {
    case readFull = 0       // Day 1: Read the complete verse
    case fillBlanks = 1     // Day 3: Fill in missing words
    case firstLetters = 2   // Day 5: Only first letters shown
    case fullRecall = 3     // Day 7: Recall from memory
    case memorized = 4      // Complete!

    var title: String {
        switch self {
        case .readFull: return "Read & Absorb"
        case .fillBlanks: return "Fill the Gaps"
        case .firstLetters: return "First Letters"
        case .fullRecall: return "Full Recall"
        case .memorized: return "Memorized!"
        }
    }

    var instruction: String {
        switch self {
        case .readFull: return "Read this verse slowly, three times. Let each word settle into your heart."
        case .fillBlanks: return "Some words are hidden. Can you fill in what's missing?"
        case .firstLetters: return "Only the first letter of each word is shown. You know this — trust your heart."
        case .fullRecall: return "Close your eyes, take a breath, and speak this verse from memory."
        case .memorized: return "This verse lives in your heart now. You carry God's Word with you."
        }
    }

    var icon: String {
        switch self {
        case .readFull: return "book.fill"
        case .fillBlanks: return "text.redaction"
        case .firstLetters: return "character.textbox"
        case .fullRecall: return "brain.head.profile"
        case .memorized: return "checkmark.seal.fill"
        }
    }

    var dayLabel: String {
        switch self {
        case .readFull: return "Day 1"
        case .fillBlanks: return "Day 3"
        case .firstLetters: return "Day 5"
        case .fullRecall: return "Day 7"
        case .memorized: return "Complete"
        }
    }

    /// Days until next stage
    var daysToNext: Int {
        switch self {
        case .readFull: return 2      // Day 1 → Day 3
        case .fillBlanks: return 2    // Day 3 → Day 5
        case .firstLetters: return 2  // Day 5 → Day 7
        case .fullRecall: return 0    // Done
        case .memorized: return 0
        }
    }

    var next: MemoryStage? {
        MemoryStage(rawValue: rawValue + 1)
    }

    // MARK: - Text Transformations

    /// Returns verse text with random words replaced by blanks (fill-the-blanks stage)
    func blankedText(from verse: String) -> (display: String, answers: [String]) {
        let words = verse.components(separatedBy: " ")
        var display: [String] = []
        var answers: [String] = []

        for (index, word) in words.enumerated() {
            // Hide roughly every 3rd word (skip short words and first/last)
            let isTarget = index > 0 && index < words.count - 1 && index % 3 == 0 && word.count > 2
            if isTarget {
                display.append(String(repeating: "_", count: word.count))
                answers.append(word)
            } else {
                display.append(word)
            }
        }

        return (display.joined(separator: " "), answers)
    }

    /// Returns verse text with only first letters shown
    func firstLettersText(from verse: String) -> String {
        let words = verse.components(separatedBy: " ")
        return words.map { word in
            guard let first = word.first else { return word }
            let rest = String(repeating: "_", count: max(0, word.count - 1))
            return String(first) + rest
        }.joined(separator: " ")
    }
}
