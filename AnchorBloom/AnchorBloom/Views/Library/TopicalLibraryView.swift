import SwiftUI

// MARK: - Topical Devotional Model
struct TopicalDevotional: Identifiable {
    let id = UUID()
    let title: String
    let category: TopicalCategory
    let scripture: String
    let scriptureReference: String
    let reflection: String
    let prayer: String
    let relatedDrift: DriftCategory?
}

enum TopicalCategory: String, CaseIterable {
    case identity = "Identity & Worth"
    case relationships = "Relationships"
    case loss = "Loss & Grief"
    case fear = "Fear & Anxiety"
    case purpose = "Purpose & Calling"
    case marriage = "Marriage & Love"
    case motherhood = "Motherhood"
    case work = "Work & Career"
    case body = "Body & Health"
    case seasons = "Hard Seasons"

    var icon: String {
        switch self {
        case .identity: return "person.fill"
        case .relationships: return "person.2.fill"
        case .loss: return "heart.slash.fill"
        case .fear: return "cloud.rain.fill"
        case .purpose: return "star.fill"
        case .marriage: return "heart.circle.fill"
        case .motherhood: return "figure.and.child.holdinghands"
        case .work: return "briefcase.fill"
        case .body: return "figure.stand"
        case .seasons: return "leaf.fill"
        }
    }
}

// MARK: - Topical Library View
struct TopicalLibraryView: View {
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @Environment(\.dismiss) private var dismiss

    @State private var searchText = ""
    @State private var selectedCategory: TopicalCategory?
    @State private var selectedDevotional: TopicalDevotional?
    @State private var showUpgrade = false
    @AppStorage("topicalViewsThisMonth") private var viewsThisMonth = 0
    @AppStorage("topicalMonthKey") private var monthKey = ""

    private let freeMonthlyLimit = 3

    private var filteredDevotionals: [TopicalDevotional] {
        var results = TopicalDevotionalContent.all
        if let cat = selectedCategory {
            results = results.filter { $0.category == cat }
        }
        if !searchText.isEmpty {
            let lowered = searchText.lowercased()
            results = results.filter {
                $0.title.lowercased().contains(lowered) ||
                $0.reflection.lowercased().contains(lowered) ||
                $0.category.rawValue.lowercased().contains(lowered)
            }
        }
        return results
    }

