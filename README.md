# Anchor & Bloom

**Rooted in Christ. Blooming into who God created you to be.**

A daily habit-tracking journal app for Christian women, built with SwiftUI and Firebase.

## Tech Stack

- **SwiftUI** (iOS 17+)
- **Firebase** (Auth, Firestore, Storage)
- **StoreKit 2** (Subscriptions)
- **AVFoundation** (Prayer audio playback)
- **UserNotifications** (Daily reminders)

## Setup

1. Clone the repository
2. Open `AnchorBloom/AnchorBloom.xcodeproj` in Xcode 15+
3. Add Firebase iOS SDK via File > Add Package Dependencies:
   - `https://github.com/firebase/firebase-ios-sdk.git` (v10.19+)
   - Add: FirebaseAuth, FirebaseFirestore, FirebaseStorage
4. Set up Firebase:
   - Create project at [Firebase Console](https://console.firebase.google.com)
   - Add iOS app with bundle ID `com.anchorbloom.app`
   - Download `GoogleService-Info.plist` and add to `AnchorBloom/AnchorBloom/App/`
   - Enable Email/Password and Apple Sign-In authentication
   - Create Firestore database and deploy `firestore.rules`
5. Build and run on simulator or device (iOS 17+)

## Project Structure

```
AnchorBloom/
├── App/                    # App entry point, theme, navigation
├── Models/                 # Data models (User, DailyEntry, Circle, etc.)
├── Services/               # Firebase, Auth, Subscriptions, Audio, Notifications
├── Views/
│   ├── Onboarding/         # Welcome screens and authentication
│   ├── Dashboard/          # Home screen with blooming tree
│   ├── Anchor/             # Morning devotional screen
│   ├── Bloom/              # Evening reflection screen
│   ├── DriftLog/           # Quick drift logging with prayer audio
│   ├── Progress/           # Stats, calendar, badge gallery
│   ├── Journey/            # 30-day guided journeys
│   ├── Circles/            # Sister Circles community
│   ├── Settings/           # Settings and subscription management
│   └── Components/         # Reusable components (BloomingTreeView, etc.)
├── Resources/              # Journey content, App Store assets
└── Preview Content/        # SwiftUI preview sample data
```

## Features

- **Morning Anchor**: Daily Scripture + reflection with tag selection
- **Evening Bloom**: Biblical womanhood role reflection
- **Drift Log**: One-tap mood tracking with instant prayer audio
- **Blooming Tree**: Visual growth tracker with animated flowers/fruit
- **30-Day Journeys**: 7 guided spiritual growth paths
- **Sister Circles**: Private community groups
- **Badges & Streaks**: Achievement system for consistency
- **Premium**: $6.99/mo or $59.99/yr via StoreKit 2

## Color Palette

| Color | Hex | Usage |
|-------|-----|-------|
| Sage Green | #8FAD94 | Primary accent, buttons |
| Blush | #E3B8B8 | Secondary accent, bloom elements |
| Warm Gold | #D9BF8C | Highlights, badges, premium |
| Cream | #F8F2E8 | Background |
| Dark Navy | #262E45 | Primary text |
