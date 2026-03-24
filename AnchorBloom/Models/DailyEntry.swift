import Foundation
import FirebaseFirestore

// MARK: - Daily Entry Model
/// Represents a single day's anchor (morning) and bloom (evening) entries
struct DailyEntry: Codable, Identifiable {
    @DocumentID var id: String?
    var userID: String
    var date: Date
    var dateString: String // "yyyy-MM-dd" for easy querying

    // Morning Anchor
    var anchorCompleted: Bool
    var anchorScriptureRef: String?
    var anchorReflection: String?
    var anchorTags: [AnchorTag]
    var anchorCompletedAt: Date?

    // Evening Bloom
    var bloomCompleted: Bool
    var bloomRoles: [BloomRole]
    var bloomReflection: String?
    var bloomCompletedAt: Date?

    // Drift entries for this day
    var driftEntries: [DriftEntry]

    var isFullyCompleted: Bool {
        anchorCompleted && bloomCompleted
    }

    static func new(userID: String, date: Date) -> DailyEntry {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return DailyEntry(
            userID: userID,
            date: date,
            dateString: formatter.string(from: date),
            anchorCompleted: false,
            anchorTags: [],
            bloomCompleted: false,
            bloomRoles: [],
            driftEntries: []
        )
    }
}

// MARK: - Anchor Tags
/// Quick-select tags for morning anchor reflection
enum AnchorTag: String, Codable, CaseIterable {
    case comparison = "Comparison"
    case perfectionism = "Perfectionism"
    case fear = "Fear"
    case unworthiness = "Unworthiness"
    case peoplepleasing = "People-Pleasing"
    case control = "Control"
    case busyness = "Busyness"
    case selfDoubt = "Self-Doubt"
    case culturalLies = "Cultural Lies"
    case anxiety = "Anxiety"

    var icon: String {
        switch self {
        case .comparison: return "arrow.left.arrow.right"
        case .perfectionism: return "checkmark.seal"
        case .fear: return "exclamationmark.shield"
        case .unworthiness: return "heart.slash"
        case .peoplepleasing: return "person.2"
        case .control: return "hand.raised"
        case .busyness: return "clock.arrow.circlepath"
        case .selfDoubt: return "questionmark.circle"
        case .culturalLies: return "bubble.left.and.exclamationmark.bubble.right"
        case .anxiety: return "waveform.path.ecg"
        }
    }

    var anchoringVerse: String {
        switch self {
        case .comparison:
            return "\"I praise you because I am fearfully and wonderfully made.\" — Psalm 139:14"
        case .perfectionism:
            return "\"My grace is sufficient for you, for my power is made perfect in weakness.\" — 2 Corinthians 12:9"
        case .fear:
            return "\"For God has not given us a spirit of fear, but of power, love, and a sound mind.\" — 2 Timothy 1:7"
        case .unworthiness:
            return "\"See what great love the Father has lavished on us, that we should be called children of God!\" — 1 John 3:1"
        case .peoplepleasing:
            return "\"Am I now trying to win the approval of human beings, or of God?\" — Galatians 1:10"
        case .control:
            return "\"Trust in the Lord with all your heart and lean not on your own understanding.\" — Proverbs 3:5"
        case .busyness:
            return "\"Be still, and know that I am God.\" — Psalm 46:10"
        case .selfDoubt:
            return "\"I can do all things through Christ who strengthens me.\" — Philippians 4:13"
        case .culturalLies:
            return "\"Do not conform to the pattern of this world, but be transformed by the renewing of your mind.\" — Romans 12:2"
        case .anxiety:
            return "\"Cast all your anxiety on him because he cares for you.\" — 1 Peter 5:7"
        }
    }
}

// MARK: - Bloom Roles
/// Biblical womanhood roles for evening bloom reflection
enum BloomRole: String, Codable, CaseIterable {
    case nurturer = "Nurturer"
    case wiseCounselor = "Wise Counselor"
    case prayerWarrior = "Prayer Warrior"
    case helperPartner = "Helper & Partner"
    case peaceCultivator = "Cultivator of Peace"
    case beautyCultivator = "Cultivator of Beauty"
    case kingdomInfluencer = "Kingdom Influencer"
    case gracefulSpeaker = "Graceful Speaker"

    var icon: String {
        switch self {
        case .nurturer: return "heart.circle.fill"
        case .wiseCounselor: return "lightbulb.fill"
        case .prayerWarrior: return "hands.sparkles.fill"
        case .helperPartner: return "person.2.fill"
        case .peaceCultivator: return "leaf.fill"
        case .beautyCultivator: return "sparkles"
        case .kingdomInfluencer: return "globe.americas.fill"
        case .gracefulSpeaker: return "quote.bubble.fill"
        }
    }

