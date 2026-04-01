import Foundation

// MARK: - Content Filter
/// Filters objectionable content from user-generated posts and comments
enum ContentFilter {

    /// Words and patterns that are not allowed in posts/comments
    private static let blockedPatterns: [String] = [
        // Profanity
        "fuck", "shit", "ass", "bitch", "damn", "hell", "dick", "cock", "pussy",
        "cunt", "whore", "slut", "bastard", "nigger", "nigga", "faggot", "retard",
        // Hate speech indicators
        "kill yourself", "kys", "go die",
        // Sexual content
        "porn", "nude", "naked", "sex chat", "hookup",
        // Spam patterns
        "buy now", "click here", "free money", "earn cash",
    ]

    /// Check if content contains objectionable material
    /// Returns the offending word/phrase if found, nil if clean
    static func findViolation(in text: String) -> String? {
        let lowered = text.lowercased()
        for pattern in blockedPatterns {
            if lowered.contains(pattern) {
                return pattern
            }
        }
        return nil
    }

    /// Returns true if the content passes the filter (is clean)
    static func isClean(_ text: String) -> Bool {
        findViolation(in: text) == nil
    }
}
