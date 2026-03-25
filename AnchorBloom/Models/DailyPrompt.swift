import Foundation

// MARK: - Daily Prompt Model
/// Rotating daily prompts for morning anchor and evening bloom
struct DailyPrompt {
    let scripture: String
    let scriptureReference: String
    let prompt: String

    // MARK: - Morning Prompts (Anchor)
    static let morningPrompts: [DailyPrompt] = [
        DailyPrompt(
            scripture: "\"She is clothed with strength and dignity; she can laugh at the days to come.\"",
            scriptureReference: "Proverbs 31:25",
            prompt: "What lie about your worth or role is the enemy whispering today? Bring it to Jesus and stand firm in His truth. You are clothed in strength — not because of what you do, but because of Whose you are."
        ),
        DailyPrompt(
            scripture: "\"Charm is deceptive, and beauty is fleeting; but a woman who fears the Lord is to be praised.\"",
            scriptureReference: "Proverbs 31:30",
            prompt: "Where are you seeking approval or validation from the world instead of from God? Anchor yourself in His delight over you today."
        ),
        DailyPrompt(
            scripture: "\"Your beauty should not come from outward adornment... Rather, it should be that of your inner self, the unfading beauty of a gentle and quiet spirit.\"",
            scriptureReference: "1 Peter 3:3-4",
            prompt: "What does a 'gentle and quiet spirit' look like in your season right now? This isn't about being silent — it's about being unshakeable in God's peace."
        ),
        DailyPrompt(
            scripture: "\"Be on your guard; stand firm in the faith; be courageous; be strong. Do everything in love.\"",
            scriptureReference: "1 Corinthians 16:13-14",
            prompt: "What area of your life needs more courage today? Where can you stand firm and still lead with love? God has not given you a spirit of fear."
        ),
        DailyPrompt(
            scripture: "\"I praise you because I am fearfully and wonderfully made; your works are wonderful, I know that full well.\"",
            scriptureReference: "Psalm 139:14",
            prompt: "Comparison steals joy. Whose life are you measuring yours against? Speak truth over yourself: you are fearfully and wonderfully made for your unique calling."
        ),
        DailyPrompt(
            scripture: "\"Trust in the Lord with all your heart and lean not on your own understanding; in all your ways submit to him, and he will make your paths straight.\"",
            scriptureReference: "Proverbs 3:5-6",
            prompt: "What are you trying to control right now that God is asking you to surrender? Release your grip and trust His good plan for your life."
        ),
        DailyPrompt(
            scripture: "\"The Lord your God is with you, the Mighty Warrior who saves. He will take great delight in you; in his love he will no longer rebuke you, but will rejoice over you with singing.\"",
            scriptureReference: "Zephaniah 3:17",
            prompt: "God is singing over you right now. How does that change the way you see yourself today? Let His delight silence every voice of shame."
        ),
        DailyPrompt(
            scripture: "\"Do not be anxious about anything, but in every situation, by prayer and petition, with thanksgiving, present your requests to God.\"",
            scriptureReference: "Philippians 4:6",
            prompt: "What anxiety is weighing on your heart this morning? Name it, give it to God, and receive His peace that surpasses understanding."
        ),
        DailyPrompt(
            scripture: "\"For we are God's handiwork, created in Christ Jesus to do good works, which God prepared in advance for us to do.\"",
            scriptureReference: "Ephesians 2:10",
            prompt: "You are His masterpiece — not a rough draft. What good work has He placed in front of you today? Walk into it with confidence."
        ),
        DailyPrompt(
            scripture: "\"Be still, and know that I am God.\"",
            scriptureReference: "Psalm 46:10",
            prompt: "In a world that glorifies hustle, God says be still. What do you need to lay down today so you can simply rest in His presence?"
        ),
        DailyPrompt(
            scripture: "\"The wise woman builds her house, but with her own hands the foolish one tears hers down.\"",
            scriptureReference: "Proverbs 14:1",
            prompt: "What are you building today? Your words, actions, and priorities are laying bricks. Ask God to help you build with wisdom and grace."
        ),
        DailyPrompt(
            scripture: "\"She speaks with wisdom, and faithful instruction is on her tongue.\"",
            scriptureReference: "Proverbs 31:26",
            prompt: "How will you steward your words today? Your tongue has the power to build up or tear down. Ask the Holy Spirit to guard your speech."
        ),
        DailyPrompt(
            scripture: "\"And let us not grow weary of doing good, for in due season we will reap, if we do not give up.\"",
            scriptureReference: "Galatians 6:9",
            prompt: "Where are you feeling weary in doing good? The harvest is coming. Don't give up. God sees every unseen act of faithfulness."
        ),
        DailyPrompt(
            scripture: "\"But the fruit of the Spirit is love, joy, peace, forbearance, kindness, goodness, faithfulness, gentleness and self-control.\"",
            scriptureReference: "Galatians 5:22-23",
            prompt: "Which fruit of the Spirit do you most need today? Ask the Holy Spirit to cultivate it in you — not through striving, but through surrender."
        ),
        DailyPrompt(
            scripture: "\"She is more precious than rubies; nothing you desire can compare with her.\"",
            scriptureReference: "Proverbs 3:15",
            prompt: "You are more precious than rubies to your Father. What would change if you truly believed your immeasurable worth in His eyes today?"
        ),
        DailyPrompt(
            scripture: "\"He gives strength to the weary and increases the power of the weak.\"",
            scriptureReference: "Isaiah 40:29",
            prompt: "Where do you feel weak this morning? God doesn't ask you to be strong in yourself — He asks you to lean into His strength."
        ),
        DailyPrompt(
            scripture: "\"Therefore, as God's chosen people, holy and dearly loved, clothe yourselves with compassion, kindness, humility, gentleness and patience.\"",
            scriptureReference: "Colossians 3:12",
            prompt: "You are chosen, holy, and dearly loved. As you get dressed today — physically and spiritually — what virtue will you intentionally put on?"
        ),
        DailyPrompt(
            scripture: "\"The name of the Lord is a fortified tower; the righteous run to it and are safe.\"",
            scriptureReference: "Proverbs 18:10",
            prompt: "When fear or anxiety knocks, where do you run? Run to His name today. He is your safe place, your refuge, your strong tower."
        ),
        DailyPrompt(
            scripture: "\"Many women do noble things, but you surpass them all.\"",
            scriptureReference: "Proverbs 31:29",
            prompt: "Stop comparing your chapter 3 to someone else's chapter 20. God says you surpass them all — not because of perfection, but because of His purpose in you."
        ),
        DailyPrompt(
            scripture: "\"Come to me, all you who are weary and burdened, and I will give you rest.\"",
            scriptureReference: "Matthew 11:28",
            prompt: "What burden are you carrying that Jesus is asking you to lay down? He doesn't need your performance — He wants your presence."
        ),
        DailyPrompt(
            scripture: "\"I have told you these things, so that in me you may have peace. In this world you will have trouble. But take heart! I have overcome the world.\"",
            scriptureReference: "John 16:33",
            prompt: "Today might bring challenges, but you serve the One who has already overcome. What trouble can you face with fresh courage knowing He's already won?"
        ),
        DailyPrompt(
            scripture: "\"Who can find a virtuous woman? For her price is far above rubies.\"",
            scriptureReference: "Proverbs 31:10 (KJV)",
            prompt: "Virtue isn't about being perfect — it's about being purposeful. Where will you choose purpose over perfection today?"
        ),
        DailyPrompt(
            scripture: "\"She watches over the affairs of her household and does not eat the bread of idleness.\"",
            scriptureReference: "Proverbs 31:27",
            prompt: "Stewardship is a quiet superpower. What has God entrusted to you — relationships, time, talents — that deserves your intentional care today?"
        ),
        DailyPrompt(
            scripture: "\"So do not fear, for I am with you; do not be dismayed, for I am your God.\"",
            scriptureReference: "Isaiah 41:10",
            prompt: "What fear is trying to hold you back from stepping into God's calling? Name it. Then remind yourself: He is with you. He will strengthen you."
        ),
        DailyPrompt(
            scripture: "\"The Lord is my shepherd, I lack nothing.\"",
            scriptureReference: "Psalm 23:1",
            prompt: "Where do you feel lack today — in provision, love, purpose, energy? Your Shepherd says you have everything you need. Rest in His sufficiency."
        ),
        DailyPrompt(
            scripture: "\"Teach us to number our days, that we may gain a heart of wisdom.\"",
            scriptureReference: "Psalm 90:12",
            prompt: "This day is a gift. How will you steward it with wisdom? Not with perfection or busyness — but with intentional, grace-filled presence."
        ),
        DailyPrompt(
            scripture: "\"She sets about her work vigorously; her arms are strong for her tasks.\"",
            scriptureReference: "Proverbs 31:17",
            prompt: "Strength looks different in every season. What does 'strong for your tasks' look like today? Ask God for His vigor, not the world's hustle."
        ),
        DailyPrompt(
            scripture: "\"Above all else, guard your heart, for everything you do flows from it.\"",
            scriptureReference: "Proverbs 4:23",
            prompt: "What are you allowing into your heart today — through social media, conversations, thoughts? Guard your heart fiercely. Everything flows from it."
        ),
        DailyPrompt(
            scripture: "\"She opens her arms to the poor and extends her hands to the needy.\"",
            scriptureReference: "Proverbs 31:20",
            prompt: "Generosity is a mark of a woman rooted in abundance. Who can you bless today — with a word, an action, a prayer, or your presence?"
        ),
        DailyPrompt(
            scripture: "\"For I know the plans I have for you, declares the Lord, plans to prosper you and not to harm you, plans to give you hope and a future.\"",
            scriptureReference: "Jeremiah 29:11",
            prompt: "When the future feels uncertain, anchor yourself in this promise. His plans for you are good. What hope can you hold onto today?"
        ),
    ]

