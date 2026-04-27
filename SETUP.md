# QuickNotes — Setup Guide

## Prerequisites
- Xcode 15+
- Apple Developer account (free works for local testing; paid required for TestFlight/App Store)
- iCloud account signed in on your test device

## Xcode Project Setup

1. Open Xcode → File → New → Project
2. Choose **Multiplatform → App**
3. Product Name: `QuickNotes`
4. Bundle ID: `com.yourorg.quicknotes` (replace `yourorg`)
5. Choose **SwiftData** for storage
6. **Delete the generated files** and replace with the files in this folder

## Add Files to Xcode

Drag the entire `QuickNotes/` source folder into the Xcode project navigator.
Make sure "Copy items if needed" is checked and the target membership includes your app target.

## Configure CloudKit

1. Select your project in Xcode → Signing & Capabilities
2. Add capability: **iCloud** → check CloudKit
3. Add container: `iCloud.com.yourorg.quicknotes` (must match entitlements exactly)
4. Add capability: **Push Notifications**
5. Add capability: **Background Modes** → check Background fetch

## Configure Entitlements

Replace `com.yourorg.quicknotes` in `QuickNotes.entitlements` with your actual bundle ID.

In Apple Developer portal:
1. Create an iCloud container matching the identifier above
2. Enable CloudKit for your App ID

## Info.plist Additions

Add these keys to `Info.plist`:
```xml
<key>BGTaskSchedulerPermittedIdentifiers</key>
<array>
    <string>com.yourorg.quicknotes.refresh</string>
</array>
<key>UIBackgroundModes</key>
<array>
    <string>fetch</string>
    <string>processing</string>
</array>
```

## Run the App

- **Simulator**: CloudKit sync won't work; notifications work with limitations
- **Real device**: Full experience; sign in with iCloud account

## Optional: Enable Claude AI Categorization

1. Get an API key from console.anthropic.com
2. Open Settings in the app → toggle "Use Claude AI" → enter your API key
3. The key is stored in UserDefaults for MVP; move to Keychain for production

## Project Structure

```
QuickNotes/
├── App/
│   ├── QuickNotesApp.swift      ← @main entry point
│   └── AppDelegate.swift        ← iOS notification setup
├── Models/
│   ├── Note.swift               ← SwiftData model
│   ├── NoteCategory.swift       ← task / idea enum
│   └── NoteStatus.swift         ← pending / done / skipped enum
├── Persistence/
│   ├── ModelContainerFactory.swift  ← CloudKit container setup
│   └── NoteRepository.swift         ← CRUD operations
├── Categorization/
│   ├── Categorizer.swift            ← protocol
│   ├── HeuristicCategorizer.swift   ← keyword-based (default)
│   └── ClaudeCategorizer.swift      ← optional AI via API
├── Notifications/
│   ├── NotificationCategories.swift ← Done/Skip/Later action setup
│   ├── NotificationManager.swift    ← schedule nudges
│   ├── NudgeScheduler.swift         ← 2-day cadence logic
│   └── NotificationActionHandler.swift ← handle button taps
└── Features/
    ├── Capture/                 ← quick input view
    ├── NoteList/                ← task/idea list with swipe actions
    └── Settings/                ← notifications + AI toggle
```

## How It Works

1. **Capture**: Tap + → type anything → Save
2. **Categorize**: App auto-detects task vs. idea from your text
3. **Nudge**: Every 2 days, a notification appears for the oldest pending note
4. **Act**: Tap Done / Skip / Later directly on the notification — no need to open the app
