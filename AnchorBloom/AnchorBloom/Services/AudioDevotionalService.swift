import Foundation
import AVFoundation

// MARK: - Audio Devotional Service
/// Converts devotional text to speech using ElevenLabs API with local caching and AVAudioPlayer playback
@MainActor
final class AudioDevotionalService: NSObject, ObservableObject, AVAudioPlayerDelegate {
    @Published var isPlaying = false
    @Published var isLoading = false
    @Published var playbackProgress: Double = 0
    @Published var duration: Double = 0
    @Published var errorMessage: String?

    private var audioPlayer: AVAudioPlayer?
    private var progressTimer: Timer?
    private let cacheDirectory: URL

    override init() {
        let caches = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        cacheDirectory = caches.appendingPathComponent("AudioDevotionals", isDirectory: true)
        super.init()
        try? FileManager.default.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        configureAudioSession()
    }

    // MARK: - Audio Session

    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .spokenAudio)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            // Audio session setup failed — playback may not work
        }
    }

    // MARK: - Play Text

    /// Converts text to speech and plays it. Caches audio for repeat plays.
    func play(text: String, cacheKey: String) async {
        stop()
        isLoading = true
        errorMessage = nil

        let cachedFile = cacheDirectory.appendingPathComponent("\(cacheKey).mp3")

        // Use cached audio if available
        if FileManager.default.fileExists(atPath: cachedFile.path) {
            playAudioFile(at: cachedFile)
            isLoading = false
            return
        }

        // Generate via ElevenLabs
        do {
            let audioData = try await generateSpeech(text: text)
            try audioData.write(to: cachedFile)
            playAudioFile(at: cachedFile)
        } catch {
            errorMessage = "Unable to generate audio. Please try again."
        }

        isLoading = false
    }

    // MARK: - Playback Controls

    func togglePlayPause() {
        guard let player = audioPlayer else { return }
        if player.isPlaying {
            player.pause()
            isPlaying = false
            progressTimer?.invalidate()
        } else {
            player.play()
            isPlaying = true
            startProgressTimer()
        }
    }

    func stop() {
        audioPlayer?.stop()
        audioPlayer = nil
        isPlaying = false
        playbackProgress = 0
        duration = 0
        progressTimer?.invalidate()
    }

    func seek(to progress: Double) {
        guard let player = audioPlayer else { return }
        player.currentTime = progress * player.duration
        playbackProgress = progress
    }

    // MARK: - ElevenLabs API

    private func generateSpeech(text: String) async throws -> Data {
        let voiceID = APIConfig.elevenLabsFemaleVoiceID
        guard let url = URL(string: "\(APIConfig.elevenLabsBaseURL)/\(voiceID)") else {
            throw AudioError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(APIConfig.elevenLabsAPIKey, forHTTPHeaderField: "xi-api-key")
        request.timeoutInterval = 60

        let body: [String: Any] = [
            "text": text,
            "model_id": "eleven_monolingual_v1",
            "voice_settings": [
                "stability": 0.65,
                "similarity_boost": 0.75,
                "style": 0.35,
                "use_speaker_boost": true
            ]
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, httpResponse) = try await URLSession.shared.data(for: request)

        guard let response = httpResponse as? HTTPURLResponse, response.statusCode == 200 else {
            throw AudioError.apiError
        }

        guard !data.isEmpty else {
            throw AudioError.emptyResponse
        }

        return data
    }

    // MARK: - Audio Playback

    private func playAudioFile(at url: URL) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            duration = audioPlayer?.duration ?? 0
            audioPlayer?.play()
            isPlaying = true
            startProgressTimer()
        } catch {
            errorMessage = "Unable to play audio."
        }
    }

    private func startProgressTimer() {
        progressTimer?.invalidate()
        progressTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self, let player = self.audioPlayer, player.duration > 0 else { return }
                self.playbackProgress = player.currentTime / player.duration
            }
        }
    }

    // MARK: - AVAudioPlayerDelegate

    nonisolated func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        Task { @MainActor in
            isPlaying = false
            playbackProgress = 0
            progressTimer?.invalidate()
        }
    }

    // MARK: - Cache Management

    func clearCache() {
        try? FileManager.default.removeItem(at: cacheDirectory)
        try? FileManager.default.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }
}

// MARK: - Audio Errors

enum AudioError: LocalizedError {
    case invalidURL
    case apiError
    case emptyResponse

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid audio configuration."
        case .apiError: return "Unable to generate audio."
        case .emptyResponse: return "No audio was returned."
        }
    }
}