    // MARK: - Evening Prompts (Bloom)
    static let eveningPrompts: [DailyPrompt] = [
        DailyPrompt(
            scripture: "\"Let your light shine before others, that they may see your good deeds and glorify your Father in heaven.\"",
            scriptureReference: "Matthew 5:16",
            prompt: "How did your light shine today? Think of a moment — even small — where you reflected God's love, truth, or beauty to someone."
        ),
        DailyPrompt(
            scripture: "\"She speaks with wisdom, and faithful instruction is on her tongue.\"",
            scriptureReference: "Proverbs 31:26",
            prompt: "How did you nurture, speak truth gently, or cultivate peace today? Name one way you walked in your calling as a woman of God."
        ),
        DailyPrompt(
            scripture: "\"And let us consider how we may spur one another on toward love and good deeds.\"",
            scriptureReference: "Hebrews 10:24",
            prompt: "Who did you encourage today? How did you build someone up with your words, presence, or actions? Celebrate that bloom."
        ),
        DailyPrompt(
            scripture: "\"Whatever you do, work at it with all your heart, as working for the Lord.\"",
            scriptureReference: "Colossians 3:23",
            prompt: "What did you pour your heart into today? Whether it was visible or hidden, God saw it. How did you serve Him through your daily work?"
        ),
        DailyPrompt(
            scripture: "\"The Lord has done great things for us, and we are filled with joy.\"",
            scriptureReference: "Psalm 126:3",
            prompt: "What are three things — big or small — you're grateful for today? Let gratitude be the soil where tomorrow's blooms will grow."
        ),
        DailyPrompt(
            scripture: "\"Clothe yourselves with compassion, kindness, humility, gentleness and patience.\"",
            scriptureReference: "Colossians 3:12",
            prompt: "Which of these virtues did you wear today? Where did you show compassion, kindness, or patience — even when it was hard?"
        ),
        DailyPrompt(
            scripture: "\"She extends her hand to the poor, and she stretches out her hands to the needy.\"",
            scriptureReference: "Proverbs 31:20",
            prompt: "How did you serve someone beyond yourself today? Your generosity — of time, words, or presence — matters more than you know."
        ),
        DailyPrompt(
            scripture: "\"A gentle answer turns away wrath, but a harsh word stirs up anger.\"",
            scriptureReference: "Proverbs 15:1",
            prompt: "Was there a moment today where you chose gentleness over reaction? Or a moment you wish you had? Bring both to God with grace."
        ),
        DailyPrompt(
            scripture: "\"She is clothed with strength and dignity; she can laugh at the days to come.\"",
            scriptureReference: "Proverbs 31:25",
            prompt: "Where did you show strength today — not the world's version, but God's? Strength in surrender, in patience, in love, in standing firm."
        ),
        DailyPrompt(
            scripture: "\"Make it your ambition to lead a quiet life: You should mind your own business and work with your hands.\"",
            scriptureReference: "1 Thessalonians 4:11",
            prompt: "How did you steward your quiet influence today? Not everything needs to be loud to be powerful. What seeds did you plant in the unseen?"
        ),
        DailyPrompt(
            scripture: "\"But the wisdom that comes from heaven is first of all pure; then peace-loving, considerate, submissive, full of mercy.\"",
            scriptureReference: "James 3:17",
            prompt: "Did you seek heavenly wisdom today in a decision, conversation, or challenge? How did God guide you?"
        ),
        DailyPrompt(
            scripture: "\"Let your conversation be always full of grace, seasoned with salt.\"",
            scriptureReference: "Colossians 4:6",
            prompt: "Reflect on your conversations today. Where did grace flow through your words? Where would you invite more grace tomorrow?"
        ),
        DailyPrompt(
            scripture: "\"Two are better than one, because they have a good return for their labor.\"",
            scriptureReference: "Ecclesiastes 4:9",
            prompt: "How did you invest in your relationships today? As a helper, friend, sister, or partner — how did you strengthen the bonds God gave you?"
        ),
        DailyPrompt(
            scripture: "\"Therefore encourage one another and build each other up.\"",
            scriptureReference: "1 Thessalonians 5:11",
            prompt: "Who did you build up today? Encouragement is a gift. Celebrate the ways you gave it — and receive it — today."
        ),
        DailyPrompt(
            scripture: "\"May the God of hope fill you with all joy and peace as you trust in him.\"",
            scriptureReference: "Romans 15:13",
            prompt: "Where did you experience joy or peace today? Even in difficult moments, God's hope sustains us. Name where you saw His faithfulness."
        ),
        DailyPrompt(
            scripture: "\"In the same way, let your light shine before others.\"",
            scriptureReference: "Matthew 5:16",
            prompt: "What kingdom impact did you make today — through prayer, kindness, truth-telling, nurturing, or simply showing up? It all counts."
        ),
        DailyPrompt(
            scripture: "\"She watches over the affairs of her household and does not eat the bread of idleness.\"",
            scriptureReference: "Proverbs 31:27",
            prompt: "How did you steward your home, your work, or your responsibilities with care and intention today? Faithfulness in the small things matters."
        ),
        DailyPrompt(
            scripture: "\"The heart of her husband trusts in her, and he will have no lack of gain.\"",
            scriptureReference: "Proverbs 31:11",
            prompt: "How did you build trust in your relationships today? Whether with a spouse, friend, or family — trustworthiness is a bloom of its own."
        ),
        DailyPrompt(
            scripture: "\"For God gave us a spirit not of fear but of power and love and self-control.\"",
            scriptureReference: "2 Timothy 1:7",
            prompt: "Where did you exercise self-control today? Where did love win over fear? These are marks of the Spirit at work in you."
        ),
        DailyPrompt(
            scripture: "\"I have fought the good fight, I have finished the race, I have kept the faith.\"",
            scriptureReference: "2 Timothy 4:7",
            prompt: "You showed up today. You fought the good fight. How did you keep the faith — in big or small ways — even when it wasn't easy?"
        ),
        DailyPrompt(
            scripture: "\"Your people will be my people and your God my God.\"",
            scriptureReference: "Ruth 1:16",
            prompt: "Like Ruth, loyalty and devotion mark a woman of God. How did you show faithfulness to the people and calling God placed in your life today?"
        ),
        DailyPrompt(
            scripture: "\"The prayer of a righteous person is powerful and effective.\"",
            scriptureReference: "James 5:16",
            prompt: "Did you pray for someone today — a friend, a stranger, a family member? Your prayers are powerful. How did you intercede as a prayer warrior?"
        ),
        DailyPrompt(
            scripture: "\"She opens her mouth with wisdom, and the teaching of kindness is on her tongue.\"",
            scriptureReference: "Proverbs 31:26 (ESV)",
            prompt: "Teaching kindness doesn't require a platform — it flows from a life rooted in love. Where did kindness flow from you today?"
        ),
        DailyPrompt(
            scripture: "\"And we know that in all things God works for the good of those who love him.\"",
            scriptureReference: "Romans 8:28",
            prompt: "Even if today was hard, God is working all things for good. What challenge today might God be using for your growth and His glory?"
        ),
        DailyPrompt(
            scripture: "\"Set your minds on things above, not on earthly things.\"",
            scriptureReference: "Colossians 3:2",
            prompt: "Where was your mind today — on worry, comparison, or heavenly things? End this day by lifting your eyes to what is eternal and true."
        ),
        DailyPrompt(
            scripture: "\"Be completely humble and gentle; be patient, bearing with one another in love.\"",
            scriptureReference: "Ephesians 4:2",
            prompt: "Where did you practice patience and humility today? These quiet virtues are some of the most powerful blooms in God's garden."
        ),
        DailyPrompt(
            scripture: "\"Blessed is she who has believed that the Lord would fulfill his promises to her!\"",
            scriptureReference: "Luke 1:45",
            prompt: "Like Mary, blessed is the woman who believes. What promise from God are you holding onto? How did you trust Him with it today?"
        ),
        DailyPrompt(
            scripture: "\"Finally, brothers and sisters, whatever is true, whatever is noble, whatever is right... think about such things.\"",
            scriptureReference: "Philippians 4:8",
            prompt: "As you close this day, fill your mind with what is true, noble, right, pure, lovely, and admirable. What beautiful thing will you take into your rest tonight?"
        ),
        DailyPrompt(
            scripture: "\"The steadfast love of the Lord never ceases; his mercies never come to an end; they are new every morning.\"",
            scriptureReference: "Lamentations 3:22-23",
            prompt: "No matter how today went, His mercies are new tomorrow. Release any guilt, perfectionism, or disappointment. Rest in His steadfast love tonight."
        ),
        DailyPrompt(
            scripture: "\"She is worth far more than rubies.\"",
            scriptureReference: "Proverbs 31:10",
            prompt: "You are precious beyond measure. As you end this day, rest in the truth that your worth is not in what you did — but in who God says you are."
        ),
    ]

