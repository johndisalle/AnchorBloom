import Foundation

// MARK: - Claude AI Devotional Companion Service
/// Generates personalized, scripture-backed responses to user reflections using Claude API
@MainActor
final class ClaudeAIService: ObservableObject {
    @Published var isGenerating = false
    @Published var lastResponse: String?
    @Published var errorMessage: String?

    // MARK: - Rate Limiting
    private static let freeWeeklyLimit = 1

    /// Checks if a free user can use AI this week
    static func canUseAI(isPremium: Bool, usedThisWeek: Int) -> Bool {
        if isPremium { return true }
        return usedThisWeek < freeWeeklyLimit
    }

    // MARK: - Generate Devotional Response

    /// Generates a personalized AI response based on the user's reflection
    func generateResponse(
        reflection: String,
        context: DevotionalContext
    ) async -> String? {
        guard !reflection.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return nil }

        isGenerating = true
        errorMessage = nil
        defer { isGenerating = false }

        let systemPrompt = buildSystemPrompt(context: context)
        let userMessage = buildUserMessage(reflection: reflection, context: context)

        do {
            let response = try await callClaudeAPI(systemPrompt: systemPrompt, userMessage: userMessage)
            lastResponse = response
            return response
        } catch {
            errorMessage = "Unable to generate response. Your reflection was still saved."
            return nil
        }
    }

    // MARK: - API Call

    private func callClaudeAPI(systemPrompt: String, userMessage: String) async throws -> String {
        guard let url = URL(string: APIConfig.claudeBaseURL) else {
            throw AIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "content-type")
        request.setValue(APIConfig.claudeAPIKey, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.timeoutInterval = 30

        let body: [String: Any] = [
            "model": APIConfig.claudeModel,
            "max_tokens": 500,
            "system": systemPrompt,
            "messages": [
                ["role": "user", "content": userMessage]
            ]
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, httpResponse) = try await URLSession.shared.data(for: request)

        guard let response = httpResponse as? HTTPURLResponse, response.statusCode == 200 else {
            throw AIError.apiError
        }

        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let content = json["content"] as? [[String: Any]],
              let firstBlock = content.first,
              let text = firstBlock["text"] as? String else {
            throw AIError.parseError
        }

        return text
    }

    // MARK: - Prompt Building

    private func buildSystemPrompt(context: DevotionalContext) -> String {
        """
        You are a gentle, wise, deeply scriptural spiritual companion for a Christian woman \
        using the Anchor & Bloom devotional app. You speak like a loving older sister in Christ \
        — warm, direct, grounded in Scripture, never preachy or condescending.

        When she shares her reflection with you, respond with:
        1. Acknowledge specifically what she shared — mirror her words and feelings so she feels truly heard
        2. Connect it to a specific Bible character, story, or verse that speaks directly to her situation. \
        Don't just quote a verse — tell her WHY it matters for what she's going through right now
        3. Offer a brief, powerful word of encouragement or truth
        4. End with a short, intimate prayer (2-3 sentences, written as if praying aloud with her)

        Rules:
        - Keep your response to 3-4 short paragraphs (under 200 words total)
        - Use second person ("you", "your")
        - Be specific to what she wrote, never generic
        - Reference Scripture naturally, as part of conversation — not as proof-texts
        - Never be judgmental or minimize her feelings
        - Never use churchy clichés ("just pray about it", "God has a plan")
        - Always point to Christ's love, God's faithfulness, or the Holy Spirit's presence
        - Write like a real woman of faith would speak — not like a textbook
        - Use em dashes and natural punctuation — write with warmth and rhythm
        - Address her by name when it feels natural (her name is \(context.displayName))
        """
    }

    private func buildUserMessage(reflection: String, context: DevotionalContext) -> String {
        var message = ""

        switch context.type {
        case .morningAnchor:
            message += "This is my morning anchor reflection.\n"
            if !context.tags.isEmpty {
                message += "I'm struggling with: \(context.tags.joined(separator: ", ")).\n"
            }
            if let scripture = context.scriptureReference {
                message += "Today's scripture was: \(scripture)\n"
            }
        case .eveningBloom:
            message += "This is my evening bloom reflection.\n"
            if !context.roles.isEmpty {
                message += "Today I walked in these roles: \(context.roles.joined(separator: ", ")).\n"
            }
        }

        message += "\nMy reflection: \(reflection)"
        return message
    }
}

// MARK: - Supporting Types

struct DevotionalContext {
    let type: DevotionalType
    let displayName: String
    let streakDays: Int
    let tags: [String]       // AnchorTag names for morning
    let roles: [String]      // BloomRole names for evening
    let scriptureReference: String?

    enum DevotionalType {
        case morningAnchor
        case eveningBloom
    }
}

enum AIError: LocalizedError {
    case invalidURL
    case apiError
    case parseError
    case rateLimited

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid API configuration."
        case .apiError: return "Unable to reach the AI service."
        case .parseError: return "Unable to read the response."
        case .rateLimited: return "You've used your free AI response this week. Upgrade to Premium for unlimited."
        }
    }
}
