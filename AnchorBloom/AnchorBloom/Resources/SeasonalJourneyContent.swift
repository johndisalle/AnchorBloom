import Foundation

// MARK: - Seasonal Journey Definitions
/// Time-limited journeys that create urgency and seasonal relevance
enum SeasonalJourneyContent {

    // MARK: - Seasonal Availability

    /// Returns currently available seasonal journeys based on date
    static func availableJourneys(for date: Date = Date()) -> [Journey] {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)

        var available: [Journey] = []

        // Advent: November 27 — December 25
        if (month == 11 && day >= 27) || (month == 12 && day <= 25) {
            available.append(adventJourney)
        }

        // New Year, New Roots: December 26 — January 31
        if (month == 12 && day >= 26) || month == 1 {
            available.append(newYearJourney)
        }

        // Lent: roughly Feb 15 — April 5 (ends at Easter, which varies yearly)
        if (month == 2 && day >= 15) || month == 3 || (month == 4 && day <= 5) {
            available.append(lentJourney)
        }

        // Back-to-School Anchor: August 1 — September 15
        if month == 8 || (month == 9 && day <= 15) {
            available.append(backToSchoolJourney)
        }

        return available
    }

    /// Days remaining for a seasonal journey
    static func daysRemaining(for journey: Journey, from date: Date = Date()) -> Int? {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: date)

        switch journey.id {
        case "seasonal_advent":
            if let end = calendar.date(from: DateComponents(year: calendar.component(.year, from: date), month: 12, day: 25)) {
                return max(0, calendar.dateComponents([.day], from: date, to: end).day ?? 0)
            }
        case "seasonal_newyear":
            if let end = calendar.date(from: DateComponents(year: month == 12 ? calendar.component(.year, from: date) + 1 : calendar.component(.year, from: date), month: 1, day: 31)) {
                return max(0, calendar.dateComponents([.day], from: date, to: end).day ?? 0)
            }
        case "seasonal_lent":
            if let end = calendar.date(from: DateComponents(year: calendar.component(.year, from: date), month: 4, day: 5)) {
                return max(0, calendar.dateComponents([.day], from: date, to: end).day ?? 0)
            }
        case "seasonal_backtoschool":
            if let end = calendar.date(from: DateComponents(year: calendar.component(.year, from: date), month: 9, day: 15)) {
                return max(0, calendar.dateComponents([.day], from: date, to: end).day ?? 0)
            }
        default: break
        }
        return nil
    }

    // MARK: - Advent Journey (25 days)

    static let adventJourney = Journey(
        id: "seasonal_advent",
        title: "Advent: Waiting for the King",
        subtitle: "25 days to Christmas",
        description: "Journey through the weeks of Advent — Hope, Peace, Joy, and Love — as you prepare your heart for the celebration of Christ's birth.",
        iconName: "star.fill",
        coverColorName: "warmGold",
        totalDays: 25,
        isPremium: true,
        days: adventDays,
        scriptureTheme: "Isaiah 9:6, Luke 2"
    )

    private static let adventDays: [JourneyDay] = [
        JourneyDay(journeyID: "seasonal_advent", dayNumber: 1, title: "The Promise of Hope", scripture: "\"For to us a child is born, to us a son is given, and the government will be on his shoulders.\"", scriptureReference: "Isaiah 9:6", reflection: "Advent begins with hope — not the wishful-thinking kind, but the anchor-your-soul kind. Hundreds of years before Jesus arrived, God made a promise. And He kept it. What promise of God are you waiting on today?", prompt: "What are you hoping God will do in your life this season?", actionStep: "Light a candle tonight and sit in silence for 2 minutes, holding your hope before God.", prayer: "Lord, as this Advent season begins, plant hope deep in my heart. You are the God who keeps promises. Help me wait with expectation, not anxiety. Amen."),
        JourneyDay(journeyID: "seasonal_advent", dayNumber: 2, title: "A Light in the Darkness", scripture: "\"The people walking in darkness have seen a great light; on those living in the land of deep darkness a light has dawned.\"", scriptureReference: "Isaiah 9:2", reflection: "Before Jesus came, the world was in spiritual darkness. And into that darkness, God sent light. If you're in a dark season right now, know this: light is coming. It always does.", prompt: "Where do you need God's light to break through in your life?", actionStep: "Text someone who might be in a dark season and tell them you're praying for them.", prayer: "Father, be my light today. Where there is darkness in my heart, my home, my mind — shine. I choose to look for Your light even when everything feels dim. Amen."),
        JourneyDay(journeyID: "seasonal_advent", dayNumber: 3, title: "Mary's Yes", scripture: "\"I am the Lord's servant. May your word to me be fulfilled.\"", scriptureReference: "Luke 1:38", reflection: "Mary was young, unmarried, and unprepared by the world's standards. But when God called, she said yes. Not because she understood — but because she trusted. What is God asking you to say yes to, even when it doesn't make sense?", prompt: "Is there something God is asking of you that scares you?", actionStep: "Write down one thing you need to surrender to God today and place it somewhere you'll see it.", prayer: "Lord, give me Mary's courage. I don't need to understand everything — I just need to trust You. Here I am. Use me. Amen."),
        JourneyDay(journeyID: "seasonal_advent", dayNumber: 4, title: "The Genealogy of Grace", scripture: "\"A record of the genealogy of Jesus the Messiah the son of David, the son of Abraham.\"", scriptureReference: "Matthew 1:1", reflection: "Jesus's family tree includes liars, adulterers, outsiders, and the broken. God didn't need a perfect lineage — He redeemed an imperfect one. Your messy history doesn't disqualify you. It qualifies you for grace.", prompt: "What part of your story have you been ashamed of that God might want to redeem?", actionStep: "Thank God for one specific way He's brought beauty from the mess in your life.", prayer: "Father, thank You for using imperfect people to accomplish Your perfect plan. Use my story — all of it — for Your glory. Amen."),
        JourneyDay(journeyID: "seasonal_advent", dayNumber: 5, title: "Waiting Well", scripture: "\"But those who hope in the Lord will renew their strength. They will soar on wings like eagles.\"", scriptureReference: "Isaiah 40:31", reflection: "Advent is a season of waiting. And waiting is hard. We want answers now, healing now, breakthrough now. But God's timing isn't just about the destination — it's about who you become while you wait.", prompt: "What is the hardest thing you're waiting for right now?", actionStep: "Set a timer for 5 minutes and sit in stillness. Practice waiting with God.", prayer: "Lord, teach me to wait well. Not passively, but expectantly. Renew my strength as I hope in You. I trust Your timing even when mine runs out. Amen."),
    ]

    // MARK: - New Year, New Roots (14 days)

    static let newYearJourney = Journey(
        id: "seasonal_newyear",
        title: "New Year, New Roots",
        subtitle: "A fresh start with God",
        description: "Start the new year not with resolutions that fade, but with roots that hold. 14 days of anchoring your identity, priorities, and purpose in Christ.",
        iconName: "leaf.fill",
        coverColorName: "sageGreen",
        totalDays: 14,
        isPremium: true,
        days: newYearDays,
        scriptureTheme: "Jeremiah 17:7-8, Psalm 1"
    )

    private static let newYearDays: [JourneyDay] = [
        JourneyDay(journeyID: "seasonal_newyear", dayNumber: 1, title: "Not Resolutions — Roots", scripture: "\"Blessed is the one who trusts in the Lord, whose confidence is in him. They will be like a tree planted by the water.\"", scriptureReference: "Jeremiah 17:7-8", reflection: "The world says 'new year, new you.' But God says 'new year, deeper roots.' You don't need to reinvent yourself. You need to plant yourself — in His Word, in His presence, in His truth. Trees that survive storms aren't the ones that grew the fastest. They're the ones with the deepest roots.", prompt: "What do you want to be rooted in this year?", actionStep: "Write down 3 words that describe who you want to become this year (not what you want to achieve).", prayer: "Lord, I don't want to start this year striving. I want to start it rooted. Plant me deep in You. Make me unshakeable. Amen."),
        JourneyDay(journeyID: "seasonal_newyear", dayNumber: 2, title: "Letting Go of Last Year", scripture: "\"Forget the former things; do not dwell on the past. See, I am doing a new thing!\"", scriptureReference: "Isaiah 43:18-19", reflection: "Before you can step forward, you have to release what's behind you. The regrets, the failures, the 'what ifs' — lay them down. God is doing a new thing, but you'll miss it if you're still looking backward.", prompt: "What from last year do you need to leave behind?", actionStep: "Write one thing you're releasing from last year on a piece of paper. Then tear it up.", prayer: "Father, I release last year to You — the good and the bad. I trust that You are doing a new thing. Open my eyes to see it. Amen."),
        JourneyDay(journeyID: "seasonal_newyear", dayNumber: 3, title: "Your Word for the Year", scripture: "\"Your word is a lamp for my feet, a light on my path.\"", scriptureReference: "Psalm 119:105", reflection: "Instead of a list of goals, ask God for one word. A single word that will anchor your entire year. It might be 'trust,' 'surrender,' 'courage,' 'rest,' or 'joy.' Let Him choose. Then let that word guide every decision.", prompt: "What word is God placing on your heart for this year?", actionStep: "Ask God for your word. Write it down. Put it where you'll see it every day.", prayer: "God, speak Your word over my year. Not my word — Yours. Give me a word that will anchor me through every season ahead. Amen."),
    ]

    // MARK: - Lent Journey (40 days — first 5 shown)

    static let lentJourney = Journey(
        id: "seasonal_lent",
        title: "40 Days of Surrender",
        subtitle: "A Lenten journey to the cross",
        description: "Walk with Jesus from the wilderness to the cross. 40 days of surrender, sacrifice, and the radical love that changed everything.",
        iconName: "cross.fill",
        coverColorName: "darkNavy",
        totalDays: 40,
        isPremium: true,
        days: lentDays,
        scriptureTheme: "Matthew 4, Luke 22-24"
    )

    private static let lentDays: [JourneyDay] = [
        JourneyDay(journeyID: "seasonal_lent", dayNumber: 1, title: "Into the Wilderness", scripture: "\"Then Jesus was led by the Spirit into the wilderness to be tempted by the devil.\"", scriptureReference: "Matthew 4:1", reflection: "Lent begins in the wilderness. Jesus didn't stumble there — the Spirit led Him there. Sometimes God leads us into hard places not to punish us, but to prepare us. What wilderness are you in right now? What if it's not a punishment — but a preparation?", prompt: "What wilderness is God leading you through this season?", actionStep: "Choose one thing to fast from for the next 40 days. Not as punishment — as surrender.", prayer: "Lord, if You're leading me into a wilderness, I'll go. Not because I'm brave, but because I trust Your plan. Prepare me for what's next. Amen."),
        JourneyDay(journeyID: "seasonal_lent", dayNumber: 2, title: "Bread Alone", scripture: "\"Man shall not live on bread alone, but on every word that comes from the mouth of God.\"", scriptureReference: "Matthew 4:4", reflection: "When Jesus was hungry, the enemy offered bread. When you're empty, the world offers distractions. But Jesus chose God's Word over quick satisfaction. What are you feeding on? Social media, approval, busyness — or His Word?", prompt: "What are you feeding on that isn't satisfying you?", actionStep: "Before opening your phone tomorrow morning, read one verse first.", prayer: "Father, I've been feeding on things that leave me empty. I choose Your Word today. Fill me with what truly satisfies. Amen."),
        JourneyDay(journeyID: "seasonal_lent", dayNumber: 3, title: "The Cost of Following", scripture: "\"Whoever wants to be my disciple must deny themselves and take up their cross daily and follow me.\"", scriptureReference: "Luke 9:23", reflection: "Following Jesus costs something. It cost Him everything. Lent reminds us that faith isn't just comfort and blessing — it's sacrifice. Not sacrifice that earns God's love (you already have that), but sacrifice that proves yours.", prompt: "What is following Jesus costing you right now?", actionStep: "Do one act of sacrificial kindness today that no one will know about.", prayer: "Jesus, I want to follow You — not just when it's easy, but when it costs me. Give me courage to carry my cross today. Amen."),
    ]

    // MARK: - Back-to-School Anchor (14 days)

    static let backToSchoolJourney = Journey(
        id: "seasonal_backtoschool",
        title: "Back-to-School Anchor",
        subtitle: "Grounding before the chaos",
        description: "Before the routines, the schedules, and the pressure return — anchor your family in God's peace. 14 days of preparation for the season ahead.",
        iconName: "backpack.fill",
        coverColorName: "blush",
        totalDays: 14,
        isPremium: true,
        days: backToSchoolDays,
        scriptureTheme: "Proverbs 22:6, Joshua 1:9"
    )

    private static let backToSchoolDays: [JourneyDay] = [
        JourneyDay(journeyID: "seasonal_backtoschool", dayNumber: 1, title: "Before the Rush Begins", scripture: "\"Be still, and know that I am God.\"", scriptureReference: "Psalm 46:10", reflection: "The world is about to speed up. School schedules, activities, homework, routines — it's coming. Before the rush hits, take today to be still. God doesn't want you to enter this season frantic. He wants you anchored.", prompt: "What are you most anxious about this upcoming season?", actionStep: "Spend 5 minutes in complete silence. Give your anxieties to God one by one.", prayer: "Lord, before the chaos of this season begins, I give it all to You. Every schedule, every worry, every unknown. You go before me. I will be still. Amen."),
        JourneyDay(journeyID: "seasonal_backtoschool", dayNumber: 2, title: "Praying Over Your Children", scripture: "\"Start children off on the way they should go, and even when they are old they will not turn from it.\"", scriptureReference: "Proverbs 22:6", reflection: "The most powerful thing you can do for your children isn't packing the perfect lunch or choosing the right school. It's covering them in prayer. Pray over their friendships, their hearts, their teachers, their faith. What you plant in prayer, God grows in their lives.", prompt: "What specific prayer do you have for your child this school year?", actionStep: "Write a prayer for each child and tuck it into their backpack or bedroom.", prayer: "Father, I place my children in Your hands. Protect them, guide them, and surround them with people who point them to You. Grow their faith even when I can't be there. Amen."),
    ]
}