    // MARK: - Premium Deeper Reflections
    /// Additional deeper reflection questions for premium users
    static let premiumMorningReflections: [String] = [
        "Journal prompt: Write a letter to yourself from God's perspective, using today's scripture as the foundation. What would He say about your current season?",
        "Go deeper: Read the full chapter surrounding today's verse. What context changes how you understand it? How does the bigger story speak to your life?",
        "Cross-reference: Today's truth connects to Psalm 139. Read both passages together. What pattern of God's character do you see across Scripture?",
        "Meditate: Read today's verse three times slowly. The first time, listen for a word that stands out. The second time, ask God why. The third time, receive His answer.",
        "Journal prompt: What would your life look like if you fully believed today's scripture? Write about one specific area where this truth would change your actions.",
        "Go deeper: Research the original Hebrew or Greek meaning of one key word in today's verse. How does the deeper meaning enrich your understanding?",
        "Cross-reference: Compare today's verse with Romans 8:28-39. How do these truths together build an unshakeable foundation for your identity?",
        "Meditate: Sit in silence for 2 minutes after reading today's verse. Don't analyze — just listen. Write down whatever the Holy Spirit brings to mind.",
        "Journal prompt: Write about a time when the opposite of today's truth felt more real. How did God bring you back? What did that journey teach you?",
        "Go deeper: Imagine you're teaching today's scripture to your daughter, niece, or younger sister. How would you explain it? What story would you tell?",
        "Cross-reference: Today's verse echoes Isaiah 43:1-4. Read both and notice how God's love is personal, not generic. Write your name into the passage.",
        "Meditate: Pray today's scripture back to God in your own words. Turn His promises into personal declarations over your life.",
        "Journal prompt: What stronghold or lie has the enemy been using against you? Write today's truth as a weapon against it. Speak it out loud.",
        "Go deeper: Study the life of the biblical woman closest to today's theme. What can you learn from her faith, mistakes, and courage?",
        "Cross-reference: Connect today's verse to Ephesians 6:10-18. Which piece of the armor of God does this truth represent? How will you wear it today?",
        "Meditate: Choose one phrase from today's scripture. Repeat it with every breath for 60 seconds. Let it become the rhythm of your morning.",
        "Journal prompt: Write three specific ways you will live out today's truth before the sun sets. Make them actionable, not abstract.",
        "Go deeper: What cultural lie does today's scripture directly oppose? How has the world tried to redefine this truth? Stand firm in God's version.",
        "Cross-reference: Read Proverbs 31 alongside today's verse. How does the Proverbs 31 woman model the truth you're studying?",
        "Meditate: Draw or sketch something that represents today's verse. Art opens a different door to hearing God — let your creativity be worship.",
        "Journal prompt: Who in your life needs to hear today's truth? Write them a note or text sharing the verse and what it means to you.",
        "Go deeper: How would embracing today's truth change your marriage, friendships, or parenting? Get specific about one relationship.",
        "Cross-reference: Today's verse pairs beautifully with Lamentations 3:22-23. How do mercy, faithfulness, and today's theme weave together?",
        "Meditate: Take a prayer walk. With each step, meditate on a different word from today's scripture. Let movement and truth combine.",
        "Journal prompt: If fear wasn't a factor, how would today's truth change the way you show up? Write about your fearless version.",
        "Go deeper: Find a worship song that echoes today's scripture. Listen to it as an act of worship and write what stirs in your heart.",
        "Cross-reference: Pair today's verse with 2 Corinthians 12:9-10. How does God's strength in weakness connect to today's truth?",
        "Meditate: Write today's verse on a sticky note and place it where you'll see it all day. Each time you read it, whisper a one-sentence prayer.",
        "Journal prompt: What season of life are you in? Write about how today's truth applies specifically to THIS season — not a past or future one.",
        "Go deeper: End your morning anchor by writing a psalm of your own, inspired by today's verse. Pour out your heart like David did.",
    ]