    private var currentMonthKey: String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM"
        return f.string(from: Date())
    }

    private var canView: Bool {
        subscriptionManager.isPremium || viewsThisMonth < freeMonthlyLimit
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(ABTheme.secondaryText)
                    TextField("Search by topic or feeling...", text: $searchText)
                        .font(ABTheme.bodyFont)
                        .textInputAutocapitalization(.never)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(ABTheme.cardBackground)
                .cornerRadius(ABTheme.cornerRadius)
                .padding(.horizontal, ABTheme.paddingMedium)
                .padding(.top, ABTheme.paddingSmall)

                // Category chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        Button {
                            selectedCategory = nil
                        } label: {
                            Text("All")
                                .font(.system(.caption, design: .serif, weight: .medium))
                                .foregroundColor(selectedCategory == nil ? .white : ABTheme.primaryText)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 7)
                                .background(selectedCategory == nil ? ABTheme.sageGreen : ABTheme.cardBackground)
                                .cornerRadius(16)
                        }

                        ForEach(TopicalCategory.allCases, id: \.self) { cat in
                            Button {
                                selectedCategory = selectedCategory == cat ? nil : cat
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: cat.icon).font(.system(size: 10))
                                    Text(cat.rawValue).font(.system(.caption, design: .serif, weight: .medium))
                                }
                                .foregroundColor(selectedCategory == cat ? .white : ABTheme.primaryText)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 7)
                                .background(selectedCategory == cat ? ABTheme.blush : ABTheme.cardBackground)
                                .cornerRadius(16)
                            }
                        }
                    }
                    .padding(.horizontal, ABTheme.paddingMedium)
                    .padding(.vertical, ABTheme.paddingSmall)
                }

                // Free usage counter
                if !subscriptionManager.isPremium {
                    HStack(spacing: 8) {
                        Image(systemName: "book.closed.fill")
                            .foregroundColor(ABTheme.warmGold)
                            .font(.caption)
                        let remaining = max(0, freeMonthlyLimit - viewsThisMonth)
                        Text("\(remaining) free devotional\(remaining == 1 ? "" : "s") this month")
                            .font(.system(.caption, design: .serif, weight: .medium))
                            .foregroundColor(ABTheme.primaryText)
                        Spacer()
                        Button { showUpgrade = true } label: {
                            Text("Unlock All")
                                .font(.system(.caption2, design: .serif, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(ABTheme.warmGold)
                                .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal, ABTheme.paddingMedium)
                    .padding(.vertical, 8)
                    .background(ABTheme.warmGold.opacity(0.08))
                }

                // Results
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(filteredDevotionals) { dev in
                            Button {
                                if canView {
                                    selectedDevotional = dev
                                    trackView()
                                } else {
                                    showUpgrade = true
                                }
                            } label: {
                                HStack(spacing: 12) {
                                    ZStack {
                                        Circle()
                                            .fill(ABTheme.blush.opacity(0.15))
                                            .frame(width: 40, height: 40)
                                        Image(systemName: dev.category.icon)
                                            .font(.system(size: 16))
                                            .foregroundColor(ABTheme.blush)
                                    }

                                    VStack(alignment: .leading, spacing: 3) {
                                        Text(dev.title)
                                            .font(.system(.body, design: .serif, weight: .semibold))
                                            .foregroundColor(ABTheme.primaryText)
                                            .lineLimit(1)
                                        Text(dev.scriptureReference)
                                            .font(.system(.caption, design: .serif))
                                            .foregroundColor(ABTheme.sageGreen)
                                        Text(dev.category.rawValue)
                                            .font(.caption2)
                                            .foregroundColor(ABTheme.secondaryText)
                                    }

                                    Spacer()

                                    if !canView && !subscriptionManager.isPremium {
                                        Image(systemName: "lock.fill")
                                            .font(.caption)
                                            .foregroundColor(ABTheme.warmGold)
                                    } else {
                                        Image(systemName: "chevron.right")
                                            .font(.caption)
                                            .foregroundColor(ABTheme.secondaryText)
                                    }
                                }
                                .abCard()
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, ABTheme.paddingMedium)
                    .padding(.top, ABTheme.paddingSmall)
                }
            }
            .abScreenBackground()
            .navigationTitle("Devotional Library")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }.foregroundColor(ABTheme.sageGreen)
                }
            }
            .sheet(item: $selectedDevotional) { dev in
                TopicalDevotionalDetailView(devotional: dev)
            }
            .sheet(isPresented: $showUpgrade) { SubscriptionView() }
            .onAppear { resetMonthlyCountIfNeeded() }
        }
    }

    private func trackView() {
        resetMonthlyCountIfNeeded()
        if !subscriptionManager.isPremium {
            viewsThisMonth += 1
        }
    }

    private func resetMonthlyCountIfNeeded() {
        if monthKey != currentMonthKey {
            monthKey = currentMonthKey
            viewsThisMonth = 0
        }
    }
}

// MARK: - Devotional Detail View
struct TopicalDevotionalDetailView: View {
    let devotional: TopicalDevotional
    @Environment(\.dismiss) private var dismiss
    @StateObject private var audioService = AudioDevotionalService()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: ABTheme.paddingLarge) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: devotional.category.icon)
                            .font(.system(size: 32))
                            .foregroundColor(ABTheme.blush)

                        Text(devotional.title)
                            .font(ABTheme.headlineFont)
                            .foregroundColor(ABTheme.primaryText)
                            .multilineTextAlignment(.center)

                        Text(devotional.category.rawValue)
                            .font(.system(.caption, design: .serif))
                            .foregroundColor(ABTheme.secondaryText)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, ABTheme.paddingSmall)

                    // Scripture
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Scripture")
                                .font(ABTheme.subheadlineFont)
                                .foregroundColor(ABTheme.primaryText)
                            Spacer()
                            ListenButton(audioService: audioService, text: devotional.scripture, cacheKey: "topical_\(devotional.id)")
                        }
                        Text(devotional.scripture)
                            .font(ABTheme.scriptureFont)
                            .foregroundColor(ABTheme.primaryText)
                            .lineSpacing(4)
                        Text("— \(devotional.scriptureReference)")
                            .font(.system(.caption, design: .serif, weight: .semibold))
                            .foregroundColor(ABTheme.sageGreen)
                    }
                    .abCard()

                    // Reflection
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Reflection")
                            .font(ABTheme.subheadlineFont)
                            .foregroundColor(ABTheme.primaryText)
                        Text(devotional.reflection)
                            .font(ABTheme.bodyFont)
                            .foregroundColor(ABTheme.primaryText)
                            .lineSpacing(4)
                    }
                    .abCard()

                    // Prayer
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "hands.sparkles.fill")
                                .foregroundColor(ABTheme.warmGold)
                            Text("Prayer")
                                .font(ABTheme.subheadlineFont)
                                .foregroundColor(ABTheme.primaryText)
                        }
                        Text(devotional.prayer)
                            .font(.system(.body, design: .serif).italic())
                            .foregroundColor(ABTheme.secondaryText)
                            .lineSpacing(4)
                    }
                    .abCard()

                    // Bookmark & Share
                    ScriptureActionButtons(
                        verseText: devotional.scripture,
                        reference: devotional.scriptureReference,
                        source: .morningAnchor
                    )

                    Spacer().frame(height: 40)
                }
                .padding(.horizontal, ABTheme.paddingMedium)
            }
            .abScreenBackground()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }.foregroundColor(ABTheme.sageGreen)
                }
            }
        }
    }
}

