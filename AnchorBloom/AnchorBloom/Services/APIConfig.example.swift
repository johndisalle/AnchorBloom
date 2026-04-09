import Foundation

// MARK: - API Configuration
// Copy this file to APIConfig.swift and fill in your actual API keys.
// APIConfig.swift is gitignored and will not be committed.
enum APIConfig {
    // MARK: - Claude AI (Anthropic)
    // Get your key at: https://console.anthropic.com
    static let claudeAPIKey = "YOUR_CLAUDE_API_KEY_HERE"
    static let claudeModel = "claude-sonnet-4-20250514"
    static let claudeBaseURL = "https://api.anthropic.com/v1/messages"

    // MARK: - ElevenLabs TTS
    // Get your key at: https://elevenlabs.io
    static let elevenLabsAPIKey = "YOUR_ELEVENLABS_API_KEY_HERE"
    static let elevenLabsFemaleVoiceID = "YOUR_FEMALE_VOICE_ID"
    static let elevenLabsMaleVoiceID = "YOUR_MALE_VOICE_ID"
    static let elevenLabsBaseURL = "https://api.elevenlabs.io/v1/text-to-speech"
}