    static let premiumEveningReflections: [String] = [
        "Evening journal: Write about a specific moment today when you felt God's presence. Describe it in detail — what were you doing, feeling, sensing?",
        "Go deeper: Review your day through the lens of the fruit of the Spirit. Which fruits were evident? Which felt absent? No judgment — just awareness.",
        "Gratitude deep dive: List 10 specific things from today you're grateful for. Challenge yourself to include things you might normally overlook.",
        "Cross-reference: Read Psalm 4:8 alongside tonight's verse. How do both speak to the peace God offers at the end of a long day?",
        "Evening journal: Write a confession and a celebration. One area you fell short, and one area you walked in obedience. God holds both with grace.",
        "Go deeper: Who did you serve today without being asked? Who served you? Reflect on how the body of Christ showed up in your day.",
        "Gratitude deep dive: Write a thank-you letter to God for one specific thing He did in your life today. Be detailed and personal.",
        "Cross-reference: Read Psalm 63:6-8 with tonight's verse. David meditated on God through the night watches. What truth will you take into sleep?",
        "Evening journal: Describe a conversation from today. How did you show grace? Where could you have shown more? Ask God for growth, not guilt.",
        "Go deeper: What surprised you today? Where did God show up unexpectedly? His faithfulness often appears in the unplanned moments.",
        "Gratitude deep dive: Thank God for one difficulty from today. How might He be using it for your growth? Trust His process even when it's hard.",
        "Cross-reference: Pair tonight's verse with Matthew 11:28-30. How is Jesus offering you rest right now? Lay your burdens at His feet.",
        "Evening journal: Rate your day from 1-10 on three scales: peace, purpose, and presence with God. Write one sentence about each score.",
        "Go deeper: What idol competed for your heart today — approval, control, comfort, or success? Name it without shame and surrender it.",
        "Gratitude deep dive: Think about one person who made your day better. Pray a specific blessing over their life right now.",
        "Cross-reference: Read Psalm 91 alongside tonight's verse. How does God's protection and presence wrap around you as you rest?",
        "Evening journal: What would you do differently if you could relive today? Not with regret — but with the wisdom God is building in you.",
        "Go deeper: Where did you see beauty today — in creation, a person, a moment? Beauty is God's signature. Write about finding Him in the ordinary.",
        "Gratitude deep dive: Write about a prayer God answered today — even partially. Answered prayer builds faith for tomorrow's requests.",
        "Cross-reference: Read Philippians 1:6 with tonight's verse. God began a good work in you and He will complete it. Reflect on your progress.",
        "Evening journal: Write about one way you mothered, mentored, or nurtured someone today — even if it felt small. It wasn't small to them.",
        "Go deeper: How did you steward your time today? Not with perfectionism — but with honesty. What matters most got your attention?",
        "Gratitude deep dive: Thank God for your body and what it allowed you to do today. We often forget to be grateful for the vessel He gave us.",
        "Cross-reference: Read Psalm 121 with tonight's verse. Your help comes from the Lord. Reflect on every way He helped you today.",
        "Evening journal: What truth do you want to carry into tomorrow? Write it down as a declaration you'll read when you wake up.",
        "Go deeper: Forgiveness check — is there anyone you need to release tonight? Unforgiveness is a heavy blanket. Let God take it before you sleep.",
        "Gratitude deep dive: Name three character qualities God is developing in you through this season. Celebrate the becoming, not just the being.",
        "Cross-reference: Read Isaiah 40:31 with tonight's verse. You may be tired, but those who hope in the Lord will renew their strength.",
        "Evening journal: Write a one-paragraph prayer for tomorrow. Surrender the unknowns. Claim God's promises. Release control and receive peace.",
        "Go deeper: As you close this day, read Song of Solomon 2:10-13. You are God's beloved. Rest in that identity tonight — nothing you did or didn't do changes it.",
    ]