// MARK: - Topical Devotional Content
enum TopicalDevotionalContent {
    static let all: [TopicalDevotional] = [
        TopicalDevotional(
            title: "When You Feel Unseen",
            category: .identity,
            scripture: "She gave this name to the Lord who spoke to her: \"You are the God who sees me,\" for she said, \"I have now seen the One who sees me.\"",
            scriptureReference: "Genesis 16:13",
            reflection: "Hagar was an outcast — used, discarded, and running. She was the last person anyone would notice. But God didn't just see her — He went after her. He met her in the wilderness and called her by name. You are not invisible. The God who found Hagar in the desert sees you right now, in every hidden struggle, every quiet sacrifice, every tear no one else notices.",
            prayer: "El Roi, the God who sees me — thank You for never looking away. When I feel invisible, remind me that Your eyes are always on me. Not watching to judge, but watching because You love me. I am seen. I am known. And that is enough. Amen.",
            relatedDrift: .comparison
        ),
        TopicalDevotional(
            title: "When Your Marriage Feels Dry",
            category: .marriage,
            scripture: "Above all, love each other deeply, because love covers over a multitude of sins.",
            scriptureReference: "1 Peter 4:8",
            reflection: "Every marriage has winters — seasons where the feelings fade and the routine feels heavy. But love was never meant to be a feeling alone. It's a covenant, a daily choice, a stubborn commitment that says 'I'm staying.' God didn't design marriage to be easy. He designed it to make you both more like Christ. The dry season isn't a sign of failure — it's an invitation to dig deeper roots.",
            prayer: "Lord, breathe life into my marriage. Where there is dryness, bring rain. Where there is distance, build a bridge. Teach me to love not from my feelings but from Your strength. Amen.",
            relatedDrift: nil
        ),
        TopicalDevotional(
            title: "When Anxiety Won't Stop",
            category: .fear,
            scripture: "Do not be anxious about anything, but in every situation, by prayer and petition, with thanksgiving, present your requests to God. And the peace of God, which transcends all understanding, will guard your hearts and your minds in Christ Jesus.",
            scriptureReference: "Philippians 4:6-7",
            reflection: "Anxiety tells you that you need to have the answer right now. That if you just think hard enough, worry long enough, plan far enough — you'll be safe. But God says the opposite: stop. Breathe. Pray. Give it to Me. The peace He promises isn't the absence of problems — it's a guard around your heart in the middle of them.",
            prayer: "Father, my mind is racing and my heart is heavy. I bring every anxious thought to You — not because I'm strong enough to let go, but because You're strong enough to hold it all. Guard my heart. Guard my mind. Replace my worry with worship. Amen.",
            relatedDrift: .anxiety
        ),
        TopicalDevotional(
            title: "When You've Lost Someone",
            category: .loss,
            scripture: "The Lord is close to the brokenhearted and saves those who are crushed in spirit.",
            scriptureReference: "Psalm 34:18",
            reflection: "Grief is not a problem to solve. It's love with nowhere to go. And God doesn't ask you to rush through it or paste on a brave face. He draws closer in your pain — not standing at a distance, but sitting with you in the ashes. Your tears are not weakness. They are the language of a heart that loved deeply. And God understands every word.",
            prayer: "Lord, I miss them. The ache is real and it doesn't go away. But I trust that You are close — closer now than ever. Hold me in this grief. Let me feel Your presence where their presence used to be. And give me hope that this isn't the end of the story. Amen.",
            relatedDrift: .selfPity
        ),
        TopicalDevotional(
            title: "When You're Struggling with Body Image",
            category: .body,
            scripture: "I praise you because I am fearfully and wonderfully made; your works are wonderful, I know that full well.",
            scriptureReference: "Psalm 139:14",
            reflection: "The mirror lies. Social media lies. The voice that says 'not thin enough, not pretty enough, not enough' — that is not God's voice. God handcrafted your body. He chose every detail. And when He finished, He didn't say 'it's okay' — He said 'it is wonderful.' Your body is not a project to fix. It is a temple of the Holy Spirit, carrying the image of God into the world.",
            prayer: "Father, forgive me for hating what You lovingly made. Help me see my body the way You see it — as a wonder, not a problem. Silence the lies and speak Your truth louder. I am fearfully and wonderfully made. I choose to believe it today. Amen.",
            relatedDrift: .comparison
        ),
        TopicalDevotional(
            title: "When You Don't Know Your Purpose",
            category: .purpose,
            scripture: "For we are God's handiwork, created in Christ Jesus to do good works, which God prepared in advance for us to do.",
            scriptureReference: "Ephesians 2:10",
            reflection: "You are not an accident. You are not random. You are handiwork — the Greek word is 'poiema,' where we get the word 'poem.' You are God's poem, written for a purpose He planned before you were born. If you can't see it yet, that's okay. Purpose isn't always a grand revelation. Sometimes it's the next faithful step. The meal you cook. The prayer you pray. The kindness you show. That is purpose.",
            prayer: "God, I want to know why I'm here. But even when I can't see the full picture, help me trust that You wrote my story before I lived it. Show me the next step. Just the next one. I'll take it. Amen.",
            relatedDrift: .doubt
        ),
        TopicalDevotional(
            title: "When Comparison Is Stealing Your Joy",
            category: .identity,
            scripture: "Each one should test their own actions. Then they can take pride in themselves alone, without comparing themselves to someone else.",
            scriptureReference: "Galatians 6:4",
            reflection: "Comparison doesn't just steal your joy — it steals your calling. When you're busy looking at her life, you miss the beauty in yours. God didn't make you to be her. He made you to be you — with your story, your gifts, your battles, your victories. The enemy wants you looking sideways. God wants you looking up.",
            prayer: "Lord, I confess that I've been measuring my life against someone else's. Forgive me. Help me celebrate who You made me to be. Give me eyes to see my own blessings, my own calling, my own beautiful story. Amen.",
            relatedDrift: .comparison
        ),
        TopicalDevotional(
            title: "When You're Exhausted as a Mom",
            category: .motherhood,
            scripture: "She is clothed with strength and dignity; she can laugh at the days to come.",
            scriptureReference: "Proverbs 31:25",
            reflection: "The Proverbs 31 woman wasn't a supermom who never got tired. She was a real woman who drew her strength from God. Being exhausted doesn't mean you're failing — it means you're pouring out. But you can't pour from an empty cup. Jesus Himself withdrew to rest. If the Son of God took breaks, you're allowed to sit down.",
            prayer: "Father, I'm tired. Not just physically — I'm tired in my soul. Fill me back up. Remind me that my worth as a mother isn't measured in productivity but in presence. Give me strength for today. Just today. Amen.",
            relatedDrift: .perfectionism
        ),
        TopicalDevotional(
            title: "When You Feel Like a Failure",
            category: .identity,
            scripture: "But he said to me, \"My grace is sufficient for you, for my power is made perfect in weakness.\"",
            scriptureReference: "2 Corinthians 12:9",
            reflection: "Peter denied Jesus three times. Moses murdered a man. David committed adultery. Rahab was a prostitute. And God used every single one of them to change history. Your failures are not your identity. They are the raw material God uses to build something redemptive. He doesn't need your perfection — He needs your surrender.",
            prayer: "Jesus, I feel like I've failed — again. But You didn't come for the perfect. You came for me, in all my mess. Take my weakness and make it Your strength. I surrender my shame to You today. Amen.",
            relatedDrift: .perfectionism
        ),
        TopicalDevotional(
            title: "When Work Feels Meaningless",
            category: .work,
            scripture: "Whatever you do, work at it with all your heart, as working for the Lord, not for human masters.",
            scriptureReference: "Colossians 3:23",
            reflection: "Your work matters — even when no one sees it, even when it feels repetitive, even when the paycheck doesn't match the effort. When you shift your audience from your boss to your God, everything changes. The spreadsheet becomes worship. The meeting becomes ministry. The mundane becomes sacred. You are not just working — you are serving the King.",
            prayer: "Lord, redeem my view of work. When it feels pointless, remind me that I'm working for You. Turn my labor into worship and my effort into offering. Help me bloom right where You've planted me. Amen.",
            relatedDrift: .laziness
        ),
        TopicalDevotional(
            title: "After a Miscarriage",
            category: .loss,
            scripture: "He heals the brokenhearted and binds up their wounds.",
            scriptureReference: "Psalm 147:3",
            reflection: "There are no words adequate enough for this kind of loss. The life you carried, the future you imagined, the name you might have whispered — it's real, and the grief is real. Don't let anyone minimize what you're feeling. God sees the child you lost. He held that little soul. And He is holding you now, binding wounds that no one else can see.",
            prayer: "God, my arms are empty and my heart is broken. I trust that You hold the baby I couldn't keep. Heal me gently. Let me grieve without guilt. And when I'm ready, help me hope again. Amen.",
            relatedDrift: nil
        ),
        TopicalDevotional(
            title: "When You're Going Through a Breakup",
            category: .relationships,
            scripture: "The Lord himself goes before you and will be with you; he will never leave you nor forsake you. Do not be afraid; do not be discouraged.",
            scriptureReference: "Deuteronomy 31:8",
            reflection: "A broken relationship feels like a broken future. Everything you planned, dreamed, and hoped for — suddenly gone. But here's what remains: God. He didn't leave when they did. He's not scrambling to fix this — He's already ahead of you, preparing the next chapter. This ending is not your ending.",
            prayer: "Lord, this hurts more than I expected. Fill the empty space they left. Heal the rejection I feel. Remind me that being left by someone doesn't mean being left by You. You will never leave. You will never forsake me. Amen.",
            relatedDrift: .selfPity
        ),
        TopicalDevotional(
            title: "When You're Tempted to Give Up on Faith",
            category: .fear,
            scripture: "I believe; help my unbelief!",
            scriptureReference: "Mark 9:24",
            reflection: "The most honest prayer in the Bible is just five words: 'Help my unbelief.' The man who said it didn't have perfect faith. He had desperate faith — the kind that shows up even when it doesn't feel like enough. God doesn't need you to believe perfectly. He needs you to be honest. Your doubt doesn't disqualify you. It qualifies you for grace.",
            prayer: "God, I believe — but barely. Some days my faith feels like a flickering candle. Don't let it go out. Meet me in my doubt. I'm not walking away — I'm just struggling to see You. Help me see You. Amen.",
            relatedDrift: .doubt
        ),
        TopicalDevotional(
            title: "When Someone Has Hurt You Deeply",
            category: .relationships,
            scripture: "Bear with each other and forgive one another if any of you has a grievance against someone. Forgive as the Lord forgave you.",
            scriptureReference: "Colossians 3:13",
            reflection: "Forgiveness is not saying what they did was okay. It's saying their actions no longer get to hold your heart hostage. Unforgiveness is a chain — and you're the one wearing it. Jesus forgave you at your worst. He's asking you to do the same — not because they deserve it, but because you deserve to be free.",
            prayer: "Jesus, I don't want to forgive — but I want to want to. Start there. Soften my heart. Break the chains of bitterness. Set me free from the prison of unforgiveness. I choose to release them into Your hands. Amen.",
            relatedDrift: .anger
        ),
        TopicalDevotional(
            title: "When You Feel Too Far Gone",
            category: .seasons,
            scripture: "Come now, let us settle the matter. Though your sins are like scarlet, they shall be as white as snow.",
            scriptureReference: "Isaiah 1:18",
            reflection: "The enemy's favorite lie is 'you've gone too far.' Too many mistakes. Too many failures. Too much baggage. But God's grace has no limit, no expiration, no fine print. The woman at the well had five husbands and Jesus offered her living water. The thief on the cross had hours to live and Jesus gave him paradise. It is never too late.",
            prayer: "Father, I feel unworthy of Your love. But Your Word says my scarlet sins become white as snow. I come to You — not cleaned up, not put together, just as I am. Take me back. Make me new. Amen.",
            relatedDrift: .avoidance
        ),
    ]
}
