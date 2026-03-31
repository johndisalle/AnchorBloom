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
    case envy = "Envy"
    case peoplepleasing = "People-Pleasing"
    case anger = "Anger"
    case selfPity = "Self-Pity"
    case impatience = "Impatience"
    case doubt = "Doubt"
    case temptation = "Temptation"
    case selfReliance = "Self-Reliance"
    case lust = "Lust"
    case avoidance = "Avoidance"
    case anxiety = "Anxiety"
    case distraction = "Distraction"
    case laziness = "Laziness"

    var icon: String {
        switch self {
        case .comparison: return "arrow.left.arrow.right"
        case .perfectionism: return "checkmark.seal"
        case .envy: return "eye"
        case .peoplepleasing: return "person.2"
        case .anger: return "flame"
        case .selfPity: return "cloud.rain"
        case .impatience: return "clock"
        case .doubt: return "questionmark.circle"
        case .temptation: return "exclamationmark.triangle"
        case .selfReliance: return "figure.stand"
        case .lust: return "heart.slash"
        case .avoidance: return "arrow.uturn.backward"
        case .anxiety: return "waveform.path.ecg"
        case .distraction: return "sparkles"
        case .laziness: return "bed.double"
        }
    }

    var anchoringVerse: String {
        switch self {
        case .comparison:
            return "\"I praise you because I am fearfully and wonderfully made.\" — Psalm 139:14"
        case .perfectionism:
            return "\"My grace is sufficient for you, for my power is made perfect in weakness.\" — 2 Corinthians 12:9"
        case .envy:
            return "\"A heart at peace gives life to the body, but envy rots the bones.\" — Proverbs 14:30"
        case .peoplepleasing:
            return "\"Am I now trying to win the approval of human beings, or of God?\" — Galatians 1:10"
        case .anger:
            return "\"My dear brothers and sisters, take note of this: Everyone should be quick to listen, slow to speak and slow to become angry.\" — James 1:19"
        case .selfPity:
            return "\"The Lord is close to the brokenhearted and saves those who are crushed in spirit.\" — Psalm 34:18"
        case .impatience:
            return "\"But those who hope in the Lord will renew their strength.\" — Isaiah 40:31"
        case .doubt:
            return "\"I can do all things through Christ who strengthens me.\" — Philippians 4:13"
        case .temptation:
            return "\"No temptation has overtaken you except what is common to mankind. And God is faithful; he will not let you be tempted beyond what you can bear.\" — 1 Corinthians 10:13"
        case .selfReliance:
            return "\"Trust in the Lord with all your heart and lean not on your own understanding.\" — Proverbs 3:5"
        case .lust:
            return "\"Flee from sexual immorality. Your body is a temple of the Holy Spirit.\" — 1 Corinthians 6:18-19"
        case .avoidance:
            return "\"Have I not commanded you? Be strong and courageous. Do not be afraid; do not be discouraged.\" — Joshua 1:9"
        case .anxiety:
            return "\"Cast all your anxiety on him because he cares for you.\" — 1 Peter 5:7"
        case .distraction:
            return "\"Let us run with perseverance the race marked out for us, fixing our eyes on Jesus.\" — Hebrews 12:1-2"
        case .laziness:
            return "\"Whatever you do, work at it with all your heart, as working for the Lord.\" — Colossians 3:23"
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
    case perfectionism = "Perfectionism"
    case envy = "Envy"
    case peoplepleasing = "People-Pleasing"
    case anger = "Anger"
    case selfPity = "Self-Pity"
    case impatience = "Impatience"
    case doubt = "Doubt"
    case temptation = "Temptation"
    case selfReliance = "Self-Reliance"
    case lust = "Lust"
    case avoidance = "Avoidance"
    case anxiety = "Anxiety"
    case distraction = "Distraction"
    case laziness = "Laziness"

    var icon: String {
        switch self {
        case .comparison: return "arrow.left.arrow.right.circle.fill"
        case .perfectionism: return "checkmark.seal.fill"
        case .envy: return "eye.fill"
        case .peoplepleasing: return "face.smiling.inverse"
        case .anger: return "flame.fill"
        case .selfPity: return "cloud.rain.fill"
        case .impatience: return "clock.fill"
        case .doubt: return "questionmark.diamond.fill"
        case .temptation: return "exclamationmark.triangle.fill"
        case .selfReliance: return "figure.stand"
        case .lust: return "heart.slash.fill"
        case .avoidance: return "arrow.uturn.backward.circle.fill"
        case .anxiety: return "waveform.path.ecg"
        case .distraction: return "sparkles"
        case .laziness: return "bed.double.fill"
        }
    }

    var color: String {
        switch self {
        case .comparison: return "blush"
        case .perfectionism: return "sageGreen"
        case .envy: return "blush"
        case .peoplepleasing: return "warmGold"
        case .anger: return "blush"
        case .selfPity: return "darkNavy"
        case .impatience: return "warmGold"
        case .doubt: return "sageGreen"
        case .temptation: return "warmGold"
        case .selfReliance: return "darkNavy"
        case .lust: return "blush"
        case .avoidance: return "darkNavy"
        case .anxiety: return "warmGold"
        case .distraction: return "sageGreen"
        case .laziness: return "darkNavy"
        }
    }

    var anchoringPrayer: String {
        switch self {
        case .comparison:
            return "Lord, anchor my heart in Your truth today. I am fearfully and wonderfully made. Help me to celebrate who You created me to be, and to rejoice in the gifts You've given others without losing sight of my own. I am enough because You are enough. Amen."
        case .perfectionism:
            return "Jesus, I release my need to be perfect. Your grace is sufficient for me. Your power is made perfect in my weakness. Help me to rest in Your finished work and find freedom in Your love. Amen."
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
        case .temptation:
            return "Lord, I know no temptation has overtaken me except what is common to mankind. You are faithful — You will not let me be tempted beyond what I can bear. Show me the way out and give me strength to take it. Amen."
        case .selfReliance:
            return "Father, forgive me for trying to do this on my own. Apart from You I can do nothing. Teach me to lean on You, to trust Your strength over mine, and to surrender control to Your capable hands. Amen."
        case .lust:
            return "Holy Spirit, guard my eyes, my heart, and my mind. My body is Your temple. Help me to flee from what dishonors You and to run toward purity and holiness. Fill the empty places in me with Your love. Amen."
        case .avoidance:
            return "Lord, give me courage to face what I've been running from. You have not given me a spirit of fear. Walk with me into the hard places. I trust that You go before me and stand beside me. Amen."
        case .anxiety:
            return "Father, I cast all my anxiety on You because You care for me. Quiet the racing thoughts. Replace my worry with worship. You are in control, and I am safe in Your hands. Amen."
        case .distraction:
            return "Jesus, fix my eyes on You today. The world is loud, but Your voice is what matters. Help me to set my mind on things above and to run the race marked out for me with perseverance. Amen."
        case .laziness:
            return "Lord, stir in me a holy urgency to steward this day well. You have given me gifts, time, and purpose. Help me to work as if working for You — not out of guilt, but out of gratitude for all You've done. Amen."
        }
    }
}