    /// Scripture reminders for premium notifications throughout the day
    static let scriptureReminders: [(scripture: String, reference: String)] = [
        ("Be still, and know that I am God.", "Psalm 46:10"),
        ("The Lord is my strength and my shield; my heart trusts in him.", "Psalm 28:7"),
        ("Cast all your anxiety on him because he cares for you.", "1 Peter 5:7"),
        ("I can do all things through Christ who strengthens me.", "Philippians 4:13"),
        ("The Lord your God is with you, the Mighty Warrior who saves.", "Zephaniah 3:17"),
        ("His mercies are new every morning; great is His faithfulness.", "Lamentations 3:23"),
        ("God is within her, she will not fall.", "Psalm 46:5"),
        ("She is clothed with strength and dignity.", "Proverbs 31:25"),
        ("For I know the plans I have for you, declares the Lord.", "Jeremiah 29:11"),
        ("The Lord will fight for you; you need only to be still.", "Exodus 14:14"),
        ("He makes me lie down in green pastures, he leads me beside quiet waters.", "Psalm 23:2"),
        ("You are fearfully and wonderfully made.", "Psalm 139:14"),
        ("Trust in the Lord with all your heart.", "Proverbs 3:5"),
        ("My grace is sufficient for you, for my power is made perfect in weakness.", "2 Corinthians 12:9"),
        ("The joy of the Lord is your strength.", "Nehemiah 8:10"),
        ("He who began a good work in you will carry it on to completion.", "Philippians 1:6"),
        ("Do not be anxious about anything, but in every situation, by prayer, present your requests to God.", "Philippians 4:6"),
        ("For God has not given us a spirit of fear, but of power, love, and self-control.", "2 Timothy 1:7"),
        ("The Lord is close to the brokenhearted.", "Psalm 34:18"),
        ("But those who hope in the Lord will renew their strength.", "Isaiah 40:31"),
        ("Above all else, guard your heart, for everything you do flows from it.", "Proverbs 4:23"),
        ("Let the peace of Christ rule in your hearts.", "Colossians 3:15"),
        ("She opens her mouth with wisdom, and the teaching of kindness is on her tongue.", "Proverbs 31:26"),
        ("Delight yourself in the Lord, and he will give you the desires of your heart.", "Psalm 37:4"),
        ("Come to me, all you who are weary, and I will give you rest.", "Matthew 11:28"),
        ("In all things God works for the good of those who love him.", "Romans 8:28"),
        ("The name of the Lord is a fortified tower; the righteous run to it and are safe.", "Proverbs 18:10"),
        ("Many women do noble things, but you surpass them all.", "Proverbs 31:29"),
        ("Blessed is she who has believed that the Lord would fulfill his promises to her!", "Luke 1:45"),
        ("Whatever is true, whatever is noble, whatever is right... think about such things.", "Philippians 4:8"),
    ]