    var description: String {
        switch self {
        case .nurturer:
            return "Caring for others with tenderness and warmth"
        case .wiseCounselor:
            return "Speaking truth with love and discernment"
        case .prayerWarrior:
            return "Interceding faithfully for others"
        case .helperPartner:
            return "Supporting and strengthening those God placed beside you"
        case .peaceCultivator:
            return "Creating calm, grace-filled spaces"
        case .beautyCultivator:
            return "Stewarding beauty that reflects God's glory"
        case .kingdomInfluencer:
            return "Advancing God's kingdom through your unique gifts"
        case .gracefulSpeaker:
            return "Using words to build up, encourage, and heal"
        }
    }

    var scriptureReference: String {
        switch self {
        case .nurturer: return "Titus 2:4-5"
        case .wiseCounselor: return "Proverbs 31:26"
        case .prayerWarrior: return "1 Thessalonians 5:17"
        case .helperPartner: return "Genesis 2:18"
        case .peaceCultivator: return "Romans 12:18"
        case .beautyCultivator: return "Philippians 4:8"
        case .kingdomInfluencer: return "Esther 4:14"
        case .gracefulSpeaker: return "Ephesians 4:29"
        }
    }
}

// MARK: - Drift Entry
/// Quick one-tap drift log entries with optional prayer
struct DriftEntry: Codable, Identifiable {
    var id: String = UUID().uuidString
    var timestamp: Date
    var category: DriftCategory
    var note: String?
    var prayerPlayed: Bool

    init(category: DriftCategory, note: String? = nil) {
        self.timestamp = Date()
        self.category = category
        self.note = note
        self.prayerPlayed = false
    }
}

// MARK: - Drift Categories
enum DriftCategory: String, Codable, CaseIterable {
    case comparison = "Comparison"
    case fear = "Fear"
    case perfectionism = "Perfectionism"
    case overwhelm = "Overwhelm"
    case envy = "Envy"
    case peoplepleasing = "People-Pleasing"
    case anger = "Anger"
    case selfPity = "Self-Pity"
    case impatience = "Impatience"
    case doubt = "Doubt"

    var icon: String {
        switch self {
        case .comparison: return "arrow.left.arrow.right.circle.fill"
        case .fear: return "exclamationmark.triangle.fill"
        case .perfectionism: return "checkmark.seal.fill"
        case .overwhelm: return "tornado"
        case .envy: return "eye.fill"
        case .peoplepleasing: return "face.smiling.inverse"
        case .anger: return "flame.fill"
        case .selfPity: return "cloud.rain.fill"
        case .impatience: return "clock.fill"
        case .doubt: return "questionmark.diamond.fill"
        }
    }

    var color: String {
        switch self {
        case .comparison: return "blush"
        case .fear: return "warmGold"
        case .perfectionism: return "sageGreen"
        case .overwhelm: return "darkNavy"
        case .envy: return "blush"
        case .peoplepleasing: return "warmGold"
        case .anger: return "blush"
        case .selfPity: return "darkNavy"
        case .impatience: return "warmGold"
        case .doubt: return "sageGreen"
        }
    }

    var anchoringPrayer: String {
        switch self {
        case .comparison:
            return "Lord, anchor my heart in Your truth today. I am fearfully and wonderfully made. Help me to celebrate who You created me to be, and to rejoice in the gifts You've given others without losing sight of my own. I am enough because You are enough. Amen."
        case .fear:
            return "Father, I bring this fear to You. You have not given me a spirit of fear but of power, love, and a sound mind. Wrap me in Your peace. I trust You with what I cannot control. You are my refuge and strength. Amen."
        case .perfectionism:
            return "Jesus, I release my need to be perfect. Your grace is sufficient for me. Your power is made perfect in my weakness. Help me to rest in Your finished work and find freedom in Your love. Amen."
        case .overwhelm:
            return "Holy Spirit, I feel the weight of too much right now. Remind me that You are the God who carries my burdens. Help me to be still and know that You are God. Order my steps and give me peace. Amen."
        case .envy:
            return "Lord, guard my heart from wanting what belongs to another. You have given me everything I need for life and godliness. Help me to steward my own gifts with gratitude and to bless others generously. Amen."
        case .peoplepleasing:
            return "Father, free me from the trap of seeking approval from others. I live for an audience of One. Help me to find my worth and identity in You alone, and to love others from that secure place. Amen."
        case .anger:
            return "Lord, I bring this anger to You. Search my heart and show me what's underneath. Give me Your gentleness and self-control. Help me to be quick to listen, slow to speak, and slow to become angry. Amen."
        case .selfPity:
            return "Jesus, lift my eyes from myself to You. You are the author of my story, and You waste nothing. Turn my sorrow into praise and my mourning into dancing. I choose to trust Your good plan. Amen."
        case .impatience:
            return "Lord, teach me to wait on You with grace. Your timing is perfect. Help me to trust the process and to find joy in the journey, not just the destination. Grow patience in me like a deep-rooted tree. Amen."
        case .doubt:
            return "Father, I believe — help my unbelief. When doubts arise, anchor me in Your unchanging Word. You are faithful even when I waver. Strengthen my faith and remind me of all the ways You've been faithful before. Amen."
        }
    }
}