    // MARK: - Get Prompt for Date
    /// Returns a rotating morning prompt based on the day of the year
    static func morningPrompt(for date: Date) -> DailyPrompt {
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: date) ?? 1
        return morningPrompts[(dayOfYear - 1) % morningPrompts.count]
    }

    /// Returns a rotating evening prompt based on the day of the year
    static func eveningPrompt(for date: Date) -> DailyPrompt {
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: date) ?? 1
        return eveningPrompts[(dayOfYear - 1) % eveningPrompts.count]
    }

    /// Returns the premium deeper reflection for the morning
    static func premiumMorningReflection(for date: Date) -> String {
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: date) ?? 1
        return premiumMorningReflections[(dayOfYear - 1) % premiumMorningReflections.count]
    }

    /// Returns the premium deeper reflection for the evening
    static func premiumEveningReflection(for date: Date) -> String {
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: date) ?? 1
        return premiumEveningReflections[(dayOfYear - 1) % premiumEveningReflections.count]
    }

    /// Returns the scripture reminder for a given day and slot (0-2)
    static func scriptureReminder(for date: Date, slot: Int) -> (scripture: String, reference: String) {
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: date) ?? 1
        let index = ((dayOfYear - 1) * 3 + slot) % scriptureReminders.count
        return scriptureReminders[index]
    }
}
